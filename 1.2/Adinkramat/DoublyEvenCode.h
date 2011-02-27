//
//  DoublyEvenCode.h
//  Adinkramatic
//
//  Created by Greg Landweber on 2/13/08.
//  Copyright 2008 Gregory D. Landweber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DoublyEvenCode : NSObject {
	int	N; // dimension of the vector space containing the code
	int k; // dimension of the code subspace
	NSArray *basis; // NSArray of NSNumbers, each an unsigned long
	UInt32  standardBasis[16]; // row reduced standard basis
	UInt32  withoutPivots[16]; // standard basis with pivots removed
}

// Class methods
+ (DoublyEvenCode *)codeWithBasis: (NSArray *)basis N: (int) N;
+ (DoublyEvenCode *)trivialCodeWithN: (int)N;
+ (DoublyEvenCode *)DN: (int)N;
+ (DoublyEvenCode *)E8timesE8: (int)N;
+ (DoublyEvenCode *)EN: (int)N;

// Initialization methods
- (DoublyEvenCode *)initWithBasis: (NSArray *)basis_ N: (int)N_;

// constructs the standard basis by row reduction
- (void)rowReduce;
- (void)removePivots;

/*
 // Returns the standard basis, with the identity matrix removed,
// stored as an array of Clifford elements of degree 3 mod 4.
- (NSArray *)commutingThreeModFourForms;
*/

// returns the codimension of the code: N-k.
- (int)codimension;

// returns the code in standard form, as an array of left and right Clifford multiplication operations
- (NSArray *)cliffordOperations;
@end
