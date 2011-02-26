//
//  DoublyEvenCode.m
//  Adinkramatic
//
//  Created by Greg Landweber on 2/13/08.
//  Copyright 2008 Gregory D. Landweber. All rights reserved.
//

#import "DoublyEvenCode.h"
#import "CliffordOperation.h"

@implementation DoublyEvenCode

// Class methods
+ (DoublyEvenCode *)codeWithBasis: (NSArray *)basis N: (int)N
{
	return [[[DoublyEvenCode alloc] initWithBasis: basis N: N] autorelease];
}

+ (DoublyEvenCode *)trivialCodeWithN: (int)N
{
	return [[[DoublyEvenCode alloc] initWithBasis: [NSArray array] N: N] autorelease];
}

+ (DoublyEvenCode *)DN: (int)N
{
	NSMutableArray *basis = [NSMutableArray array];
	
	if ( N > 3 ) {
		UInt32 basisElement = 0x0000000FL;	
		int i;
		for ( i = 0; i < (N-2)/2; i++ ) {
			[basis addObject: [NSNumber numberWithUnsignedLong: basisElement] ];
			basisElement <<= 2;
		}
	}
	
	return [DoublyEvenCode codeWithBasis: basis N: N];	
}

+ (DoublyEvenCode *)E8timesE8: (int)N
{
	UInt32 generators[4] = { 0x0000000FL, 0x00000033L, 0x00000055L, 0x00000096L };
	
	NSMutableArray *basis = [NSMutableArray array];
	
	int i;
	for ( i = 0; i < N; i += 8 )
		switch ( ( i < N - 8 ) ? 0 : N % 8 ) {
			case 0:
				[basis addObject: [NSNumber numberWithUnsignedLong: generators[3] << i]];
			case 7:
				[basis addObject: [NSNumber numberWithUnsignedLong: generators[2] << i]];
			case 6:
				[basis addObject: [NSNumber numberWithUnsignedLong: generators[1] << i]];
			case 5:
			case 4:
				[basis addObject: [NSNumber numberWithUnsignedLong: generators[0] << i]];
		}
	
	return [DoublyEvenCode codeWithBasis: basis N: N];
}

+ (DoublyEvenCode *)EN: (int)N
{
	NSMutableArray *basis = [NSMutableArray array];
	
	if ( N > 3 ) {
		UInt32 basisElement = 0x0000000FL;	
		int i;
		for ( i = 0; i < (N-2)/2; i++ ) {
			[basis addObject: [NSNumber numberWithUnsignedLong: basisElement] ];
			basisElement <<= 2;
		}
	}
	
	if ( N >= 31 )
		[basis addObject: [NSNumber numberWithUnsignedLong: 0x55555555L ]];
	else if ( N >= 23 )
		[basis addObject: [NSNumber numberWithUnsignedLong: 0x00555555L ]];
	else if ( N >= 15 )
		[basis addObject: [NSNumber numberWithUnsignedLong: 0x00005555L ]];
	else if ( N >= 7 )
		[basis addObject: [NSNumber numberWithUnsignedLong: 0x00000055L ]];
	
	return [DoublyEvenCode codeWithBasis: basis N: N];
}

// Initialization methods
- (DoublyEvenCode *)initWithBasis: (NSArray *)basis_ N: (int)N_
{
	if ( self = [super init] ) {
		basis = [basis_ retain];
		N = N_;
		[self rowReduce];
		[self removePivots];
	}
	return self;
}

- (void)dealloc
{
	[basis release];
	[super dealloc];
}

- (void)rowReduce;
{
	int row, column, pivotRow;
	
	// Copy basis to standard basis.
	
	k = [basis count];
	
	for ( row = 0; row < k; row++ ) {
		id element = [basis objectAtIndex: row];
		
		if ( [element isKindOfClass: [NSNumber class]] )
			standardBasis[row] = [ [basis objectAtIndex: row] unsignedLongValue ];
		else if ( [element isKindOfClass: [NSString class]] ) {
			standardBasis[row] = 0L;
			int i;
			for ( i = 0; i < [element length]; i++ ) {
				if ( [element characterAtIndex: i] == '1' )
					standardBasis[row] += ( 1L << i );
			}
		}
		else
			standardBasis[row] = 0L;
		
	}
	
	// Forward phase of row reduction.
	
	pivotRow = 0;
	
	for ( column = 0; ( column < N ) && ( pivotRow < k ); column++ ) {
		UInt32 mask = 1L << column;
		
		// Find the first row with a non-zero entry in this column.
		for ( row = pivotRow; row < k; row++ ) {
			if ( standardBasis[row] & mask ) {
				// We have found our row. Now move it to the top.
				UInt32 temp = standardBasis[row];
				standardBasis[row] = standardBasis[pivotRow];
				standardBasis[pivotRow] = temp;
				break;
			}
		}
		
		// zero out the entries below the pivot
		if ( standardBasis[pivotRow] & mask ) {
			for ( row = pivotRow + 1; row < k; row++ )
				if ( standardBasis[row] & mask )
					standardBasis[row] ^= standardBasis[pivotRow];
			pivotRow++;
		}
		else
			; // BAD: we have a zero column!
	}
	
	// Backward phase of row reduction.
	
	for ( pivotRow = k - 1; pivotRow >= 0; pivotRow-- ) {
		
		// find the pivot column
		UInt32 mask = 1L;
		for ( column = 0; column < N; column++ ) {
			if ( standardBasis[pivotRow] & mask )
				break;
			mask <<= 1;
		}
		
		// zero out the entries above the pivot
		if ( standardBasis[pivotRow] & mask ) {
			for ( row = 0; row < pivotRow; row++ )
				if ( standardBasis[row] & mask )
					standardBasis[row] ^= standardBasis[pivotRow];
		}
		else
			k--; // BAD: we have a zero row!
	}
}

- (void)removePivots;
{
	int row, pivotRow, column;
	
	for ( row = 0; row < k; row++ )
		withoutPivots[row] = standardBasis[row];
	
	for ( pivotRow = 0; pivotRow < k; pivotRow++ ) {
		
		// find the pivot column
		UInt32 mask = 1L;
		for ( column = 0; column < N; column++ ) {
			if ( withoutPivots[pivotRow] & mask )
				break;
			mask <<= 1;
		}
		
		// remove the pivot column from all rows
		for ( row = 0; row < k; row++ ) {
			withoutPivots[row] = ( withoutPivots[row] & ( mask - 1L ) )
							   | ( ( withoutPivots[row] & ~( (mask << 1 ) - 1L ) ) >> 1 );
		}
	}
}
									   
/*
- (NSArray *)commutingThreeModFourForms
{
	NSMutableArray *commutingThreeModFourForms = [NSMutableArray array];
	
	int index;
	
	for ( index = 0; index < k; index++ )
		[commutingThreeModFourForms addObject: [Clifford cliffordWithBinaryForm: (standardBasis[index] >> k) isNegative: NO]];
		
	return commutingThreeModFourForms;
}
*/

- (int)codimension
{
	return N-k;
}

// returns the code in standard form, as an array of left and right Clifford multiplication operations
- (NSArray *)cliffordOperations
{
	NSMutableArray *cliffordOperations = [NSMutableArray array];
	NSMutableArray *cliffordElements = [NSMutableArray array];

	int index;
	BOOL uhOh = NO;
	
	for ( index = 0; index < N - k; index++ )
		[cliffordOperations addObject: [CliffordOperation leftMultiplicationBy: [Clifford gamma: index+1]]];

	for ( index = 0; index < k; index++ ) {
		Clifford *element = [Clifford cliffordWithBinaryForm: withoutPivots[index] isNegative: NO];
		[cliffordOperations addObject: [CliffordOperation rightMultiplicationBy: element]];
		
		if ( ![element isOdd] || ![[element times: element] isEqual: [[Clifford one] negative]] )
			uhOh = YES;

		NSLog ( @"element %@, square %@", element, [element times:element] );

		NSEnumerator *enumerator = [cliffordElements objectEnumerator];
		Clifford *anElement;
		while ( anElement = [enumerator nextObject] )
			if ( ![[element times: anElement] isEqual: [[anElement times: element] negative]] ) {
				NSLog ( @"element %@, anElement %@, product1 %@, product2 %@", element, anElement, [element times: anElement], [anElement times: element] );
				uhOh = YES;
			}
		[cliffordElements addObject: element];
	}
	
	if ( uhOh ) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Not doubly even."
										 defaultButton:nil
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"The code you specified is not doubly even. The resulting Adinkra does not correspond to an off-shell representation of the one dimensional super Poincaré algebra, and its topology does not correspond to a Clifford supermodule."];
		[alert runModal];
	}
	
	return cliffordOperations;
}

@end
