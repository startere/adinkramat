//
//  AdinkraInspectorWindowController.m
//  Adinkramatic
//
//  Created by James on 6/30/11.
//  Copyright 2011 university of md college park. All rights reserved.
//

#import "AdinkraInspectorWindowController.h"


@implementation AdinkraInspectorWindowController
@synthesize noSelectionView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self selector:@selector(documentActivateNotification:)
                       name:AdinkraDocument_DocumentActivateNotification object:nil];
        
        [center addObserver:self selector:@selector(documentDeactivateNotification:)
                       name:AdinkraDocument_DocumentDeactivateNotification object: nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[ NSNotificationCenter defaultCenter ] removeObserver:self ];
    [ self setNoSelectionView:nil ];
    
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self setShouldCascadeWindows: NO];
    [self setWindowFrameAutosaveName: @"inspectorWindow"];
}

- (NSString *) windowTitleForDocumentDisplayName: (NSString *) name {
    return @"Inspector";
}

#pragma mark -
#pragma mark Handle notifications

- (void) documentActivateNotification: (NSNotification *) notification {
    NSDocument *document = [notification object];
    [self setDocument: document];
}


- (void) documentDeactivateNotification: (NSNotification *) notification {
    [self setDocument: nil];
}

- (void) setDocument: (NSDocument *) document {
    [super setDocument: document];
    
    NSView *view = document ? [ document valueForKey:@"inspectorView" ] : noSelectionView;
    [[ self window ] setContentView:view ];
}

@end
