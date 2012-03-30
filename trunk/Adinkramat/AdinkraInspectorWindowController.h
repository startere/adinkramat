//
//  AdinkraInspectorWindowController.h
//  Adinkramatic
//
//  Created by James on 6/30/11.
//  Copyright 2011 university of md college park. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AdinkraDocument.h"

@interface AdinkraInspectorWindowController : NSWindowController {
@private
    NSView *noSelectionView;
}

@property (retain) IBOutlet NSView *noSelectionView;

@end
