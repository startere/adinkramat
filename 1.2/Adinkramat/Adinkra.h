//
//  Adinkra.h
//  Adinkramatic
//
//  Created by Greg Landweber on 7/28/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShowsProgress.h"
#import "Vertex.h"
#import "Edge.h"

@interface Adinkra : NSObject <NSCopying> {
	NSDictionary *vertices;
	NSArray *edges;
}

// Class methods
+ (Adinkra *)adinkra;
+ (Adinkra *)adinkraWithAdinkra: (Adinkra *)anAdinkra;
+ (Adinkra *)adinkraWithDictionary: (NSDictionary *)dictionary;

// Initialization methods
- (Adinkra *)initWithAdinkra: (Adinkra *)anAdinkra;
- (Adinkra *)initWithDictionary: (NSDictionary *)dictionary;

// Other methods
- (long)vertexCount;
- (long)edgeCount;

- (id)tagForVertex: (Vertex *)theVertex;
- (NSDictionary *)dictionary;
- (void)maxDegree: (int *)max minDegree: (int *)min maxHorizontal: (int *)maxHorizontal minHorizontal: (int *)minHorizontal;
- (Vertex *)vertexWithTag: (id)tag;
- (NSEnumerator *)tagEnumerator;	
- (NSEnumerator *)vertexEnumerator;
- (NSEnumerator *)edgeEnumerator;

- (Adinkra *)setHorizontal;
- (Adinkra *)makeTwoDegreesWithLowestDegreeFermions: (BOOL)lowestDegreeFermions;
- (Adinkra *)kleinFlip;
- (Adinkra *)edgeFlip: (int)Q;
- (Adinkra *)degreeFlip;
- (Adinkra *)makeSourceVertices: (NSSet *)sourceVertices;
- (Adinkra *)makeSingleSourceVertex: (Vertex *)sourceVertex;

@end

@protocol MutableAdinkra
- (void)addVertexWithDegree: (int)degree isFermion: (BOOL)isFermion tag: (bycopy id)tag;
@end


@interface MutableAdinkra : Adinkra <MutableAdinkra> {
}

+ (MutableAdinkra *)adinkra;
- (MutableAdinkra *)init;

- (void)addEdgeFromVertex: (Vertex *)theVertex
				 toVertex: (Vertex *)newVertex
			   isNegative: (BOOL)isNegative
						Q: (int)Q;

- (void)addVertex: (Vertex *)vertex forTag: (id)tag;
						
@end
