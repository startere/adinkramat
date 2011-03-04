//
//  Vertex.h
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Vertex : NSObject {
	BOOL			isFermion;
	BOOL			isHidden;
	int				degree;
	NSMutableArray	*edges;
	
	int				horizontal;
	NSPoint			location;
}

// Class methods
+ (Vertex *)vertexWithDegree: (int)degree isFermion: (BOOL)isFermion;
+ (Vertex *)vertexWithDegree: (int)degree isFermion: (BOOL)isFermion horizontal: (int)horizontal;
+ (Vertex *)vertexForDictionary:(NSDictionary *)dictionary;

// Initialization methods
- (Vertex *)initWithDegree: (int)degree isFermion: (BOOL)isFermion;
- (Vertex *)initWithDegree: (int)degree isFermion: (BOOL)isFermion horizontal: (int)horizontal;
- (Vertex *)initWithDegree: (int)degree isFermion: (BOOL)isFermion horizontal: (int)horizontal hidden:(BOOL) isHidden;

// Accessor methods
- (void)setDegree: (int)newDegree;
- (int)degree;

- (void)setHorizontal: (int)newHorizontal;
- (int)horizontal;

- (NSPoint)location;
- (void)setLocation: (NSPoint)newLocation;

- (BOOL)isFermion;
- (void)setFermion: (BOOL)newFermion;

- (BOOL)isHidden;
- (void)setHidden:(BOOL)newHidden;

// Other methods
- (void)toggleVisibility;
- (NSDictionary *)dictionary;
- (void)changeSign;
- (BOOL)isSource;
- (BOOL)isSink;
- (Vertex *)applyQ: (int)Q;
- (void)addEdge: (id)edge;

@end