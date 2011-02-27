//
//  Clifford.h
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Adinkra.h"

@interface Clifford : NSObject <NSCopying> {
	unsigned long binaryForm;
	BOOL isNegative;
}

// Class methods
+ (Clifford *)one;
+ (Clifford *)gamma: (unsigned int)i;
+ (Clifford *)gamma: (unsigned int)i gamma: (unsigned int)j;
+ (Clifford *)gamma: (unsigned int)i
			  gamma: (unsigned int)j
			  gamma: (unsigned int)k;
+ (Clifford *)gamma: (unsigned int)i
			  gamma: (unsigned int)j
			  gamma: (unsigned int)k
			  gamma: (unsigned int)l;

+ (Clifford *)topWithN: (unsigned int)N;

+ (Clifford *)cliffordWithBinaryForm: (unsigned long)binary
						  isNegative: (BOOL)negative;

+ (Clifford *)cliffordWithString: (NSString *)aString;

// Initialization methods
- (Clifford *)initWithBinaryForm: (unsigned long)binary isNegative: (BOOL)negative;

// accessors
- (BOOL)isNegative;

// Operator methods
- (Clifford *)times: (Clifford *)b;
- (NSSet *)timesSet: (NSSet *)set;
- (Clifford *)cosetRepresentativeTimesSet: (NSSet *)set;
- (Clifford *)negative;

- (int)degree;
- (BOOL)isOdd;

- (Clifford *)hodgeStarWithN: (unsigned int)N;

+ (NSMutableArray *)maximalCommutingSubsetsOf: (NSMutableArray *)elements;
	//					 withRequiredElements: (NSMutableArray *)requirements;

// Representation and Adinkra constructing methods
+ (NSArray *)basicCommutingInvolutionsWithN: (unsigned int)N;
+ (NSSet *)commutingInvolutionsWithBasis: (NSArray *)basicInvolutions;

// NSComparisonMethods protocol methods
- (NSComparisonResult)compare: (id)object;
- (NSComparisonResult)degreeCompare: (id)object;

@end