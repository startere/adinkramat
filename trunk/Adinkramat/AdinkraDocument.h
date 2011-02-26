//
//  AdinkraDocument.h
//  Adinkramatic
//
//  Created by Greg Landweber on 8/11/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AdinkraView.h"

@interface AdinkraDocument : NSDocument <ShowsProgress> {

//	IBOutlet NSWindow *window;
	
    IBOutlet id adinkraProgress;
    IBOutlet id adinkraSheet;
    IBOutlet id adinkraString;
    IBOutlet id adinkraType;
    IBOutlet AdinkraView *adinkraView;
	IBOutlet id dashedEdgesButton;
    IBOutlet id edgeDrawer;
    IBOutlet id edgeMatrix;
    IBOutlet id edgeMax;
	IBOutlet id edgeStepper;
    IBOutlet id NField;
	IBOutlet id OKButton;
	IBOutlet id oneEdge;
	IBOutlet id oneEdgeStepper;
	IBOutlet id extendedValise;
	
	// To pass to AdinkraView once awake
	Adinkra *theAdinkra;
	NSMutableArray *showEdges;
	NSMutableSet *edgeSet;
	BOOL drawDashedEdges;

	// So we don't resize the window more than once
	BOOL awake;
	
	// For the Adinkra Construction Thread
	int	N;
	int adinkraTypeCode;
	BOOL isValise;
	BOOL cancelled;	
	NSAutoreleasePool *pool;
}

//
// Actions in FirstResponder
//

- (IBAction)scaleToWindow:(id)sender;
- (IBAction)toggleEdgeDrawer:(id)sender;

//
// Actions specific to AdinkraDocument
//

- (IBAction)allEdgesUpToN:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)dashedEdges:(id)sender;
- (IBAction)new:(id)sender;
- (IBAction)OK:(id)sender;
- (IBAction)oneEdge:(id)sender;
- (IBAction)showEdges:(id)sender;

//
// Undo methods in AdinkraDocument
//

- (void)setDrawDashedEdges: (NSNumber *)drawDashedEdgesObject;
- (void)setEdgeSet: (NSSet *)newEdgeSet;

//
// Other methods in AdinkraDocument
//

- (void)resizeWindowToAdinkra;

//
// AdinkraDocument Thread Methods
//

- (void)detatchAdinkraConstructionThread;
- (void)constructAdinkra: (id)anObject;

- (void) showProgress: (NSDictionary *)userInfo;
- (void) setAdinkra: (Adinkra *)anAdinkra;

@end