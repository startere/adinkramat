//
//  Vertex.m
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import "Vertex.h"
#import "Edge.h"

@implementation Vertex

#pragma mark NSObject Methods

- (id)init
{
	return [self initWithDegree: 0 isFermion: NO]; // tag: nil ];
}

- (void)dealloc
{
//	[tag release];
	[edges release];
	[super dealloc];
}

#pragma mark Vertex Convenience Constructors

+ (Vertex *)vertexWithDegree: (int)degree isFermion: (BOOL)isFermion // tag: (id)tag
{
	return [[[Vertex alloc] initWithDegree: degree isFermion: isFermion] //tag: tag]
		autorelease];
}

+ (Vertex *)vertexWithDegree: (int)degree isFermion: (BOOL)isFermion horizontal: (int)horizontal
{
	return [[[Vertex alloc] initWithDegree: degree isFermion: isFermion horizontal: horizontal] autorelease];
}

// JP - 3/2/11
// Creates vertex from dictionary. If isHidden is not in dictionary, isHidden will default to NO.
+ (Vertex *)vertexForDictionary:(NSDictionary *)dictionary {
	return [[[ Vertex alloc ] initWithDegree:[[dictionary objectForKey: @"degree"] intValue]
								   isFermion:[[dictionary objectForKey: @"isFermion"] intValue]
								  horizontal:[[dictionary objectForKey: @"horizontal" ] intValue]
									  hidden:[[dictionary objectForKey: @"isHidden"] boolValue ]] autorelease ];
}
					  
#pragma mark Vertex Initializers

- (Vertex *)initWithDegree: (int)newDegree isFermion: (BOOL)newFermion // tag: (id)tag
{
	return [self initWithDegree: newDegree isFermion: newFermion horizontal: 0];
/*	
	if ( self = [super init] ) {
		self->degree = degree;
		self->isFermion = isFermion;
		edges = [[NSMutableArray alloc] init];

//		[self->tag autorelease];
//		self->tag = [tag retain];
	}
	return self;
*/
}

- (Vertex *)initWithDegree: (int)newDegree isFermion: (BOOL)newFermion horizontal: (int)newHorizontal
{
	return [ self initWithDegree:newDegree isFermion:newFermion horizontal:newHorizontal hidden:NO ];// JP - 3/2/11
}

// JP - 3/2/11
// Support for hidden vertices.
- (Vertex *)initWithDegree: (int)newDegree isFermion: (BOOL)newFermion horizontal: (int)newHorizontal hidden:(BOOL) newHidden {
	if (( self = [super init] )) {
		degree = newDegree;
		isFermion = newFermion;
		isHidden = newHidden;
		horizontal = newHorizontal;
		edges = [[NSMutableDictionary alloc] init];//[[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark Vertex Accessors

- (int)degree
{
	return degree;
}

- (void)setDegree: (int)newDegree
{
	degree = newDegree;
}

- (NSPoint)location
{
	return location;
}

- (void)setLocation: (NSPoint)newLocation
{
	location = newLocation;
}

- (int)horizontal
{
	return horizontal;
}

- (void)setHorizontal: (int)newHorizontal
{
	horizontal = newHorizontal;
}

- (BOOL)isFermion
{
	return isFermion;
}

- (void)setFermion: (BOOL)newFermion
{
	isFermion = newFermion;
}

// JP - 3/2/11
// Support for hidden vertices.
- (BOOL)isHidden {
	return isHidden;
}

- (void)setHidden:(BOOL)newHidden {
	isHidden = newHidden;
}

#pragma mark Vertex Methods

// JP - 3/2/11
// Toggles a vertex's visibility.
- (void)toggleVisibility {
	isHidden = !isHidden;
}

- (void)changeSign
{
    for ( Edge *edge in [ edges allValues ] )
		[edge changeSign];
}

- (BOOL)isSource
{
    for ( Edge *edge in [ edges allValues ] ) {
		if ( [[edge vertexAdjacentToVertex:self] degree] > degree )
			return NO;
	}
	
	return YES;
}

- (BOOL)isSink
{
    for ( Edge *edge in [ edges allValues ] ) {
		if ( [[edge vertexAdjacentToVertex:self] degree] < degree )
			return NO;
	}
	
	return YES;
}

- (NSDictionary *)dictionary
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithBool: isFermion], @"isFermion",
				[NSNumber numberWithBool: isHidden], @"isHidden", // JP - 3/2/11
				[NSNumber numberWithInt: degree], @"degree",
				[NSNumber numberWithInt: horizontal], @"horizontal",
				nil ];
}

/*
- (NSString *)description
{
	NSString *theString; // = [tag description];
	
	theString = [theString stringWithFormat: @"(%i):", degree];
	
	NSEnumerator *enumerator = [edges objectEnumerator];
	Edge *edge;
	while ( edge = [enumerator nextObject] ) {
		id tag = [[edge adjacentTo:self] tag];
		
		if ( [ tag isKindOfClass: [NSSet class]] )
			tag = [tag anyObject];
		
		if ( [edge isNegative] )
			tag = [tag negative];
		
		theString = [theString stringByAppendingFormat: @"  Q%i%@%@",
						[edge Q], [NSString stringWithUTF8String: "→"],
						tag ];
						
					//	[edge isNegative] ? [NSString stringWithUTF8String: "–"] : @"",
					//	[tag isKindOfClass: [NSSet class]] ? [tag anyObject] : tag ];
						
	}
	
	return theString;
}
*/
/*
- (id)tag
{
	return [[tag retain] autorelease];
}
*/

// JP - 8/27/11
- (void)addEdge: (id)edge
{
    [ edges setObject:edge forKey:[ NSNumber numberWithInt:[ edge Q ]]];
	/*
    [edges addObject: edge];
    
    // JP - 8/27/11
    [ edges sortUsingComparator:(NSComparator)^(id obj1, id obj2) {
        return [ obj1 Q ] > [ obj2 Q ];
    }];*/
}

// JP - 7/12/11
- (Vertex *)applyQ: (int)Q
{
    Edge *edge = [ self getQ:Q ];
    
    if (edge)
        return [ edge vertexAdjacentToVertex:self ];
    
    return nil;
}

// JP - 8/27/11
- (Edge *)getQ: (int)Q {
    return [ edges objectForKey:[ NSNumber numberWithInt:Q ]];
    /*
    for ( Edge *edge in edges )
		if ( [edge Q] == Q )
			return edge;
	
	return nil;
     */
}

/*
- (BOOL)isEqual: (id)anObject
{
	if ( tag == nil )
		return false;
		
	if ( [tag isKindOfClass: [NSSet class] ] )
		return [tag containsObject: anObject];
	else
		return [tag isEqual: anObject];
}
*/

-(NSString *) description {
    return [ NSString stringWithFormat:@"(%d,%d)",horizontal,degree ];
}

#pragma mark NSCopying Protocol

// Is this okay because the coding associated with a vertex is immutable??
- (id)copyWithZone:(NSZone *)zone {
    return [ self retain ];
}

@end