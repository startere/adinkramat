//
//  Clifford.m
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import "Clifford.h"

@implementation Clifford

#pragma mark NSObject Methods

- (Clifford *)init
{
	return [self initWithBinaryForm: 0L isNegative: NO];
}

#pragma mark NSObject Protocol

- (NSString *)description
{
	NSString *theString;
	
	if ( isNegative )
		theString = [NSString stringWithUTF8String: "–"];
	else
		theString = @"";
		
	if ( binaryForm ) {
		BOOL firstGamma = YES;
		int i;
		
		for ( i = 1; i <= 32; i++ )
			if ( binaryForm & ( 1L << (i-1) ) ) {
				if ( firstGamma )
					firstGamma = NO;
				else
					theString = [theString stringByAppendingString: [NSString stringWithUTF8String: "•"]];
				theString = [theString stringByAppendingFormat: [NSString stringWithUTF8String:"γ%i"], i];
			}
	}
	else
		theString = [theString stringByAppendingString: @"1"];
		
	return theString;
}

- (unsigned)hash
{
//	return self->binaryForm;
	return self->isNegative ? self->binaryForm : ~self->binaryForm;
}

- (BOOL)isEqual: (Clifford *)b
{
	return (self->binaryForm == b->binaryForm) && (self->isNegative == b->isNegative);
}

#pragma mark Clifford Convenience Constructors

+ (Clifford *)cliffordWithBinaryForm: (unsigned long)binary isNegative: (BOOL)negative
{
	return [[[Clifford alloc] initWithBinaryForm: binary isNegative: negative] autorelease];
}

+ (Clifford *)cliffordWithString: (NSString *)aString
{
	BOOL isNegative = NO;
	
	if ( [aString hasPrefix: @"-"] ) {
		isNegative = YES;
		aString = [aString substringFromIndex: 1];
	}
	
	unsigned long binaryForm = 0;
	
	int i;
	for ( i = 0; i < [aString length]; i++ ) {
		if ( [aString characterAtIndex: i] == '1' )
			binaryForm += ( 1L << i );
	}
	
	return [Clifford cliffordWithBinaryForm: binaryForm isNegative: isNegative];
}

+ (Clifford *)one
{
	return [[[Clifford alloc] init] autorelease];
}

+ (Clifford *)gamma: (unsigned int)i
{
	return [Clifford cliffordWithBinaryForm: 0x00000001L << (i-1) isNegative: NO];
}

+ (Clifford *)gamma: (unsigned int)i gamma: (unsigned int)j
{
	return [[Clifford gamma:i] times: [Clifford gamma:j]];
}

+ (Clifford *)gamma: (unsigned int)i
			  gamma: (unsigned int)j
			  gamma: (unsigned int)k
{
	return [[Clifford gamma:i] times: [Clifford gamma: j gamma: k]];
}

+ (Clifford *)gamma: (unsigned int)i
			  gamma: (unsigned int)j
			  gamma: (unsigned int)k
			  gamma: (unsigned int)l
{
	if ( (i < j) && (j < k) && (k < l) )
		return [Clifford cliffordWithBinaryForm: (1L << (i-1)) | (1L << (j-1)) | (1L << (k-1)) | (1L << (l-1))
				isNegative: NO];
	else
		return [[Clifford gamma:i] times: [Clifford gamma: j gamma: k gamma:l]];
}

+ (Clifford *)topWithN: (unsigned int)N
{
	return [Clifford cliffordWithBinaryForm: (1L << N) - 1L isNegative: NO];
}

#pragma mark Clifford Class Methods
/*
+ (NSMutableArray *)maximalCommutingSubsetsOf: (NSMutableArray *)elements
						 withRequiredElements: (NSMutableSet *)requirements
{
	if ( requirements == nil )
		requirements = [[NSMutableSet alloc] initWithCapacity: 16];
	
	NSMutableArray *returnSet = [[NSMutableArray alloc] initWithCapacity: 0];
	
	if ( [elements count] == 1 ) {
		[requirements addObjectsFromArray: elements];
		[returnSet addObject: requirements];
	}
	else if ( [elements count] == 0 ) {
		[returnSet addObject: requirements ];
	}
	else {
		Clifford *anElement = [elements objectAtIndex:0];
		[elements removeObjectAtIndex: 0];
		
		NSMutableArray *commutingElements = [[NSMutableArray alloc] initWithCapacity: [elements count]];
		NSMutableSet *noncommutingElements = [[NSMutableSet alloc] initWithCapacity: [elements count]];
		
		Clifford *newElement, *product;
		int index;
		for ( index = 0; index < [elements count]; index++ ) {
			newElement = [elements objectAtIndex: index];
			product = [anElement times: newElement];
			if ( [product degree] % 4 != 0 )
				[commutingElements addObject: newElement];
			else
				[noncommutingElements addObject: newElement];
			[ product release ];			
		}
		
		NSMutableArray *newRequirements = [requirements mutableCopy];
		[newrequirements addObject: anElement];			
		NSMutableArray *commutingSubsets = [Clifford maximalCommutingSubsetsOf: commutingElements
														  withRequiredElements: newRequirements];
		[newRequirements release];
				
		[returnSet addObjectsFromArray: commutingSubsets];
		
		if ( [noncommutingElements count] > 0 ) {
			
			commutingSubsets = [Clifford maximalCommutingSubsetsOf: elements
											  withRequiredElements: requirements];
			
			NSEnumerator *subsetEnumerator = [commutingSubsets objectEnumerator];
			NSMutableSet *aSubset;
			
			int index;
			for ( index = 0; index < [commutingSubsets count]; index++ ) {
				aSubset = [commutingSubsets objectAtIndex: index];
				if ( [ noncommutingElements intersectsSet: aSubset ] )
					[returnSet addObject: aSubset];
			}
			
		}
		[commutingSubsets release];
		[commutingElements release];
		[noncommutingElements release];
	}
	
	return returnSet;
}
*/

 // Note: destroys elements
+ (NSMutableArray *)maximalCommutingSubsetsOf: (NSMutableArray *)elements
//						 withRequiredElements: (NSMutableArray *)requirements
{
	NSMutableArray *returnSet;
	
	if ( [elements count] <= 1 )
		returnSet = [[NSMutableArray alloc] initWithObjects: [[NSMutableSet alloc] initWithArray: elements ], nil ];
	else if ( [elements count] == 2 ) {
		Clifford *anElement = [elements objectAtIndex: 0];
		Clifford *newElement = [elements objectAtIndex: 1];
		
		unsigned long product = anElement->binaryForm ^ newElement->binaryForm;
		int degree = 0;
		while ( product ) {
			degree += (product & 1L);
			product >>= 1;
		}
		
		if ( degree % 4 != 0 )
			returnSet = [[NSMutableArray alloc] initWithObjects:
				[[NSMutableSet alloc] initWithArray: elements],
				nil ];
		else
			returnSet = [[NSMutableArray alloc] initWithObjects:
				[[NSMutableSet alloc] initWithObjects: anElement, nil],
				[[NSMutableSet alloc] initWithObjects: newElement, nil],
				nil];			
	}
	else {		
		Clifford *anElement = [elements lastObject];
		[elements removeObject: anElement];
		
		NSMutableArray *commutingElements = [[NSMutableArray alloc] initWithCapacity: [elements count]];
		NSMutableSet *noncommutingElements = [[NSMutableSet alloc] initWithCapacity: [elements count]];
		
		Clifford *newElement;
		int index, count = [elements count];
		for ( index = 0; index < count; index++ ) {
			newElement = [elements objectAtIndex: index];
			
			unsigned long product = anElement->binaryForm ^ newElement->binaryForm;
			int degree = 0;
			while ( product ) {
				degree += (product & 1L);
				product >>= 1;
			}
						
			if ( degree % 4 != 0 )
				[commutingElements addObject: newElement];
			else
				[noncommutingElements addObject: newElement];
		}

		returnSet = [Clifford maximalCommutingSubsetsOf: commutingElements];
		[returnSet makeObjectsPerformSelector: @selector(addObject:)
								   withObject: anElement];
		
		[commutingElements release];

		if ( [noncommutingElements count] == 1 ) {
			Clifford *nextElement = [noncommutingElements anyObject];
			[elements removeObject: nextElement];
			
			NSMutableArray *nextCommutingElements = [[NSMutableArray alloc] initWithCapacity: [elements count]];
			
			Clifford *newElement;
			int index, count = [elements count];
			for ( index = 0; index < count; index++ ) {
				newElement = [elements objectAtIndex: index];
				
				unsigned long product = nextElement->binaryForm ^ newElement->binaryForm;
				int degree = 0;
				while ( product ) {
					degree += (product & 1L);
					product >>= 1;
				}
				
				if ( degree % 4 != 0 )
					[nextCommutingElements addObject: newElement];
			}
			
			NSMutableArray *nextReturnSet = [Clifford maximalCommutingSubsetsOf: nextCommutingElements];
			[nextReturnSet makeObjectsPerformSelector: @selector(addObject:)
										   withObject: nextElement];
			[returnSet addObjectsFromArray: nextReturnSet];
			
			[nextCommutingElements release];
			[nextReturnSet release];
		}
		else if ( [noncommutingElements count] > 0 ) {
		
			NSMutableArray *commutingSubsets = [Clifford maximalCommutingSubsetsOf: elements];

			int index, count = [commutingSubsets count];
			for ( index = 0; index < count; index++ ) {
				NSMutableSet *aSubset = [commutingSubsets objectAtIndex: index];
				if ( [ noncommutingElements intersectsSet: aSubset ] )
					[returnSet addObject: aSubset];
			}
			[commutingSubsets release];			
		}
		[noncommutingElements release];
	}
		
	return returnSet;
}

/*
// Note: destroys elements
+ (NSMutableArray *)maximalCommutingSubsetsOf: (NSMutableArray *)elements
						 withRequiredElements: (NSMutableArray *)requirements
{
//	NSLog (@"Entering with elements: %@, requirements: %@", elements, requirements );
	NSMutableArray *returnSet = [NSMutableArray arrayWithCapacity: 0];
	
	if ( requirements == nil )
		requirements = [NSMutableArray arrayWithCapacity:0];
	else
		requirements = [requirements mutableCopy];
	
	
//	if ( [elements count] == 1 ) {
//		[returnSet addObject: [NSMutableSet setWithArray: elements ] ];
//	}
//	else
	if ( [elements count] == 0 ) {
		if ( [requirements count] == 0 )
			[returnSet addObject: [NSMutableSet setWithCapacity: 0] ];
	}
	else {
		NSMutableSet *requirement;
		Clifford *anElement;
		
		if ( [requirements count] == 0 ) {
			requirement = nil;
			anElement = [elements lastObject];
		}
		else {
			requirement = [[requirements lastObject] mutableCopy];
			[requirements removeLastObject];
			
			anElement = [requirement anyObject];
			
			if ( anElement )
				[requirement removeObject: anElement];
		}
		
		if ( [elements containsObject: anElement] ) {
				
			[elements removeObject: anElement];
		
			NSMutableArray *commutingElements = [[NSMutableArray alloc] initWithCapacity: [elements count]];
			NSMutableSet *noncommutingElements = [[NSMutableSet alloc] initWithCapacity: [elements count]];

			NSEnumerator *elementEnumerator = [elements objectEnumerator];
			Clifford *newElement, *product;
			while ( newElement = [elementEnumerator nextObject] ) {
				product = [anElement times: newElement];
				if ( [product degree] % 4 != 0 )
					[commutingElements addObject: newElement];
				else
					[noncommutingElements addObject: newElement];
			//	[ product release ];
			}
			
			NSMutableArray *commutingSubsets = [Clifford maximalCommutingSubsetsOf: commutingElements
															  withRequiredElements: requirements];
			if ( ( requirement != nil ) && ( [requirement count] > 0 ) )
				[requirements addObject: requirement];
			
			[commutingSubsets makeObjectsPerformSelector: @selector(addObject:)
											  withObject: anElement];
			
			[returnSet addObjectsFromArray: commutingSubsets];
		
	//		NSLog ( @"given elements: %@, %@, return set: %@", elements, anElement, returnSet );
			
			if ( ( [noncommutingElements count] == 0 ) ||
				 ( (requirement != nil) && ( [requirement count] == 0 ) ) ) {
//				NSLog ( @"returning: %@", returnSet );
				return returnSet;
			}
			else
				[requirements addObject: noncommutingElements];
			
			/*
			 commutingSubsets = [Clifford maximalCommutingSubsetsOf: elements];
			
			NSEnumerator *subsetEnumerator = [commutingSubsets objectEnumerator];
			NSMutableSet *aSubset;
			while ( aSubset = [subsetEnumerator nextObject] )
				if ( [ noncommutingElements intersectsSet: aSubset ] )
					 [returnSet addObject: aSubset];
			 [subsetEnumerator release];
			
			
		//	[elementEnumerator release];
		//	[commutingSubsets release];
		//	[commutingElements release];
		//	[noncommutingElements release];
		}
		else {
			if ( ( requirement != nil ) && ( [requirement count] > 0 ) )
				[requirements addObject: requirement];
		}

		[returnSet addObjectsFromArray: [Clifford maximalCommutingSubsetsOf: elements
													   withRequiredElements: requirements]];
	}
	
//	NSLog ( @"returning: %@", returnSet );
	
	return returnSet;
}
*/
			
+ (NSArray *)basicCommutingInvolutionsWithN: (unsigned int)N
{
	NSMutableArray *basicInvolutions = [NSMutableArray arrayWithCapacity:16];
	
	int i,j,k,l;
	
	for ( l = 4; l <= N; l++ )
		for ( k = 3; k < l; k++ )
			for ( j = 2; j < k; j++ )
				for ( i = 1; i < j; i++ ) {
				
					Clifford *candidate = [Clifford gamma:i gamma:j gamma:k gamma:l];
					
					NSEnumerator *enumerator;
					Clifford *element;
					BOOL commutes = YES;
					
					enumerator = [basicInvolutions objectEnumerator];
					while ( commutes && (element = [enumerator nextObject]) )
						commutes = [ [ candidate times: element] isEqual: [ element times: candidate] ];
					
					if ( commutes ) {						
						[basicInvolutions addObject: candidate];
						i = (j = (k = l - 1) - 1) - 1;
					}
				}
				
	return basicInvolutions;
}

+ (NSSet *)commutingInvolutionsWithBasis: (NSArray *)basicInvolutions
{
	NSMutableSet *commutingInvolutions = [NSMutableSet setWithCapacity: 1 << [basicInvolutions count]];
	
	[commutingInvolutions addObject: [Clifford one]];
	
	NSEnumerator *basisEnumerator = [basicInvolutions objectEnumerator];
	Clifford *basisElement;
	while ( basisElement = [basisEnumerator nextObject] ) {
	
		[commutingInvolutions unionSet: [basisElement timesSet: commutingInvolutions] ];
	/*
		NSEnumerator *enumerator = [commutingInvolutions objectEnumerator];
		Clifford *element;
		while ( element = [enumerator nextObject] ) {
			[commutingInvolutions addObject: [basisElement times: element] ];
		}
	*/
	}
	
	return commutingInvolutions;
}

#pragma mark Clifford Initializers

- (Clifford *)initWithBinaryForm: (unsigned long)binary isNegative: (BOOL)negative
{
	if ( self = [super init] ) {
		binaryForm = binary;
		isNegative = negative;
	}
	return self;
}


#pragma mark Clifford Accessors

- (BOOL)isNegative
{
	return isNegative;
}

#pragma mark Clifford Operators

- (Clifford *)times: (Clifford *)b
{
	unsigned long binary = self->binaryForm ^ b->binaryForm;

	BOOL negative = self->isNegative ^ b->isNegative;
	
	unsigned long bit = 0x80000000;
	
	while ( bit ) {
	
		if ( self->binaryForm & bit ) {
			
			unsigned long x = b->binaryForm & (bit - 1);
			while ( x ) {
				negative ^= x & 1;
				x >>= 1;
			}
		}
			
		bit >>= 1;
	}
	
	return [Clifford cliffordWithBinaryForm: binary isNegative: negative];
}

- (Clifford *)negative
{
	return [Clifford cliffordWithBinaryForm: binaryForm isNegative: !isNegative];
}

- (NSSet *)timesSet: (NSSet *)set;
{
	NSMutableSet *theSet = [ NSMutableSet setWithCapacity: [set count] ];
	NSEnumerator *enumerator= [set objectEnumerator];
	Clifford *element;
	while ( element = [enumerator nextObject] )
		[theSet addObject: [self times: element] ];
	return theSet;
}

- (Clifford *)cosetRepresentativeTimesSet: (NSSet *)set;
{
	NSEnumerator *enumerator = [set objectEnumerator];
	Clifford *element, *product;
	Clifford *representative = nil;
	
	while ( element = [enumerator nextObject] ) {
		product = [self times: element];
		if ( ( representative == nil ) || ( product->binaryForm < representative->binaryForm ) )
			representative = product;
	}
	return representative;
}

/*
+ (NSString *)toString: (id)object
{
	if ( [object isKindOfClass: [Clifford class]] )
		return [object description];
		
	if ( [object isKindOfClass: [NSSet class]] ) {
		NSString *theString = @"0";
		NSEnumerator *enumerator = [object objectEnumerator];
		Clifford *element;
		while ( element = [enumerator nextObject] ) {
			if ( [theString isEqualToString: @"0"] )
				theString = @"";
			else {
				if ( !element->isNegative )
					theString = [theString stringByAppendingString:@"+"];
			}
			theString = [theString stringByAppendingString: [element description]];
		}
		return theString;
	}
		
	return [object description];
}
*/

- (int)degree
{
	int degree = 0;
	int temp = binaryForm;
	
	while ( temp ) {
		degree += (temp & 1L);
		temp >>= 1;
	}
	return degree;
}

- (BOOL)isOdd
{
	return [self degree] % 2;
}

- (Clifford *)hodgeStarWithN: (unsigned int)N
{
	return [[[self times: self] times: self] times: [Clifford topWithN: N]];
}

#pragma mark NSCopying Protocol

// Clifford objects are immutable, so we retain rather than copy
- (id)copyWithZone:(NSZone *)zone {
    return [self retain];
}

#pragma mark NSComparisonMethods Protocol

- (NSComparisonResult)compare: (id)object
{
	if ( binaryForm < ((Clifford *)object)->binaryForm )
		return NSOrderedAscending;
	else if ( binaryForm > ((Clifford *)object)->binaryForm )
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

- (NSComparisonResult)degreeCompare: (id)object
{
	if ( [self degree] < [(Clifford *)object degree] )
		return NSOrderedAscending;
	else if ( [self degree] > [(Clifford *)object degree] )
		return NSOrderedDescending;
	else if ( binaryForm < ((Clifford *)object)->binaryForm )
		return NSOrderedAscending;
	else if ( binaryForm > ((Clifford *)object)->binaryForm )
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

@end