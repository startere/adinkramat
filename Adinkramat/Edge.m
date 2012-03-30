//
//  Edge.m
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import "Edge.h"

@implementation Edge

- (NSDictionary *)dictionaryWithAdinkra: (id)adinkra
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
				[[(Adinkra*)adinkra tagForVertex: from] description], @"from",
				[[(Adinkra *)adinkra tagForVertex: to] description], @"to",
				[NSNumber numberWithBool: isNegative], @"isNegative",
				[NSNumber numberWithInt: Q], @"Q",
				nil ];
}

- (Edge *)init
{
	return [self initFromVertex: nil toVertex: nil isNegative: NO Q:0];
}

-(Edge *)initFromVertex: (Vertex *)newFrom
			   toVertex: (Vertex *)newTo
			 isNegative: (BOOL)newNegative
					  Q: (int)newQ
{
	if ( self = [super init] ) {
		from = newFrom;
		to = newTo;
		isNegative = newNegative;
		Q = newQ;
	}
	return self;
}

+ (Edge *)edgeFromVertex: (Vertex *)newFrom
	toVertex: (Vertex *)newTo
	isNegative: (BOOL)newNegative
	Q: (int)newQ
{
	return [[[Edge alloc] initFromVertex: newFrom toVertex: newTo isNegative: newNegative Q: newQ] autorelease];
}

- (Vertex *)from
{
	return from;
}

- (Vertex *)to
{
	return to;
}

- (BOOL)isNegative
{
	return isNegative;
}

// JP - 3/2/11
// Checks if edge is hidden.
- (BOOL)isHidden {
	return [ from isHidden ] || [ to isHidden ];
}

// JP - 7/12/11
// Checks if edge goes upwards from vertex. Assumes adjacent vertices cannot have the same degree.
- (BOOL)isUpFromVertex: (Vertex *)vertex {
    return [[ self vertexAdjacentToVertex:vertex ] degree ] < [ vertex degree ];
}

- (void)setNegative: (BOOL)newNegative
{
	isNegative = newNegative;
}

- (int)Q
{
	return Q;
}

- (void)changeSign
{
	isNegative = !isNegative;
}

- (Vertex *)vertexAdjacentToVertex: (Vertex *)vertex;
{
	if ( vertex == from )
		return to;
		
	if ( vertex == to )
		return from;
		
	return nil;
}
@end

