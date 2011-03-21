#import "AdinkraView.h"
#import "NSUserDefaults+myColorSupport.h"

@implementation AdinkraView

// -----------------------------------
// Initialize the View
// -----------------------------------

#pragma mark NSObject Methods

// Register our defaults
+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]];
	
    [defaults registerDefaults:appDefaults];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:[ appDefaults retain ] ];
}

- (void)dealloc
{
	NSUserDefaultsController *theController = [NSUserDefaultsController sharedUserDefaultsController];
	
	[theController removeObserver: self forKeyPath: @"values.edgeThickness"];	
	[theController removeObserver: self forKeyPath: @"values.vertexRadius"];
	[theController removeObserver: self forKeyPath: @"values.vertexSpacing"];
	[theController removeObserver: self forKeyPath: @"values.drawShadow"];
	
	[theAdinkra release];	
	[edgeSet release];

	[solidEdgePaths release];
	[dashedEdgePaths release];
	[blackVertexFillPath release];
	[whiteVertexFillPath release];
	[vertexStrokePath release];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[selectedVertices release];
	
    // call super
    [super dealloc];  
}

#pragma mark NSNibAwakening Protocol

- (void)awakeFromNib
{
	edgeThickness = [[NSUserDefaults standardUserDefaults] floatForKey: @"edgeThickness" ];
	vertexRadius = [[NSUserDefaults standardUserDefaults] floatForKey: @"vertexRadius" ];
	vertexSpacing = [[NSUserDefaults standardUserDefaults] floatForKey: @"vertexSpacing" ];
	drawShadow = [[NSUserDefaults standardUserDefaults] boolForKey: @"drawShadow" ];
}


#pragma mark NSView Methods

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		theAdinkra = nil;
		edgeSet = nil;
		
		draggingVertex = nil;
		
		fillWindow = false;
        showHiddenVertices = YES;
		
		drawDashedEdges = YES;
		
		solidEdgePaths = nil;
		dashedEdgePaths = nil;
		
		blackVertexFillPath = nil;
		whiteVertexFillPath = nil;
		vertexStrokePath = nil;
		
		selectedVertices = [[NSMutableSet setWithCapacity: 1] retain];
			
		NSUserDefaultsController *theController = [NSUserDefaultsController sharedUserDefaultsController];
		
		[theController addObserver: self forKeyPath: @"values.edgeThickness" options: 0 context: NULL];
		[theController addObserver: self forKeyPath: @"values.vertexRadius" options: 0 context: NULL];
		[theController addObserver: self forKeyPath: @"values.vertexSpacing" options: 0 context: NULL];
		[theController addObserver: self forKeyPath: @"values.drawShadow" options: 0 context: NULL];
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{		
	BOOL shouldDrawFast = false;
//	//( draggingVertex && ( [theAdinkra vertexCount] >= 16 ) ) ||
						  ( fillWindow && ( [theAdinkra vertexCount] >= 128 ) ) ||
						  ( !fillWindow && ( [theAdinkra vertexCount] >= 1024 ) );

	[self cachePaths];

	float array[2];
	array[0] = 3*edgeThickness;
	array[1] = 3*edgeThickness;

	NSShadow* theShadow;
	[NSGraphicsContext saveGraphicsState]; 
	 
	// Create the shadow below and to the right of the shape.
	theShadow = [[NSShadow alloc] init]; 
	[theShadow setShadowOffset:NSMakeSize(0.0, - edgeThickness / 2.0 )]; 
	[theShadow setShadowBlurRadius: edgeThickness]; 
	 
	// Use a partially transparent color for shapes that overlap.
	[theShadow setShadowColor:[[NSColor blackColor]
				 colorWithAlphaComponent:0.3]]; 
	 
	if ( drawShadow )
		[theShadow set];

	int i;
	for ( i = 1; i <= 32; i++ )
		if ( [edgeSet containsObject: [NSNumber numberWithInt: i ] ] ) {
			NSColor *theColor = [[NSUserDefaults standardUserDefaults] colorForKey: [NSString stringWithFormat: @"Q%iColor", i] ];
			if ( !theColor )
				theColor = [[NSColor blackColor] colorWithAlphaComponent: 0.25];
			[theColor set];
			
			NSBezierPath *aPath;
			
			aPath = [ solidEdgePaths objectAtIndex: (i-1) ];
			[ aPath setLineCapStyle: shouldDrawFast ? NSSquareLineCapStyle : NSRoundLineCapStyle ];
			[ aPath setLineWidth: edgeThickness ];
			[ aPath stroke ];
			
			aPath = [dashedEdgePaths objectAtIndex: (i-1) ];
			[ aPath setLineCapStyle: shouldDrawFast ? NSSquareLineCapStyle : NSRoundLineCapStyle ];
			[ aPath setLineWidth: edgeThickness ];
			[ aPath setLineDash: array count: drawDashedEdges ? 2 : 0 phase: 0.0];
			[ aPath stroke ];
		}
	
	[theShadow setShadowOffset:NSMakeSize(0.0, - edgeThickness )]; 
	if ( drawShadow )
		[theShadow set];
	
	[[NSColor whiteColor] set];
	if ( ( vertexRadius >= 1.0 ) )
		[ whiteVertexFillPath fill ];
	
	[[NSColor blackColor] set];
	if ( ( vertexRadius >= 1.0 ) )
		[ blackVertexFillPath fill ];
	
	[NSGraphicsContext restoreGraphicsState];
	[theShadow release]; 
	 
	[ vertexStrokePath setLineWidth: edgeThickness ];
	if ( ( vertexRadius + edgeThickness / 2.0 >= 1.0 ) )
		[ vertexStrokePath stroke ];
	
    if ( [NSGraphicsContext currentContextDrawingToScreen] ) {
		NSBezierPath *selectedVerticesPath = [NSBezierPath bezierPath];
		
		NSEnumerator *vertexEnumerator = [selectedVertices objectEnumerator];
		Vertex *aVertex;
		while ( aVertex = [vertexEnumerator nextObject] ) {
			NSPoint location = [aVertex location];
			NSRect	vertexRect = NSMakeRect ( location.x - vertexRadius, location.y - vertexRadius, 2 * vertexRadius, 2 * vertexRadius );
			if ( edgeThickness > 4.0 )
				vertexRect = NSInsetRect ( vertexRect, - edgeThickness, - edgeThickness );
			else
				vertexRect = NSInsetRect ( vertexRect, - 2.0 - edgeThickness / 2.0, - 2.0 - edgeThickness / 2.0 );
			
			[selectedVerticesPath appendBezierPathWithOvalInRect:vertexRect];
		}
		[[NSColor selectedControlColor] set];

		[selectedVerticesPath setLineWidth: edgeThickness > 4.0 ? edgeThickness : 4.0 ];
		
		[selectedVerticesPath stroke];
	}
}

/*
- (void)drawRect:(NSRect)rect
{

//	if ( theAdinkra && !NSEqualRects ( oldBounds, [self bounds] ) ) {
//		oldBounds = [self bounds];
//		[self locateVertices];
//	}	

	// erase the background by drawing white
	//	[[NSColor whiteColor] set];
	//	[NSBezierPath fillRect:rect];

	BOOL drawFast = ( [theAdinkra vertexCount] > 256 );
	
	[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		
	if ( !draggingVertex )
		[self removeAllToolTips];

	if ( theAdinkra ) {
	
		NSMutableArray *edgeColors = [NSMutableArray arrayWithCapacity: 33];
		int i;
		for ( i = 0; i <= 32; i++ ) {
			NSColor *theColor = [[NSUserDefaults standardUserDefaults] colorForKey: [NSString stringWithFormat: @"Q%iColor", i] ];
			if ( !theColor )
				theColor = [[NSColor blackColor] colorWithAlphaComponent: 0.5];
				
			[edgeColors addObject: theColor];
		}
		
		NSEnumerator *enumerator;
		
		[NSBezierPath setDefaultLineWidth: edgeThickness  ];
		
		float array[2];
		array[0] = 3*edgeThickness;
		array[1] = 3*edgeThickness;
		
		enumerator = [theAdinkra edgeEnumerator];
		Edge *edge;
		while ( edge = [enumerator nextObject] ) {
		//	[line setLineWidth: 3.0];
			
			if ( (!edgeSet || [edgeSet containsObject: [NSNumber numberWithInt: [edge Q] ] ] ) ) { //&&
				// !( ( [[edge from] location].y < NSMinY ( rect ) &&
			    //      [[edge to] location].y < NSMinY ( rect ) ) ||
				//    ( [[edge from] location].y > NSMaxY ( rect ) &&
			    //      [[edge to] location].y > NSMaxY ( rect ) ) ) ) {


NSShadow* theShadow;

if ( !drawFast ) {
	[NSGraphicsContext saveGraphicsState]; 
	 
	// Create the shadow below and to the right of the shape.
	theShadow = [[NSShadow alloc] init]; 
	[theShadow setShadowOffset:NSMakeSize(0.0, - edgeThickness / 2.0 )]; 
	[theShadow setShadowBlurRadius: edgeThickness]; 
	 
	// Use a partially transparent color for shapes that overlap.
	[theShadow setShadowColor:[[NSColor blackColor]
				 colorWithAlphaComponent:0.3]]; 
	 
	[theShadow set];
}

				[ [edgeColors objectAtIndex: [edge Q] ] set ];
				if ( !drawFast && [edge isNegative] ) {
					NSBezierPath *line = [NSBezierPath bezierPath];
					[line moveToPoint: [[edge from] location] ];
					[line lineToPoint: [[edge to] location] ];
					[line setLineDash: array count: 2 phase: 0.0];
					[line stroke];
				}
				else
					[NSBezierPath strokeLineFromPoint: [[edge from] location]
								  toPoint: [[edge to] location] ];

if ( !drawFast ) {
	[NSGraphicsContext restoreGraphicsState];
	[theShadow release]; 
}

			}
		}

//if ( !drawFast ) {		
	//	enumerator = [theAdinkra vertexEnumerator];
		Vertex *vertex;
		
		NSEnumerator *tagEnumerator = [theAdinkra tagEnumerator];
		id theTag;
		
	//	[NSBezierPath setDefaultLineWidth: 2.0];
		[[NSColor blackColor] set];
		
		while ( theTag = [tagEnumerator nextObject] ) {
			vertex = [ theAdinkra vertexWithTag: theTag ];
			
			NSPoint location = [vertex location];
			NSRect	theRect = NSMakeRect ( location.x - vertexRadius, location.y - vertexRadius, 2 * vertexRadius, 2 * vertexRadius );
			
		//	if ( NSIntersectsRect ( theRect, rect ) ) {
				NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect: theRect];
			//	[circle setLineWidth: 3.0];
			
NSShadow* theShadow;
				
if ( !drawFast ) {
	[NSGraphicsContext saveGraphicsState]; 
	 
	// Create the shadow below and to the right of the shape.
	theShadow = [[NSShadow alloc] init]; 
	[theShadow setShadowOffset:NSMakeSize(0.0, - edgeThickness)]; 
	[theShadow setShadowBlurRadius: edgeThickness]; 
	 
	// Use a partially transparent color for shapes that overlap.
	[theShadow setShadowColor:[[NSColor blackColor]
				 colorWithAlphaComponent:0.3]]; 
	 
	[theShadow set];
}
  
				if ( [vertex isFermion] ) {
					[circle fill];
				}
				else {
					[[NSColor whiteColor] set];
					[circle fill];
					[[NSColor blackColor] set];
				}
				
if ( !drawFast ) {
	[NSGraphicsContext restoreGraphicsState];
	[theShadow release];
}

				[circle stroke];
				
				if ( !draggingVertex && !drawFast ) {
					theRect = NSInsetRect ( theRect, - edgeThickness / 2, - edgeThickness / 2 );
					[self addToolTipRect: theRect owner: theTag userData: nil];
				}
		//	}
		}
//}

	}
}
*/

- (BOOL)isFlipped
{
	return YES;
}

- (BOOL)isOpaque
{
	return NO;
	
    // If the background color is opaque, return YES
    // otherwise, return NO
//    return [[self backgroundColor] alphaComponent] >= 1.0 ? YES : NO;
}

- (void)setFrame: (NSRect)rect
{
//	NSRect oldBounds = [self bounds];
	
	[super setFrame: rect];
	if ( fillWindow ) {
		[self locateVerticesWithAnimation: NO];
	//	[self setBounds: oldBounds];
	}
	else {
		[self setBounds: rect];
	}
}

- (void)resetCursorRects
{
	float vertexSize = vertexRadius + edgeThickness / 2.0;

	[self removeAllToolTips];
    [self discardCursorRects];
	
	BOOL shouldDrawFast = fillWindow && ( [theAdinkra vertexCount] > 256 );
	
	if ( !shouldDrawFast && ( vertexSize >= 1.0 ) ) {
		NSEnumerator *tagEnumerator = [theAdinkra tagEnumerator];
		id aTag;
		while ( aTag = [tagEnumerator nextObject] ) {
			Vertex *aVertex = [theAdinkra vertexWithTag: aTag];

			NSPoint location = [aVertex location];
			NSRect	theRect = NSMakeRect ( location.x - vertexSize, location.y - vertexSize, 2 * vertexSize, 2 * vertexSize );
			
			[self addToolTipRect: theRect owner: aTag userData: nil];
			[self addCursorRect: theRect cursor:[NSCursor openHandCursor]];
		}
	}
}

/*
+ (Class) cellClass
{
    return [NSActionCell class];
}
*/

#pragma mark My NSResponder Actions

- (IBAction)hangFromVertices:(id)sender
{
	if ( [selectedVertices count] ) {
		[self registerUndoActionName: @"Hang from Vertices"];
	
		[theAdinkra makeSourceVertices: selectedVertices];
		[theAdinkra setHorizontal];
		
		[self setAdinkra: theAdinkra ];
	}
}

- (IBAction)changeVertexSigns:(id)sender
{
	[self registerUndoActionName: @"Change Vertex Signs"];
	[selectedVertices makeObjectsPerformSelector: @selector(changeSign)];
	[self setNeedsDisplay: YES];
}

// JP - 3/2/11
// Toggles vertex visibility.
- (IBAction)toggleVertexVisibility:(id)sender
{
	[self registerUndoActionName: @"Change Vertex Visibility"];//Hide/Show?
	[selectedVertices makeObjectsPerformSelector: @selector(toggleVisibility)];
	[self setNeedsDisplay: YES];
}

// JP - 3/19/11
// Support to toggle hidden vertices visibilty.
-(IBAction) toggleHiddenVertexVisibility:(id)sender {
    showHiddenVertices = !showHiddenVertices;
    [self setNeedsDisplay: YES];
}

- (IBAction)makeValise:(id)sender
{
	[self registerUndoActionName: @"Pack into Valise" ];
	[self setAdinkra: [ [ [self adinkra] makeTwoDegreesWithLowestDegreeFermions: NO] setHorizontal ] ];
}

- (IBAction)kleinFlip:(id)sender
{
	[self registerUndoActionName: @"Klein Flip" ];
	[self setAdinkra: [ [self adinkra] kleinFlip ] ];
}

- (IBAction)edgeFlip:(id)sender
{
	[self registerUndoActionName: @"Edge Flip" ];
	[self setAdinkra: [ [self adinkra] edgeFlip: [sender tag] ] ];
}

- (IBAction)degreeFlip:(id)sender
{
	[self registerUndoActionName: @"Degree Flip" ];
	[self setAdinkra: [ [self adinkra] degreeFlip ] ];
}

- (IBAction)balanceHorizontally:(id)sender
{
	[self registerUndoActionName: @"Balance Rows" ];
	[self setAdinkra: [ [self adinkra] setHorizontal ] ];
}

#pragma mark NSResponder Actions

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (IBAction)copy:(id)sender
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard declareTypes:[NSArray arrayWithObjects: NSPDFPboardType, NSPostScriptPboardType, nil] owner:self];		

//	[pasteboard setData: [self dataWithPDFInsideRect:[self shrinkWrappedBounds]] forType: NSPDFPboardType];

	[self writePDFInsideRect:[self shrinkWrappedBounds] toPasteboard:pasteboard ];
	[self writeEPSInsideRect:[self shrinkWrappedBounds] toPasteboard:pasteboard ];
}

-(void)mouseDown:(NSEvent *)event
{
    NSPoint clickLocation;
    
    // convert the click location into the view coords
    clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    
    // did the click occur in a vertex
	draggingVertex = [self vertexHit:clickLocation];
    
	if ( !draggingVertex && [selectedVertices count] ) {
		[selectedVertices removeAllObjects];
		[self setNeedsDisplay: YES];
	}
	
	if ( [event clickCount] == 2 ) {
		
		if ( [selectedVertices containsObject: draggingVertex] ) {
			
			[self changeVertexSigns: self];
		//	[self registerUndoActionName: @"Change Vertex Signs"];
		//	[selectedVertices makeObjectsPerformSelector: @selector(changeSign)];
		//	[self setNeedsDisplay: YES];
		}
		draggingVertex = nil;
	}

	if ( draggingVertex ) {
		
		unsigned int modifierFlags = [ event modifierFlags ];
		
		if ( ( modifierFlags & NSShiftKeyMask )  || ( modifierFlags & NSCommandKeyMask ) )
			if ( [ selectedVertices containsObject: draggingVertex ] )
				[selectedVertices removeObject: draggingVertex];
			else
				[selectedVertices addObject: draggingVertex];
		else {
			[ selectedVertices removeAllObjects ];
			[ selectedVertices addObject: draggingVertex ];
		}

		//	lastDragLocation=clickLocation;
		
			// set the cursor to the closed hand cursor
			// for the duration of the drag
			[[NSCursor closedHandCursor] push];
			[self setNeedsDisplay:YES];
    }
}

-(void)mouseDragged:(NSEvent *)event
{
    if (draggingVertex) {
		[self autoscroll:event];
		
		NSPoint newDragLocation=[self convertPoint:[event locationInWindow]
						  fromView:nil];

		// should put this in its own function
		if ( newDragLocation.x < NSMinX(draggingBounds) )
			newDragLocation.x = NSMinX(draggingBounds);
		if ( newDragLocation.y < NSMinY(draggingBounds) )
			newDragLocation.y = NSMinY(draggingBounds);
		if ( newDragLocation.x > NSMaxX(draggingBounds) )
			newDragLocation.x = NSMaxX(draggingBounds);
		if ( newDragLocation.y > NSMaxY(draggingBounds) )
			newDragLocation.y = NSMaxY(draggingBounds);
					
		[draggingVertex setLocation: newDragLocation];
		[self setNeedsDisplayInRect:updateBounds];

	/*
		
		// offset the pill by the change in mouse movement
		// in the event
		[self offsetLocationByX:(newDragLocation.x-lastDragLocation.x)
				   andY:(newDragLocation.y-lastDragLocation.y)];
	*/	
		// save the new drag location for the next drag event
	//	lastDragLocation=newDragLocation;
		
		// support automatic scrolling during a drag
		// by calling NSView's autoscroll: method
	//	[self autoscroll:event];
    }
}

-(void)mouseUp:(NSEvent *)event
{   
	if ( draggingVertex ) {
		Boolean changed = NO;
		
		// finished dragging, restore the cursor
		[NSCursor pop];
		
		// the item has moved, we need to reset our cursor
		// rectangle
		[[self window] invalidateCursorRectsForView:self];

		NSPoint location = [draggingVertex location];
		
		int newHorizontal, newDegree;
		
		if ( location.x >= 0 )
			newHorizontal = ( location.x + scale.width / 2 ) / scale.width;
		else
			newHorizontal = - ( ( -location.x + scale.width / 2 ) / scale.width );
		
		newDegree = [draggingVertex degree];
		
		NSUndoManager *undoManager = [ self undoManager ];

		if ( [draggingVertex horizontal] != newHorizontal ) {
			changed = YES;
			[ undoManager setActionName: @"Move Vertex" ];
		}
		
		int oldDegree = [draggingVertex degree];

		if ( ( location.y ) / scale.height > ( oldDegree + 1.0 ) ) {
			newDegree = oldDegree + 2;
			changed = YES;
			[ undoManager setActionName: @"Lower Vertex" ];
		}
		else if ( ( location.y ) / scale.height < ( oldDegree - 1.0 ) ) {
			newDegree = oldDegree - 2;
			changed = YES;
			[ undoManager setActionName: @"Raise Vertex" ];
		}

		if ( changed ) {
			[ self moveVertexUsingDictionary: [ NSDictionary dictionaryWithObjectsAndKeys:
				draggingVertex, @"vertex",
				[NSNumber numberWithInt: newDegree], @"degree",
				[NSNumber numberWithInt: newHorizontal], @"horizontal",
				nil ] ];
		}		
		else {
			NSPoint newLocation = 
			NSMakePoint ( [draggingVertex horizontal] * scale.width,
						  [draggingVertex degree] * scale.height );
			[draggingVertex setLocation: newLocation];
			[self setNeedsDisplay: YES];
		}

		draggingVertex = nil;
											  
	/*
		float i;
		for ( i = 0.2; i < 1.0; i += 0.2 ) {
			NSPoint midLocation = NSMakePoint ( location.x * (1-i) + newLocation.x * i,
												location.y * (1-i) + newLocation.y * i );
			[draggingVertex setLocation: midLocation];
			[self displayRect:updateBounds];
		}
	

		draggingVertex = nil;
		
	//	[self displayRect:updateBounds];	

		[self setNeedsDisplay: YES];
		
	//	[self setNeedsDisplayInRect: updateBounds];
		
		if ( changed ) {
			[self locateVerticesWithAnimation: YES];
			[self sendAction:[self action] to:[self target] ];
		}
	*/
	}
}

#pragma mark AdinkraView Methods

- (void)cachePaths
{
	[solidEdgePaths release];
	[dashedEdgePaths release];
	[blackVertexFillPath release];
	[whiteVertexFillPath release];
	[vertexStrokePath release];

	solidEdgePaths = [ [NSMutableArray arrayWithCapacity:32] retain ];
	dashedEdgePaths = [ [NSMutableArray arrayWithCapacity:32] retain ];
	
	int i;
	
	for ( i = 0; i < 32; i++ ) {
		[solidEdgePaths addObject: [NSBezierPath bezierPath] ];
		[dashedEdgePaths addObject: [NSBezierPath bezierPath] ];
	}
	
	blackVertexFillPath = [ [NSBezierPath bezierPath] retain ];
	whiteVertexFillPath = [ [NSBezierPath bezierPath] retain ];
	vertexStrokePath = [ [NSBezierPath bezierPath] retain];
	
	NSEnumerator *edgeEnumerator = [theAdinkra edgeEnumerator];
	Edge *anEdge;
	while ( anEdge = [edgeEnumerator nextObject] ) {
		NSBezierPath *edgeQPath = [ ( [anEdge isNegative] ? dashedEdgePaths : solidEdgePaths ) objectAtIndex: ( [anEdge Q] - 1 ) ];
		[edgeQPath moveToPoint: [[anEdge from] location]];
		[edgeQPath lineToPoint: [[anEdge to] location]];
	}

	NSEnumerator *vertexEnumerator = [theAdinkra vertexEnumerator];
	Vertex *aVertex;
	while ( aVertex = [vertexEnumerator nextObject] ) {
		NSPoint location = [aVertex location];
		NSRect	vertexRect = NSMakeRect ( location.x - vertexRadius, location.y - vertexRadius, 2 * vertexRadius, 2 * vertexRadius );

		NSBezierPath *vertexFillPath = [aVertex isFermion] ? blackVertexFillPath : whiteVertexFillPath;
		
		[vertexFillPath appendBezierPathWithOvalInRect:vertexRect];
		[vertexStrokePath appendBezierPathWithOvalInRect:vertexRect];
	}
}

- (void)locateVerticesWithAnimation: (BOOL)animate
{	
	int max, min, maxHorizontal, minHorizontal;	
	[theAdinkra maxDegree: &max minDegree: &min maxHorizontal:&maxHorizontal minHorizontal: &minHorizontal];
	
	NSRect theRect;
	
	if ( fillWindow ) {
		theRect = [self bounds];
		scale = NSMakeSize ( ( theRect.size.width - 40.0 ) / ( maxHorizontal - minHorizontal + 2 ),
							 ( theRect.size.height - 50.0 ) / ( max - min + 2 ) );
		theRect.origin = NSMakePoint ( ( minHorizontal - 1.0 ) * scale.width - 20.0,
									  ( min - 1.0 ) * scale.height - 25.0 );
	}
	else {
		scale = NSMakeSize ( vertexSpacing / 2, vertexSpacing );
		theRect = NSMakeRect ( ( minHorizontal - 1.0 ) * scale.width - 20.0,
								  ( min - 1.0 ) * scale.height - 25.0,
								  ( maxHorizontal - minHorizontal + 2.0 ) * scale.width + 40.0, 
								  ( max - min + 2.0) * scale.height + 50.0 );
	}
							
	NSEnumerator *enumerator = [theAdinkra vertexEnumerator];
	Vertex *vertex;
	
	while ( vertex = [enumerator nextObject] ) {
		[vertex setLocation: NSMakePoint ( [vertex horizontal] * scale.width,
										   [vertex degree] * scale.height ) ];
	}
	
	[[self window] invalidateCursorRectsForView:self];
	
	if ( fillWindow ) {
		[self setBounds:theRect];
		[self setNeedsDisplay: YES];
	}
	else {
		if ( animate ) {
			// firstView, secondView are outlets
			NSViewAnimation *theAnim;
			NSMutableDictionary* viewDict;
		 
			// Create the attributes dictionary for the first view.
			viewDict = [NSMutableDictionary dictionaryWithCapacity:2];

			// Specify which view to modify.
			[viewDict setObject:self forKey:NSViewAnimationTargetKey];

			// Change the ending position of the view.
			[viewDict setObject:[NSValue valueWithRect:theRect] 
					 forKey:NSViewAnimationEndFrameKey]; 
		  
			// Create the view animation object.
			theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray
						arrayWithObject:viewDict]];
		 
			// Set some additional attributes for the animation.
			[theAnim setDuration:0.5];    // in seconds second. 
			[theAnim setAnimationCurve:NSAnimationLinear];
		 
			// Run the animation.
			[theAnim startAnimation];
		 
			// The animation has finished, so go ahead and release it. 
			[theAnim release];
		}
		else
			[self setFrame: theRect];
	}
}

- (NSRect)shrinkWrappedBounds
{
	return NSInsetRect ( [self bounds], scale.width, scale.height );
}

- (Vertex *)vertexHit: (NSPoint)testPoint
{
	float vertexSize = vertexRadius + edgeThickness;
	
	NSEnumerator *enumerator = [theAdinkra vertexEnumerator];
	Vertex *vertex;
	while ( vertex = [enumerator nextObject] ) {
		NSPoint location = [vertex location];
		NSRect	theRect = NSMakeRect ( location.x - vertexSize, location.y - vertexSize, 2 * vertexSize, 2 * vertexSize );
		if ( NSPointInRect ( testPoint, theRect ) ) {
			draggingBounds = [self bounds];
			draggingBounds = NSInsetRect ( draggingBounds, 20.0, 25.0 );
			
			updateBounds = [self bounds];
			if ( [vertex isSink] ) {
				draggingBounds.origin.y = location.y;
				draggingBounds.size.height = 2 * scale.height;
				updateBounds = NSInsetRect ( draggingBounds, -20.0, - 25.0 );				
			}
			else if ( [vertex isSource] ) {
				draggingBounds.origin.y = location.y - 2 * scale.height;
				draggingBounds.size.height = 2 * scale.height;
				updateBounds = NSInsetRect ( draggingBounds, -20.0, - 25.0 );				
			}
			else {
				draggingBounds.origin.y = location.y;
				draggingBounds.size.height = 0;
				updateBounds = NSInsetRect ( draggingBounds, -20.0, - 25.0 - scale.height );
			}
			return vertex;
		}
	}
	return nil;
}

#pragma mark Key-Value Observing

- (void)observeValueForKeyPath:keyPath ofObject: object change:change context: context
{
	float newEdgeThickness = [[NSUserDefaults standardUserDefaults] floatForKey: @"edgeThickness" ];
	float newVertexRadius = [[NSUserDefaults standardUserDefaults] floatForKey: @"vertexRadius" ];
	float newVertexSpacing = [[NSUserDefaults standardUserDefaults] floatForKey: @"vertexSpacing" ];
	BOOL  newDrawShadow = [[NSUserDefaults standardUserDefaults] boolForKey: @"drawShadow" ];
	
	vertexRadius = newVertexRadius;
	edgeThickness = newEdgeThickness;
	if ( newVertexSpacing != vertexSpacing ) {
		vertexSpacing = newVertexSpacing;
		[self locateVerticesWithAnimation: NO];
	}
	drawShadow = newDrawShadow;
	
	[self setNeedsDisplay:YES];
}

#pragma mark AdinkraView Accessors

- (Adinkra *)adinkra
{
	return theAdinkra;
}

- (void)setAdinkra: (Adinkra *)adinkra
{
	[selectedVertices removeAllObjects];
	
	if ( theAdinkra ) {
		[theAdinkra autorelease];
		
		if ( theAdinkra != adinkra )
			[ [ self undoManager ] registerUndoWithTarget: self
												 selector: @selector(setAdinkra:)
												   object: theAdinkra ];
			
	}

	theAdinkra = [adinkra retain];

	[self locateVerticesWithAnimation: NO];

	[self setNeedsDisplay: YES];

	[self scrollPoint: NSMakePoint ( - edgeThickness - vertexRadius - vertexSpacing / 2, - edgeThickness - vertexRadius - vertexSpacing ) ];
}

- (void)setEdgeSet: (NSSet *)set
{
	if ( edgeSet )
		[edgeSet autorelease];
	
	edgeSet = [set retain];
	
	[self setNeedsDisplay: YES];
}

- (void)setFillWindow: (BOOL)newFillWindow
{
	fillWindow = newFillWindow;
}

- (BOOL)doesFillWindow
{
	return fillWindow;
}

- (void)setDrawDashedEdges: (BOOL)newDrawDashedEdges
{
	drawDashedEdges = newDrawDashedEdges;
	[self setNeedsDisplay: YES];
}

- (BOOL)doesDrawDashedEdges
{
	return drawDashedEdges;
}

// -----------------------------------
// Modify the item location 
// -----------------------------------

/*
- (void)offsetLocationByX:(float)x andY:(float)y
{
    // tell the display to redraw the old rect
    [self setNeedsDisplayInRect:[self calculatedItemBounds]];

    // since the offset can be generated by both mouse moves
    // and moveUp:, moveDown:, etc.. actions, we'll invert
    // the deltaY amount based on if the view is flipped or 
    // not.
    int invertDeltaY = [self isFlipped] ? -1: 1;
    
    location.x=location.x+x;
    location.y=location.y+y*invertDeltaY;
    
    // invalidate the new rect location so that it'll
    // be redrawn
    [self setNeedsDisplayInRect:[self calculatedItemBounds]];
    
}
*/

#pragma mark AdinkraView Undo Methods

- (void)moveVertexUsingDictionary: (NSDictionary *)dictionary
{
	NSUndoManager *undoManager = [ self undoManager ];
	
	Vertex *vertex = [ dictionary objectForKey:@"vertex" ];
	int	newDegree = [ [ dictionary objectForKey:@"degree"] intValue];
	int newHorizontal = [ [ dictionary objectForKey:@"horizontal"] intValue];
	
	int oldDegree = [ vertex degree ];
	int oldHorizontal = [ vertex horizontal ];
	
	[ vertex setDegree: newDegree ];
	[ vertex setHorizontal: newHorizontal ];
	
	[ self locateVerticesWithAnimation: YES];
	
	[ undoManager registerUndoWithTarget: self
								selector:@selector(moveVertexUsingDictionary:)
								  object: [ NSDictionary dictionaryWithObjectsAndKeys:
				vertex, @"vertex",
				[NSNumber numberWithInt: oldDegree], @"degree",
				[NSNumber numberWithInt: oldHorizontal], @"horizontal",
				nil ] ];
}

- (void)registerUndoActionName: (NSString *)actionName
{
	[ [ self undoManager ] registerUndoWithTarget: self
										 selector: @selector(setAdinkra:)
										   object: [Adinkra adinkraWithDictionary: [theAdinkra dictionary ] ] ];
	[ [ self undoManager ] setActionName: actionName ];
}


// -----------------------------------
// Handle KeyDown Events 
// -----------------------------------

/*
- (void)keyDown:(NSEvent *)event
{
    BOOL handled = NO;
    NSString  *characters;
    
    // get the pressed key
    characters = [event charactersIgnoringModifiers];
    
    // is the "r" key pressed?
    if ([characters isEqual:@"r"]) {
	// Yes, it is
	handled = YES;
	
	// set the rectangle properties
	[self setItemPropertiesToDefault:self];
    }
    if (!handled)
	[super keyDown:event];
    
}
*/

// -----------------------------------
// Handle NSResponder Actions 
// -----------------------------------

/*
-(IBAction)moveUp:(id)sender
{
    [self offsetLocationByX:0 andY: 10.0];
    [[self window] invalidateCursorRectsForView:self];
}

-(IBAction)moveDown:(id)sender
{
    [self offsetLocationByX:0 andY:-10.0];
    [[self window] invalidateCursorRectsForView:self];
}

-(IBAction)moveLeft:(id)sender
{
    [self offsetLocationByX:-10.0 andY:0.0];
    [[self window] invalidateCursorRectsForView:self];
}

-(IBAction)moveRight:(id)sender
{
    [self offsetLocationByX:10.0 andY:0.0];
    [[self window] invalidateCursorRectsForView:self];
}

- (IBAction)setItemPropertiesToDefault:(id)sender
{
    [self setLocation:NSMakePoint(0.0,0.0)];
    [self setItemColor:[NSColor redColor]];
    [self setBackgroundColor:[NSColor whiteColor]];
}
*/

// -----------------------------------
// Handle color changes via first responder 
// -----------------------------------

/*
- (void)changeColor:(id)sender
{
    // Set the color in response
    // to the color changing in the color panel.
    // get the new color by asking the sender, the color panel
    [self setItemColor:[sender color]];
}
*/



// -----------------------------------
// Reset Cursor Rects 
// -----------------------------------

/*
-(void)resetCursorRects
{
    // remove the existing cursor rects
    [self discardCursorRects];
    
    // add the draggable item's bounds as a cursor rect
    [self addCursorRect:[self calculatedItemBounds] cursor:[NSCursor openHandCursor]];
    
}
*/

// -----------------------------------
//  Accessor Methods
// -----------------------------------

/*
- (void)setItemColor:(NSColor *)aColor
{
	if (![itemColor isEqual:aColor]) {
        [itemColor release];
        itemColor = [aColor retain];
		
		// if the colors are not equal, mark the
		// draggable rect as needing display
        [self setNeedsDisplayInRect:[self calculatedItemBounds]];
    }
}
*/

/*
- (NSColor *)itemColor
{
    return [[itemColor retain] autorelease];
}
*/

/*
- (void)setBackgroundColor:(NSColor *)aColor
{
	if (![backgroundColor isEqual:aColor]) {
        [backgroundColor release];
        backgroundColor = [aColor retain];
		
		// if the colors are not equal, mark the
		// draggable rect as needing display
        [self setNeedsDisplayInRect:[self calculatedItemBounds]];
    }
}
*/

/*
- (NSColor *)backgroundColor
{
    return [[backgroundColor retain] autorelease];
}
*/

/*
- (void)setLocation:(NSPoint)point
{
    // test to see if the point actually changed
    if (!NSEqualPoints(point,location)) {
        // tell the display to redraw the old rect
	[self setNeedsDisplayInRect:[self calculatedItemBounds]];
	
        // reassign the rect
	location=point;
	
        // display the new rect
	[self setNeedsDisplayInRect:[self calculatedItemBounds]];
	
        // invalidate the cursor rects 
	[[self window] invalidateCursorRectsForView:self];
    }
}
*/

/*
- (NSPoint)location {
    return location;
}
*/

/*
- (NSRect)calculatedItemBounds
{
    NSRect calculatedRect;
    
    // calculate the bounds of the draggable item
    // relative to the location
    calculatedRect.origin=location;
    
    // the example assumes that the width and height
    // are fixed values
    calculatedRect.size.width=60.0;
    calculatedRect.size.height=20.0;
    
    return calculatedRect;
}
*/




@end
