//
//  AdinkraDocument.m
//  Adinkramatic
//
//  Created by Greg Landweber on 8/11/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import "AdinkraDocument.h"
#import "Adinkra+Clifford.h"
#import "Adinkra+Extension.h"
#import "AdinkramatAppDelegate.h"
#import "Clifford.h"

@implementation AdinkraDocument

#pragma mark NSObject Methods

- (id)init
{
    self = [super init];
    if (self) {
		theAdinkra = nil;
		showEdges = nil;
		edgeSet = nil;
		N = 0;
		drawDashedEdges = YES;
		awake = NO;
		cancelled = NO;
        autoCheckExtension = NO;
		pool = nil;
        
        // Establish collapsed bindings
    }
    return self;
}

- (void)dealloc
{
	[pool release];
	
	[edgeSet release];
	[super dealloc];
}

#pragma mark NSNibAwakening Protocol

- (void)awakeFromNib
{
	if ( theAdinkra ) {
		[adinkraView setAdinkra: theAdinkra];
		[theAdinkra release];
		theAdinkra = nil;
	
		if ( showEdges ) {
			NSMutableSet *newEdgeSet = [NSMutableSet setWithCapacity:32];
			int i;
			for (i = 1; i <= 32; i++ )
				if ( [ [showEdges objectAtIndex: i-1] boolValue ] )
					[newEdgeSet addObject: [NSNumber numberWithInt: i ] ];
			
			[self setEdgeSet: newEdgeSet];
			
			[showEdges release];
			showEdges = nil;
		}
		
		[edgeMax setIntValue: N];
		[edgeStepper setMaxValue: N];
		[edgeStepper setIntValue: N];
		
		[oneEdge setIntValue: 1];
		[oneEdgeStepper setMaxValue: N];
		[oneEdgeStepper setIntValue: 1];
		
		[dashedEdgesButton setIntValue: drawDashedEdges];
		[adinkraView setDrawDashedEdges: drawDashedEdges];
        
        // Enable inspector.
        [ self enableView:inspectorView ];

		if ( !awake ) {
			awake = YES;
			if ( N > 8 )
				[adinkraView setFillWindow: YES];
            // else autoCheckExtension = YES;
			[self resizeWindowToAdinkra];
		}
	}
}

#pragma mark NSDocument Methods

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"AdinkraDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}
 
/* Deprecated
- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use the new Tiger API -dataOfType:error:.  In this case you can also choose to override -writeToURL:ofType:error:, -fileWrapperOfType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    return nil;
}
*/

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if ( [typeName isEqualToString: @"Adinkra" ] ) {
		Adinkra *anAdinkra = [adinkraView adinkra];
		
		if ( anAdinkra ) {
			NSMutableDictionary *theDictionary = [ self generateDictionaryFromAdinkra:anAdinkra ];
			
			BOOL success = [theDictionary writeToURL:absoluteURL atomically: YES];
			if ( !success )
				*outError = [NSError errorWithDomain: @"com.cohomology.Adinkramat.ErrorDomain"
									 code: 0
									 userInfo: nil];
			return success;
		}
		else {
			*outError = [NSError errorWithDomain: @"com.cohomology.Adinkramat.ErrorDomain"
								 code: 0
								 userInfo: nil];
			return NO;
		}
	}
	
	if ( [typeName isEqualToString: @"EPS" ] ) {
		NSData *data = [adinkraView dataWithEPSInsideRect:[adinkraView shrinkWrappedBounds]];
		return [data writeToURL:absoluteURL options:NSAtomicWrite error:outError];
	}

	if ( [typeName isEqualToString: @"PDF" ] ) {
		NSData *data = [adinkraView dataWithPDFInsideRect:[adinkraView shrinkWrappedBounds]];
		return [data writeToURL:absoluteURL options:NSAtomicWrite error:outError];
	}
	
	*outError = [NSError errorWithDomain: @"com.cohomology.Adinkramat.ErrorDomain"
						 code: 0
						 userInfo: nil];
	return NO;
}

/* Deprecated
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use the new Tiger API readFromData:ofType:error:.  In this case you can also choose to override -readFromURL:ofType:error: or -readFromFileWrapper:ofType:error: instead.
    
    return YES;
}
*/

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL: absoluteURL];
	
	return [ self createAdinkraWithDictionary:dictionary error:outError ];
}

// JP - 2/27/2011
// Migrated adinkra creation from 'readFromURL:ofType:error:' to support duplicating adinkras.
- (BOOL)createAdinkraWithDictionary:(NSDictionary *)dictionary error:(NSError **)outError {
	if ( dictionary ) {
		theAdinkra = [[Adinkra adinkraWithDictionary: dictionary] retain];
		
		N = [[dictionary objectForKey: @"N"] intValue];
		
		if ( [dictionary objectForKey: @"showEdges"] )
			showEdges = [[dictionary objectForKey: @"showEdges"] retain];
		else {
			showEdges = [[NSMutableArray arrayWithCapacity:32] retain];
			int i;
			for (i = 1; i <= 32; i++ )
				[showEdges addObject: [NSNumber numberWithBool: i <= N]];
		}
		
		if ( [dictionary objectForKey: @"drawDashedEdges"] )
			drawDashedEdges = [[dictionary objectForKey: @"drawDashedEdges"] boolValue];
		else
			drawDashedEdges = (N > 8) ? NO : YES;
		
		if ( theAdinkra ) {
			if ( adinkraView )
				[self awakeFromNib]; // update values in adinkraView
			return YES;
		}
		else {
			*outError = [NSError errorWithDomain: @"com.cohomology.Adinkramat.ErrorDomain"
											code: 0
										userInfo: nil];
			return NO;
		}
	}
	else {
		*outError = [NSError errorWithDomain: @"com.cohomology.Adinkramat.ErrorDomain"
										code: 0
									userInfo: nil];
		return NO;
	}
}

// JP - 2/27/2011
// Migrated dictionary creation from 'writeToURL:ofType:error:' to support duplicating adinkras.
- (NSMutableDictionary *) generateDictionaryFromAdinkra:(Adinkra *)anAdinkra {
	NSMutableDictionary *theDictionary = [[anAdinkra dictionary] mutableCopy];
	[theDictionary setObject:[NSNumber numberWithInt: N] forKey:@"N" ];
	[theDictionary setObject:[NSNumber numberWithBool: [dashedEdgesButton intValue]] forKey:@"drawDashedEdges"];
	
	{
		NSMutableArray *showEdgeArray = [NSMutableArray arrayWithCapacity:32];
		int i;
		
		for (i = 1; i <= 32; i++ )
			[showEdgeArray addObject: [NSNumber numberWithBool: [[edgeMatrix cellWithTag:i] intValue]]];
		
		[theDictionary setObject: showEdgeArray forKey: @"showEdges"];
	}
	
	return [ theDictionary autorelease ];
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
	NSPrintInfo *printInfo = [self printInfo];
	[printInfo setHorizontalPagination: NSFitPagination];
	[printInfo setVerticalPagination: NSFitPagination];
	
	return [ NSPrintOperation printOperationWithView: adinkraView ];
}

- (void)showWindows
{
	[super showWindows];
	
	if ( ![adinkraView adinkra] )
		[self new:self];
}

#pragma mark NSMenuValidation Protocol

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	if ( [menuItem action] == @selector(scaleToWindow:) ) {
		if ( [adinkraView doesFillWindow] )
			[menuItem setState: NSOnState];
		else
			[menuItem setState: NSOffState];
	}
    /*
    else if ( [ menuItem action ] == @selector(toggleExtension:)){
        if ( autoCheckExtension)
            [ menuItem setState:NSOnState ];
        else
            [ menuItem setState:NSOffState ];
    }
     */
#if DRAWER
	if ( [menuItem action] == @selector(toggleEdgeDrawer:) ) {
		if ( [edgeDrawer state] == NSDrawerOpenState || [edgeDrawer state] == NSDrawerOpeningState )
			[menuItem setTitle: @"Hide Edge Drawer"];
		else
			[menuItem setTitle: @"Show Edge Drawer"];
	}
#endif

	return true;
}

#pragma mark My NSResponder Actions

- (IBAction)scaleToWindow:(id)sender
{
	[adinkraView setFillWindow: ![adinkraView doesFillWindow] ];
	
	if ( [adinkraView doesFillWindow] )
		[self windowDidResize:nil];
	else {
		[adinkraView setFrame: [adinkraView bounds] ];
		[adinkraView locateVerticesWithAnimation: NO];
	}
	
	[adinkraView setNeedsDisplay: TRUE];
}
#if DRAWER
- (IBAction)toggleEdgeDrawer:(id)sender
{
	[edgeDrawer toggle:self];
}
#endif

/*
#pragma mark AdinkraDocument Actions
- (IBAction)setTempsss:(id)sender {
    //[NSAnimationContext beginGrouping];
    //[[NSAnimationContext currentContext] setDuration:5.0f];
    [[ temp animator ] setBrightness:.1 ];
    //[NSAnimationContext endGrouping];
}
*/

- (IBAction)allEdgesUpToN:(id)sender
{
	if ( sender ) {
		[edgeMax takeIntValueFrom: sender];
		[edgeStepper takeIntValueFrom: sender];
	}
	
	int max = [edgeMax intValue];
	
	int i;

	for (i = 1; i <= 32; i++ ) {
		NSButton *theButton = [edgeMatrix cellWithTag:i];
		[theButton setIntValue: i <= max ? YES : NO];
	}
	
	[self showEdges: self];
}

- (IBAction)oneEdge:(id)sender
{
	if ( sender ) {
		[oneEdge takeIntValueFrom: sender];
		[oneEdgeStepper takeIntValueFrom: sender];
	}
	
	int Q = [oneEdge intValue];
	
	int i;

	for (i = 1; i <= 32; i++ ) {
		NSButton *theButton = [edgeMatrix cellWithTag:i];
		[theButton setIntValue: i == Q ? YES : NO];
	}
	
	[self showEdges: self];
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:adinkraSheet];
	[adinkraSheet orderOut: self];

	if ( [OKButton isEnabled] )
		[self close];
	else
		cancelled = YES;
}

- (IBAction)new:(id)sender
{
	[NSApp beginSheet:adinkraSheet
		   modalForWindow:[self windowForSheet]
		   modalDelegate:nil
		   didEndSelector:nil
		   contextInfo:nil];
}


- (IBAction)OK:(id)sender
{	
	N = [NField intValue];
	adinkraTypeCode = [[adinkraType objectValue] intValue];
	isValise = [[extendedValise objectValue] intValue];
	
	[OKButton setEnabled: NO];
	[NField setEnabled: NO];
	[adinkraType setEnabled: NO];
	
	[adinkraProgress setDoubleValue: 0.0];
	[adinkraString setStringValue: @""];
	
	float deltaHeight = [adinkraSheet maxSize].height - [adinkraSheet minSize].height;
	
	NSRect oldFrame, newFrame;
	oldFrame = newFrame = [adinkraSheet frame];	
	newFrame.size.height += deltaHeight;
	newFrame.origin.y -= deltaHeight;
	[[adinkraSheet contentView] setBoundsOrigin: NSMakePoint ( 0.0, -deltaHeight ) ];
	[adinkraSheet setFrame: newFrame display: YES animate:YES];
	
	[edgeMax setIntValue: N];
	[edgeStepper setMaxValue: N];
	[edgeStepper setIntValue: N];
	
	[oneEdge setIntValue: 1];
	[oneEdgeStepper setMaxValue: N];
	[oneEdgeStepper setIntValue: 1];

	[self allEdgesUpToN:nil];
	
	[dashedEdgesButton setIntValue: (N > 8) ? 0 : 1];
	[adinkraView setDrawDashedEdges: (N > 8) ? NO : YES];
	
	[self detatchAdinkraConstructionThread];
}

- (IBAction)showEdges:(id)sender
{
	NSMutableSet *newEdgeSet = [NSMutableSet setWithCapacity:32];
	
	int i;
	
	for (i = 1; i <= 32; i++ ) {
		NSButton *theButton = [edgeMatrix cellWithTag:i];
		if ( [theButton intValue] )
			[newEdgeSet addObject: [NSNumber numberWithInt: i]];
	}
	
	[self setEdgeSet: newEdgeSet];
}

- (IBAction)dashedEdges:(id)sender
{
	BOOL newDrawDashedEdges = [dashedEdgesButton intValue];
	[self setDrawDashedEdges: [NSNumber numberWithBool: newDrawDashedEdges]];
	[[self undoManager] setActionName: newDrawDashedEdges ? @"Switch On Dashed Edges"
						 								  : @"Switch Off Dashed Edges" ];
}

#pragma mark AdinkraDocument Undo Methods

- (void)setDrawDashedEdges: (NSNumber *)drawDashedEdgesObject
{
	BOOL oldDrawDashedEdges = [adinkraView doesDrawDashedEdges];
	BOOL newDrawDashedEdges = [drawDashedEdgesObject boolValue];
	
	if ( oldDrawDashedEdges != newDrawDashedEdges ) {
		[dashedEdgesButton setIntValue:newDrawDashedEdges];
		[adinkraView setDrawDashedEdges: newDrawDashedEdges];

		[[self undoManager] registerUndoWithTarget: self
										  selector: @selector(setDrawDashedEdges:)
											object: [NSNumber numberWithBool: oldDrawDashedEdges] ];
	}
}

- (void)setEdgeSet: (NSSet *)newEdgeSet
{
	if ( [newEdgeSet isEqual: edgeSet ] )
		return;
		
	NSUndoManager *undoManager = [self undoManager];
	
	if ( edgeSet ) {
		[undoManager registerUndoWithTarget: self
								   selector: @selector(setEdgeSet:)
									 object: edgeSet];
		[ undoManager setActionName: @"Change Shown Edges" ];
	}
	
	[edgeSet autorelease];
	edgeSet = [newEdgeSet retain];
	
	int i;
	for ( i = 1; i <= 32; i++ ) {
		NSButton *theButton = [edgeMatrix cellWithTag:i];
		[theButton setIntValue: [edgeSet containsObject: [NSNumber numberWithInt: i] ] ];
	}
	
	[adinkraView setEdgeSet: edgeSet];
}

#pragma mark AdinkraDocument Methods

- (void)resizeWindowToAdinkra
{	
	Adinkra *anAdinkra = [adinkraView adinkra];
	
	if ( anAdinkra ) {
		NSWindow *window = [adinkraView window];

		NSRect oldFrameRect, newFrameRect, screenRect;
		
		oldFrameRect = [window frame];
		newFrameRect = [window frameRectForContentRect: [adinkraView bounds]];
		screenRect = [[window screen] frame];
		
		newFrameRect.origin = NSMakePoint ( NSMinX ( oldFrameRect ), NSMaxY ( oldFrameRect ) - newFrameRect.size.height );
		
		if ( NSMaxX ( newFrameRect ) > NSMaxX ( screenRect ) )
			newFrameRect.size.width = NSMaxX ( screenRect ) - NSMinX ( newFrameRect );
		if ( NSMinY ( newFrameRect ) < NSMinY ( screenRect ) ) {
			newFrameRect.size.height = NSMaxY ( newFrameRect ) - NSMinY ( screenRect );
			newFrameRect.origin.y = NSMinY ( screenRect );
		}
		
		[ window setFrame: newFrameRect display: YES animate: [anAdinkra vertexCount] <= 256 ];
	}
}

#pragma mark ShowsProgress Protocol

- (void) setProgressValue: (unsigned long)value maxValue: (unsigned long)max message: (NSString *)aString
{
	[self performSelectorOnMainThread:@selector(showProgress:)
						   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithUnsignedLong:max], @"max",
										[NSNumber numberWithUnsignedLong:value], @"value",
										aString, @"string",
										nil]
						waitUntilDone:NO ];
												
	if ( cancelled ) {
		[pool release];
		[NSThread exit];
	}	
}

#pragma mark Inspector Methods

// JP - 6/30/11
// Inspector methods. Referenced "http://www.borkware.com/rants/inspectors/".
- (void) postNotification: (NSString *) notificationName {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: self];
}

-(void) enableView:(NSView *) view {
    for ( NSView *subView in [ view subviews ]) {
        if( [subView respondsToSelector:@selector(setEnabled:)] )
            [(NSControl*)subView setEnabled:YES];
        
        [ self enableView:subView ];
        //[ subView display ];
    }
}

#pragma mark NSWindow Delegate Methods


// JP - 6/30/11
- (void) windowDidBecomeMain: (NSNotification *) notification {
    [self postNotification: AdinkraDocument_DocumentActivateNotification];
    
}

// JP - 6/30/11
- (void) windowDidResignMain: (NSNotification *) notification {
    [self postNotification: AdinkraDocument_DocumentDeactivateNotification];
    
}

// JP - 6/30/11
- (void) windowWillClose: (NSNotification *) notification {
    [self postNotification: AdinkraDocument_DocumentDeactivateNotification];
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)sender defaultFrame:(NSRect)defaultFrame
{
	if ( [adinkraView doesFillWindow] )
		return defaultFrame;
	else {
		NSRect newFrame;
		newFrame.size = [sender frameRectForContentRect:[adinkraView bounds]].size;
		newFrame.origin.x = defaultFrame.origin.x;
		newFrame.origin.y = defaultFrame.origin.y + defaultFrame.size.height - newFrame.size.height;
		return NSIntersectionRect ( newFrame, defaultFrame );
	}
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	if ( [adinkraView doesFillWindow] )
		[adinkraView setFrame: [[[adinkraView window] contentView] frame] ];
}

#pragma mark AdinkraDocument Thread Methods

- (void)detatchAdinkraConstructionThread
{	
    [NSThread detachNewThreadSelector:@selector(constructAdinkra:)
							 toTarget:self
						   withObject:nil];
}

- (void)constructAdinkra: (id)anObject
{
    pool = [[NSAutoreleasePool alloc] init];
 
	Adinkra *anAdinkra = nil;
	
	switch ( adinkraTypeCode ) {  //adinkraType
	case 0 :
		anAdinkra = [Adinkra exteriorAdinkraWithN: N sender: self];
		
		break;
		
	case 1 :
		anAdinkra = [Adinkra adinkraE8timesE8: N sender: self];
	//	anAdinkra = [Adinkra irreducibleAdinkraWithN: N
	//						 alternativeSpinStructure: NO
	//										   sender: self ];
	//  theAdinkra = [Adinkra quotientAdinkraWithN: [NField intValue]
	//						  commutingInvolutions: [Clifford basicCommutingInvolutionsWithN: [NField intValue]]
	//										sender: self];
		break;
		
	case 2 :
		anAdinkra = [Adinkra adinkraEN: N sender: self];
	//	anAdinkra = [Adinkra extendedIrreducibleAdinkraWithN: N sender: self];
		break;
	
	case 3 : // type D_N
		anAdinkra = [Adinkra adinkraDN: N sender: self];
		break;
	}
	
	if ( isValise )
		anAdinkra = [anAdinkra makeTwoDegreesWithLowestDegreeFermions: NO ];
	
	[anAdinkra setHorizontal];

	[self performSelectorOnMainThread:@selector(setAdinkra:)
						   withObject:anAdinkra
						waitUntilDone:YES ];
    
    // Enable inspector.
    // Note: Performing in background thread.
    [ self enableView:inspectorView ];
    
	[pool release];
	pool = nil;
}

- (void) showProgress: (NSDictionary *)userInfo
{
	if ( cancelled ) {
		[self close];
		return;
	}
	
	[adinkraProgress setMinValue: 0.0];
	[adinkraProgress setMaxValue: [[userInfo objectForKey:@"max"] doubleValue]];
	[adinkraProgress setDoubleValue: [[userInfo objectForKey:@"value"] doubleValue]];
	[adinkraString setStringValue: [userInfo objectForKey:@"string"]];
}

- (void) setAdinkra: (Adinkra *)anAdinkra
{	
	if ( cancelled ) {
		[self close];
		return;
	}

	[NSApp endSheet:adinkraSheet];
	[adinkraSheet orderOut: self];
	
	[adinkraView setAdinkra: anAdinkra];
	
	if ( N > 8 )
		[adinkraView setFillWindow: YES];
	[self resizeWindowToAdinkra];
}

#pragma mark Operation Methods

// JP - 2/26/11
// Creates a new document, with the same Adinkra.
- (IBAction)duplicateAdinkra:(id)sender {
	NSError *err = nil;
	AdinkraDocument *duplicate = [[ AdinkraDocument alloc ] initWithType:@"Adinkra" error:&err ];
	Adinkra *anAdinkra = [adinkraView adinkra];
	
	if ( !anAdinkra ) {
		NSLog(@"Failed to duplicate adinkra.");
		[ duplicate release ];
		return;
	}
	
	[ duplicate makeWindowControllers ];
	[ duplicate createAdinkraWithDictionary:[ self generateDictionaryFromAdinkra:anAdinkra ] error:&err ];
	
	if ( err != nil) {
		NSLog(@"Error: Failed to duplicate adinkra.\n%@", err);
		[ duplicate release ];
		return;
	}
	
	[[ NSDocumentController sharedDocumentController ] addDocument: duplicate ];
	
	[ duplicate showWindows ];
	[ duplicate release ];
}

#pragma mark Extension methods

// JP - 3/30/11
// Checks whether an Adinkra extends to higher dimensions.
- (IBAction)checkExtension:(id) sender {
    [[ adinkraView adinkra ] checkExtension ];
}

/*
// JP - 7/13/11
// Toggles to check whether an Adinkra extends to higher dimensions.
- (IBAction)toggleExtension:(id) sender {
    if ( autoCheckExtension) {
        //turn off binding/notifications
        
        // cancel any current checking
        // set colors to grey(default)
    }
    else {
        //begin binding
        //call func {
        ///check if already checking
        [[ adinkraView adinkra ] checkExtension ];
        ///if not: checkextension in new thread
        
        ///[NSThread detachNewThreadSelector:@selector(checkExtension:) toTarget:[ adinkraView adinkra ] withObject:nil];
        /// What happens when document is closed? Application quits?
        
        //}
    }
    
    autoCheckExtension = !autoCheckExtension;
}


#pragma mark Collapsible view methods

// JP - 11/16/11
// Toggles if the dimensional extension view is collapsed.
- (IBAction)toggleDimensionalExtensionView:(id) sender {
    [ dimesionExtensionView toggleCollapsed ];
}
*/

@end
