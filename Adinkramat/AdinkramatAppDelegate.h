//
//  AdinkramatAppDelegate.h
//  Adinkramatic
//
//  Created by James on 2/13/11.
//  Copyright 2011 university of md college park. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "AdinkraInspectorWindowController.h"

@interface AdinkramatAppDelegate : NSObject {
    IBOutlet NSPanel *inspectorWindow;
}

// Interface Methods
- (IBAction)toggleInspector:(id) sender;

// Operation Methods
- (IBAction)multiplyAdinkras:(id) sender;
- (IBAction)commutateAdinkras:(id) sender;

@end