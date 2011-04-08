//
//  Adinkra.m
//  Adinkramatic
//
//  Created by Greg Landweber on 7/28/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import "Adinkra.h"
#import "Adinkra+Clifford.h"
#import "DoublyEvenCode.h"

@implementation Adinkra

#pragma mark NSObject Methods

- (Adinkra *)init
{
	if ( self = [super init] ) {
		vertices = [[NSMutableDictionary alloc] init];
		edges = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[vertices release];
	[edges release];
	[super dealloc];
}

#pragma mark NSObject Protocol

- (NSString *)description
{
	return [ vertices description ];
}

#pragma mark Adinkra Convenience Constructors

+ (Adinkra *)adinkra
{
	return [[[Adinkra alloc] init] autorelease];
}

+ (Adinkra *)adinkraWithAdinkra: (Adinkra *)anAdinkra
{
	return [[[Adinkra alloc] initWithAdinkra: anAdinkra] autorelease];
}

+ (Adinkra *)adinkraWithDictionary: (NSDictionary *)dictionary
{
	return [[[Adinkra alloc] initWithDictionary: dictionary] autorelease];
}

#pragma mark Adinkra Initializers

- (Adinkra *)initWithAdinkra: (Adinkra *)anAdinkra
{
	vertices = [[NSDictionary alloc] initWithDictionary: anAdinkra->vertices ];
	edges = [[NSArray alloc] initWithArray: anAdinkra->edges ];
	
	return self;
}

- (Adinkra *)initWithDictionary: (NSDictionary *)dictionary
{
	NSArray *basis = [dictionary objectForKey: @"code"];
	if ( basis )
		return [self initWithCode: [DoublyEvenCode codeWithBasis: basis N: [[dictionary objectForKey: @"N"] intValue] ] ];
	
	MutableAdinkra *theAdinkra = [MutableAdinkra adinkra];
	
	NSDictionary *vertexDictionary = [dictionary objectForKey: @"vertices"];
	NSArray *edgeArray = [dictionary objectForKey: @"edges"];
	
	for ( id tag in vertexDictionary) {
		NSDictionary *vertex = [vertexDictionary objectForKey: tag];
		
		[theAdinkra addVertex: [Vertex vertexForDictionary:vertex ] // JP - 3/2/11
					   forTag: tag ];
	}
	
	NSEnumerator *edgeEnumerator = [edgeArray objectEnumerator];
	id edge;
	while ( edge = [edgeEnumerator nextObject] ) {
		[theAdinkra addEdgeFromVertex: [theAdinkra vertexWithTag: [edge objectForKey: @"from"]]
			  toVertex: [theAdinkra vertexWithTag: [edge objectForKey: @"to"]]
			  isNegative: [[edge objectForKey: @"isNegative"] intValue] // formerly boolValue
			  Q: [[edge objectForKey: @"Q"] intValue] ];
	}
	
	return [self initWithAdinkra: theAdinkra];
}

#pragma mark Adinkra Enumerators

- (NSEnumerator *)tagEnumerator
{
	return [ [ [vertices allKeys] sortedArrayUsingSelector: @selector(compare:) ] objectEnumerator ];
//	return [ [ [vertices allKeys] sortedArrayUsingSelector: @selector(degreeCompare:) ] objectEnumerator ];
}

- (NSEnumerator *)vertexEnumerator
{
	return [vertices objectEnumerator];
}

- (NSEnumerator *)edgeEnumerator
{
	return [edges objectEnumerator];
}

#pragma mark Getters

// JP - 4/7/2011
// Added getters to support fast enumeration, replacing edgeEnumerator.
- (NSArray *)tags {
    return [[ vertices allKeys ] sortedArrayUsingSelector: @selector(compare:) ];
}

- (NSArray *)vertices {
    return [ vertices allValues ];
}

- (NSArray *)edges {
    return edges;
}

#pragma mark Adinkra Counters

- (long)vertexCount
{
	return [vertices count];
}

- (long)edgeCount
{
	return [edges count];
}

#pragma mark Adinkra Methods

- (id)tagForVertex: (Vertex *)theVertex
{
	for ( id tag in [ self tags ]) {
		if ( [self vertexWithTag: tag] == theVertex )
			return tag;
	}
	return nil;
}

- (NSDictionary *)dictionary
{
	NSMutableDictionary *vertexDictionary = [NSMutableDictionary dictionaryWithCapacity:[vertices count]];
    
    for ( id tag in [ self tags ])
		[vertexDictionary setObject: [[self vertexWithTag: tag] dictionary] forKey: [tag description]];
		
	NSMutableArray *edgeArray = [NSMutableArray arrayWithCapacity:[edges count]];
	for ( Edge *edge in [ self edges ])
		[edgeArray addObject: [edge dictionaryWithAdinkra: self] ];
		
	return [ NSDictionary dictionaryWithObjectsAndKeys: vertexDictionary, @"vertices", edgeArray, @"edges", nil ];
}

- (Adinkra *)setHorizontal
{
	int width = 0;
	
	NSMutableDictionary *maxWidth = [NSMutableDictionary dictionaryWithCapacity:0];
	
	for ( id tag in [ self tags ]) {
		Vertex *vertex = [vertices objectForKey:tag];
		
		int	degree = [vertex degree];
		int horizontal;
		NSNumber *object,
				 *key = [NSNumber numberWithInt: degree];
		
		if ( object = [maxWidth objectForKey: key] )
			horizontal = [object intValue];
		else
			horizontal = 0;
		
		[vertex setHorizontal: horizontal];
		
		horizontal++;
		
		[maxWidth setObject: [NSNumber numberWithInt: horizontal] forKey: key ];
		
		if ( horizontal > width )
			width = horizontal;
	}
    
	for ( Vertex *vertex in [ self vertices ]) {
		int rowWidth = [ [maxWidth objectForKey: [NSNumber numberWithInt:[vertex degree] ] ] intValue ];
		
		[vertex setHorizontal: width - rowWidth + 2 * [vertex horizontal] ];
	}
	
	return self;
}

- (void)maxDegree: (int *)max minDegree: (int *)min maxHorizontal: (int *)maxHorizontal minHorizontal: (int *)minHorizontal
{
	*max = -10000;
	*min = +10000;
	*maxHorizontal = -10000;
	*minHorizontal = +10000;
	
	for ( Vertex *oneVertex in [ self vertices ]) {
		int degree = [oneVertex degree];
		int	horizontal = [oneVertex horizontal];
		
		if ( degree > *max )
			*max = degree;
		if ( degree < *min )
			*min = degree;
			
		if ( horizontal > *maxHorizontal )
			*maxHorizontal = horizontal;
		if ( horizontal < *minHorizontal )
			*minHorizontal = horizontal;
	}
}

/*
- (void)maxDegree: (int *)max minDegree: (int *)min width: (int *)width
{
	*max = -10000;
	*min = 10000;
	*width = 0;
	
	NSMutableDictionary *maxWidth = [NSMutableDictionary dictionaryWithCapacity:0];
	
	NSEnumerator *vertexEnumerator = [ self vertexEnumerator ];
	Vertex *vertex;
	while ( vertex = [vertexEnumerator nextObject] ) {
		int degree = [vertex degree];
		int		 horizontal;
		NSNumber *object,
				 *key = [NSNumber numberWithInt: degree];
		
		if ( degree > *max )
			*max = degree;
		if ( degree < *min )
			*min = degree;
			
		if ( object = [maxWidth objectForKey: key] )
			horizontal = [object intValue];
		else
			horizontal = 0;
		
		horizontal++;
		
		[maxWidth setObject: [NSNumber numberWithInt: horizontal] forKey: key ];
		
		if ( horizontal > *width )
			*width = horizontal;
	}
		
	*width = *width * 2 - 2;
}
*/

- (Adinkra *)makeTwoDegreesWithLowestDegreeFermions: (BOOL)lowestDegreeFermions
{
    for ( Vertex  *vertex in [ self vertices ]) {
		if ( [vertex degree] % 2 )
			[vertex setDegree: lowestDegreeFermions ? -1 : 1];
		else
			[vertex setDegree: 0];
	}
	return self;
}

- (Adinkra *)edgeFlip: (int)Q
{
	for ( Edge *edge in [ self edges ])
		if ( Q == 0 || [edge Q] == Q )
			[edge setNegative: ![edge isNegative] ];
	
	return self;
}

- (Adinkra *)kleinFlip
{
    for ( Vertex  *vertex in [ self vertices ])
		[vertex setFermion: ![vertex isFermion] ];
	
	return self;
}

- (Adinkra *)degreeFlip
{
    for ( Vertex  *vertex in [ self vertices ])
		[vertex setDegree: -[vertex degree] ];
	
	return self;
}

- (Vertex *)vertexWithTag: (id)tag
{
	return [ vertices objectForKey: tag];
/*
	NSEnumerator *enumerator = [vertices objectEnumerator];
	Vertex *vertex;
	while ( vertex = [enumerator nextObject] ) {
		if ( [[vertex tag] isKindOfClass: [NSSet class] ] ) {
			if ( [[vertex tag] containsObject: tag] )
				return vertex;
		}
		else {
			if ( [[vertex tag] isEqual: tag] )
				return vertex;
		}
	}
	return nil;
*/

//	old code
/*
	int index = [vertices indexOfObject: tag];
	
	if ( index == NSNotFound )
		return nil;
	else
		return [vertices objectAtIndex: index];
*/
}

- (Adinkra *)makeSourceVertices: (NSSet *)sourceVertices
{
	for ( Vertex *aVertex in [ self vertices ])
		if ( ![sourceVertices containsObject: aVertex] )
			[aVertex setDegree: -1000];
		
	BOOL done = false;
	
	while ( !done ) {
		BOOL changed = false;
        for ( Vertex *aVertex in [ self vertices ]) {
			if ( [aVertex degree] != -1000 ) {
				int Q;
				for ( Q = 1; Q <= 32; Q++ ) {
					Vertex *newVertex;
					
					newVertex = [aVertex applyQ: Q];
					if ( ![sourceVertices containsObject: newVertex] &&
						 ( ( [newVertex degree] == -1000 ) ||
						   ( [newVertex degree] > [aVertex degree] + 1 ) ) ) {
						
						[newVertex setDegree: [aVertex degree] + 1 ];
						
						changed = true;
					}
				}
			}
		}
		done = !changed;
	}
	
	return self;
}

- (Adinkra *)makeSingleSourceVertex: (Vertex *)sourceVertex
{
	[ sourceVertex setDegree: 0 ];
	
	return [ self makeSourceVertices: [NSSet setWithObject: sourceVertex ] ];
/*
	NSEnumerator *vertexEnumerator;
	Vertex *aVertex;
	
	vertexEnumerator = [self vertexEnumerator];
	while ( aVertex = [vertexEnumerator nextObject] )
		[aVertex setDegree: -1];
	
	[sourceVertex setDegree: 0];
	
	BOOL done = false;
	
	while ( !done ) {
		BOOL changed = false;
		vertexEnumerator = [self vertexEnumerator];
		while ( aVertex = [vertexEnumerator nextObject] ) {
			if ( [aVertex degree] != -1 ) {
				int Q;
				for ( Q = 1; Q <= 32; Q++ ) {
					Vertex *newVertex;
					
					newVertex = [aVertex applyQ: Q];
					if ( ( [newVertex degree] == -1 ) ||
						 ( [newVertex degree] > [aVertex degree] + 1 ) ) {
						[newVertex setDegree: [aVertex degree] + 1 ];
						changed = true;
					}
				}
			}
		}
		done = !changed;
	}
 */
		
/*	
	int sizeArray[32];
	int i;

	for ( i = 0; i < 32; i++ ) {
		sizeArray[i] = 0;
	}
		
	NSEnumerator *vertexEnumerator = [self vertexEnumerator];
	Vertex *aVertex;
	while ( aVertex = [vertexEnumerator nextObject] ) {
		sizeArray [ [aVertex degree] ] ++;
	}
	 	
	NSLog ( @"Sizes: %i, %i, %i, %i, %i, %i, %i, %i, %i, %i", sizeArray[0], 
			sizeArray[1], 
			sizeArray[2], 
			sizeArray[3], 
			sizeArray[4], 
			sizeArray[5], 
			sizeArray[6], 
			sizeArray[7], 
			sizeArray[8], 
			sizeArray[9] ); 
*/
}

#pragma mark NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone {
    return [[Adinkra alloc] initWithDictionary: [self dictionary]];
}

@end

@implementation MutableAdinkra

+ (MutableAdinkra *)adinkra
{
	return [[[MutableAdinkra alloc] init] autorelease];
}

- (MutableAdinkra *)init
{
	return (MutableAdinkra *)[super init];
}

- (void)addVertex: (Vertex *)vertex forTag: (id)tag;
{
	[(NSMutableDictionary *)vertices setObject: vertex forKey:tag];
}

- (void)addVertexWithDegree: (int)degree isFermion: (BOOL)isFermion tag: (bycopy id)tag
{
	[self addVertex: [Vertex vertexWithDegree: degree isFermion: isFermion] forTag: tag];
}

- (void)addEdgeFromVertex: (Vertex *)from
	toVertex: (Vertex *)to
	isNegative: (BOOL)isNegative
	Q: (int)Q
{
	if ( [from applyQ: Q] )
		return;
		
	Edge *edge = [Edge edgeFromVertex: from toVertex: to isNegative: isNegative Q: Q];
	[(NSMutableArray *)edges addObject: edge];
	[from addEdge: edge];
	[to addEdge: edge];
}

@end