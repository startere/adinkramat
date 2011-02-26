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
	if ( self = [super init] ) {
		degree = newDegree;
		isFermion = newFermion;
		horizontal = newHorizontal;
		edges = [[NSMutableArray alloc] init];
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

#pragma mark Vertex Methods

- (void)changeSign
{
	NSEnumerator *enumerator = [edges objectEnumerator];
	id edge;
	
	while ( edge = [enumerator nextObject] )
		[edge changeSign];
}

- (BOOL)isSource
{
	NSEnumerator *enumerator = [edges objectEnumerator];
	id edge;
	
	while ( edge = [enumerator nextObject] ) {
		if ( [[edge vertexAdjacentToVertex:self] degree] > degree )
			return NO;
	}
	
	return YES;
}

- (BOOL)isSink
{
	NSEnumerator *enumerator = [edges objectEnumerator];
	id edge;

	while ( edge = [enumerator nextObject] ) {
		if ( [[edge vertexAdjacentToVertex:self] degree] < degree )
			return NO;
	}
	
	return YES;
}

- (NSDictionary *)dictionary
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithBool: isFermion], @"isFermion",
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

- (void)addEdge: (id)edge
{
	[edges addObject: edge];
}

- (Vertex *)applyQ: (int)Q
{
	NSEnumerator *enumerator = [edges objectEnumerator];
	Edge *edge;
	
	while ( edge = [enumerator nextObject] )
		if ( [edge Q] == Q )
			return [edge vertexAdjacentToVertex: self];
	
	return nil;
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

@end