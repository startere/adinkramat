//
//  CliffordOperation.m
//  Adinkramatic
//
//  Created by Greg Landweber on 9/18/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import "CliffordOperation.h"


@implementation CliffordOperation

+ (CliffordOperation *)leftMultiplicationBy: (Clifford *)a
{
	return [[[CliffordOperation alloc] initWithElement: a left: YES] autorelease];
}

+ (CliffordOperation *)rightMultiplicationBy: (Clifford *)a
{
	return [[[CliffordOperation alloc] initWithElement: a left: NO] autorelease];
}

- (CliffordOperation *)initWithElement: (Clifford *)newElement left: (BOOL)newLeft
{
	if ( self = [super init] ) {
		element = [newElement retain];
		left = newLeft;
	}
	return self;
}

- (void)dealloc
{
	[element release];
	[super dealloc];
}

- (Clifford *)applyToClifford: (Clifford *)b
{
	if ( left ) {
		return [ element times: b];
	} else {
		if ( [b isOdd] )
			return [ [b negative] times: element ];
		else
			return [ b times: element ];
	}
}

@end
