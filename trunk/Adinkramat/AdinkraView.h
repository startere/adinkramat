#import <Cocoa/Cocoa.h>
#import "Adinkra.h"

#define ALPHA 0.3

@interface AdinkraView : NSView {

    Adinkra *theAdinkra;
	NSSet	*edgeSet;
	BOOL	drawDashedEdges;
	
	BOOL	fillWindow;
	BOOL	showHiddenVertices;
	
	NSMutableSet	*selectedVertices;
	
    // private variables for dragging
    Vertex	*draggingVertex;
	NSRect	draggingBounds;
	NSRect	updateBounds;
	
	NSSize	scale;
	
	// user defaults
	float edgeThickness;
	float vertexRadius;
	float vertexSpacing;
	BOOL drawShadow;
}

//
// Accessor methods
//

- (Adinkra *)adinkra;
- (void)setAdinkra: (Adinkra *)adinkra;

- (void)setEdgeSet: (NSSet *)set;

- (BOOL)doesFillWindow;
- (void)setFillWindow: (BOOL)newFillWindow;

- (BOOL)doesDrawDashedEdges;
- (void)setDrawDashedEdges: (BOOL)newDrawDashedEdges;

// 
// Other methods
//

//- (void)cachePaths;
- (NSRect)shrinkWrappedBounds;
- (void)locateVerticesWithAnimation: (BOOL)animate;
- (Vertex *)vertexHit: (NSPoint)testPoint;

//
// Undo methods
//

- (void)moveVertexUsingDictionary: (NSDictionary *)dictionary;
- (void)registerUndoActionName: (NSString *)actionName;

//
// NSNotification observers
//

- (void)userDefaultsDidChange: (NSNotification *)notification;


//-(void)mouseDown:(NSEvent *)event;
//-(void)mouseDragged:(NSEvent *)event;
//-(void)mouseUp:(NSEvent *)event;


//- (id)initWithFrame:(NSRect)frame;

// -----------------------------------
// Draw the View Content
// -----------------------------------

// This doesn't belong here, but I'll deal with that later.

//- (void)drawRect:(NSRect)rect;

//- (BOOL)isOpaque;
// -----------------------------------
// Modify the Rectange location 
// -----------------------------------

//- (void)offsetLocationByX:(float)x andY:(float)y;
// -----------------------------------
// Handle Mouse Events 
// -----------------------------------

// -----------------------------------
// First Responder Methods
// -----------------------------------

//- (BOOL)acceptsFirstResponder;
// -----------------------------------
// Handle KeyDown Events 
// -----------------------------------
//- (void)keyDown:(NSEvent *)event;

// -----------------------------------
// Handle color changes via first responder 
// -----------------------------------
//- (void)changeColor:(id)sender;

// -----------------------------------
// Reset Cursor Rects 
// -----------------------------------
//-(void)resetCursorRects;

// -----------------------------------
// Handle NSResponder Actions 
// -----------------------------------

/*
-(IBAction)moveUp:(id)sender;
-(IBAction)moveDown:(id)sender;
-(IBAction)moveLeft:(id)sender;
-(IBAction)moveRight:(id)sender;
-(IBAction)setItemPropertiesToDefault:(id)sender;
*/

// -----------------------------------
// Various Accessor Methods
// -----------------------------------
/*
- (void)setItemColor:(NSColor *)aColor;
- (NSColor *)itemColor;

- (void)setLocation:(NSPoint)point;
- (NSPoint)location;
- (NSRect)calculatedItemBounds;

- (void)setBackgroundColor:(NSColor *)aColor;
- (NSColor *)backgroundColor;
*/

@end

