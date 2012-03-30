//
//  AdinkramatAppDelegate.m
//  Adinkramatic
//
//  Created by James on 2/13/11.
//  Copyright 2011 university of md college park. All rights reserved.
//

#import "AdinkramatAppDelegate.h"


@implementation AdinkramatAppDelegate

#pragma mark -
#pragma mark Delegate Methods

// JP - 6/30/11
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Register our defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]];
	
    [defaults registerDefaults:appDefaults];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:appDefaults ];
    
    // Load Inspector.
    if (![NSBundle loadNibNamed:@"Inspector" owner:self ])
        NSLog(@"Warning: Failed to load inspector.");
    
    [ inspectorWindow setIsVisible:[[ NSUserDefaults standardUserDefaults ] boolForKey:@"inspectorVisible" ]];
}

// JP - 9/2/11
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[ NSUserDefaults standardUserDefaults ] setBool:[ inspectorWindow isVisible ] forKey:@"inspectorVisible" ];
}

#pragma mark -
#pragma mark Interface Methods

// JP - 6/30/11
- (IBAction)toggleInspector:(id) sender {
    if ([ inspectorWindow isVisible ])
        [inspectorWindow orderOut:self];
    else
        [inspectorWindow makeKeyAndOrderFront:self];
}

#pragma mark NSMenuValidation Protocol

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem {
	if ( [menuItem action] == @selector(toggleInspector:) ) {
        if ([ inspectorWindow isVisible ])
			[menuItem setTitle: @"Hide Inspector"];
		else
			[menuItem setTitle: @"Show Inspector"];
	}
    
	return true;
}

#pragma mark -
#pragma mark Operation Methods

// JP - 2/26/11
// Launches a window to multiply two adinkras together.
- (IBAction)multiplyAdinkras:(id) sender {
	NSLog(@"multiply");
}

// JP - 2/26/11
// Launches a window to commutate two adinkras.
- (IBAction)commutateAdinkras:(id)sender {
	NSLog(@"commutate");
}

@end
