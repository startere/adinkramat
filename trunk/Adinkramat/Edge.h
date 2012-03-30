//
//  Edge.h
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Vertex.h"
#import "Adinkra.h"

@interface Edge : NSObject {
	Vertex	*from;
	Vertex	*to;
	BOOL	isNegative;
	int		Q;
}

// Class methods
+ (Edge *)edgeFromVertex: (Vertex *)from
	toVertex: (Vertex *)to
	isNegative: (BOOL)isNegative
	Q: (int)Q;
	
// Initialization methods
-(Edge *)initFromVertex: (Vertex *)from
	toVertex: (Vertex *)to
	isNegative: (BOOL)isNegative
	Q: (int)Q;

// Accessor methods
- (Vertex *)from;
- (Vertex *)to;
- (BOOL)isNegative;
- (BOOL)isHidden;
- (BOOL)isUpFromVertex: (Vertex *)vertex;
- (void)setNegative: (BOOL)newNegative;
- (int)Q;

// Other methods
- (NSDictionary *)dictionaryWithAdinkra: (id)adinkra;
- (void)changeSign;
- (Vertex *)vertexAdjacentToVertex: (Vertex *)vertex;

@end
