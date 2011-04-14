//
//  Adinkra+Clifford.m
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import "Adinkra+Clifford.h"
#import "Clifford.h"
#import "CliffordOperation.h"
#import "DoublyEvenCode.h"

@implementation MutableAdinkra (Clifford)

- (void)addEdgeFromVertex: (Vertex *)fromVertex toVertexWithTag: (Clifford *)element Q: (int)Q
{
	Vertex *toVertex;
	
	if ( [element isNegative] ) {
		if ( toVertex = [self vertexWithTag: [element negative]] )
			[self addEdgeFromVertex: fromVertex toVertex: toVertex isNegative: YES Q: Q];
	}
	else {
		if ( toVertex = [self vertexWithTag: element] )
			[self addEdgeFromVertex: fromVertex toVertex: toVertex isNegative: NO Q: Q];
	}
}

@end

@implementation Adinkra (Clifford)

+ (Adinkra *)adinkraE8timesE8: (unsigned int)N sender: (id <ShowsProgress>)sender
{
	return [self adinkraWithCode: [DoublyEvenCode E8timesE8: N] sender: sender];
}

+ (Adinkra *)adinkraEN: (unsigned int)N sender: (id <ShowsProgress>)sender
{
	return [self adinkraWithCode: [DoublyEvenCode EN: N] sender: sender];
}

+ (Adinkra *)adinkraDN: (unsigned int)N sender: (id <ShowsProgress>)sender
{	
	return [self adinkraWithCode: [DoublyEvenCode DN: N] sender: sender];
/*	
	NSArray *D32StandardForm = [NSArray arrayWithObjects:
		[Clifford gamma: 1 gamma: 2 gamma: 3],
		[Clifford gamma: 1 gamma: 2 gamma: 4],
		[Clifford gamma: 1 gamma: 2 gamma: 5],
		[Clifford gamma: 1 gamma: 2 gamma: 6],
		[Clifford gamma: 1 gamma: 2 gamma: 7],
		[Clifford gamma: 1 gamma: 2 gamma: 8],
		[Clifford gamma: 1 gamma: 2 gamma: 9],
		[Clifford gamma: 1 gamma: 2 gamma: 10],
		[Clifford gamma: 1 gamma: 2 gamma: 11],
		[Clifford gamma: 1 gamma: 2 gamma: 12],
		[Clifford gamma: 1 gamma: 2 gamma: 13],
		[Clifford gamma: 1 gamma: 2 gamma: 14],
		[Clifford gamma: 1 gamma: 2 gamma: 15],
		[Clifford gamma: 1 gamma: 2 gamma: 16],
		nil];
	
	int numberOfThreeModFourForms = 0;
	
	if ( N > 3 ) {
		numberOfThreeModFourForms = ( N - 2 ) / 2;
		N -= numberOfThreeModFourForms;
	}
	
	return [self exteriorAdinkraWithN: N
		   commutingThreeModFourForms: [D32StandardForm subarrayWithRange: NSMakeRange(0,numberOfThreeModFourForms)]
							   sender: sender];
*/
}

	
+ (Adinkra *)exteriorAdinkraWithN: (unsigned int)N sender: (id <ShowsProgress>)sender
{
	return [self adinkraWithCode: [DoublyEvenCode trivialCodeWithN: N] sender: sender];
//	return [self exteriorAdinkraWithN: N commutingThreeModFourForms: [NSArray array] sender: sender];
/*	
	MutableAdinkra *theAdinkra = [MutableAdinkra adinkra];
	
	[sender setProgressValue: 0 maxValue: 1 message:@"Adding vertices"];

	long binaryForm;	
	for ( binaryForm = 0; binaryForm < (1L << N); binaryForm++ ) {
		int degree = 0;
		int temp = binaryForm;
		
		while ( temp ) {
			degree += (temp & 1L);
			temp >>= 1;
		}
		
		[theAdinkra addVertexWithDegree: degree
							  isFermion: degree % 2
									tag: [Clifford cliffordWithBinaryForm: binaryForm isNegative: NO] ];
	}
	
	NSEnumerator *tagEnumerator = [theAdinkra tagEnumerator];
	Clifford *theTag;
	Vertex *theVertex;
	
	Clifford *gamma[33];		
	int Q;
	for ( Q = 1; Q <= N; Q++ )
		gamma[Q] = [Clifford gamma:Q];
	
	unsigned long vertexNumber, vertexMax;
	
	vertexMax = [[tagEnumerator allObjects] count];
	tagEnumerator = [theAdinkra tagEnumerator];
	
	vertexNumber = 1L;

	while ( theTag = [tagEnumerator nextObject] ) {
	
		vertexNumber++;
		if ( !(vertexNumber & 0x000000fL ) )
			[sender setProgressValue: vertexNumber maxValue: vertexMax message:@"Adding edges"];

		theVertex = [ theAdinkra vertexWithTag: theTag];
		
		int Q;
				
		for ( Q = 1; Q <= N; Q++ ) {
			Clifford *product = [ gamma[Q] times: theTag ];
									
			[theAdinkra addEdgeFromVertex: theVertex toVertexWithTag: product Q: Q];
		}
	}
	
//	[theAdinkra setHorizontal];
	
	return [Adinkra adinkraWithAdinkra: theAdinkra];
*/
}

+ (Adinkra *)cliffordAdinkraWithN: (unsigned int)N sender: (id <ShowsProgress>)sender
{
	return [ [ [Adinkra exteriorAdinkraWithN: N sender: sender] makeTwoDegreesWithLowestDegreeFermions: NO ] setHorizontal];
}

// E8 x E8 x ... x E8
+ (Adinkra *)irreducibleAdinkraWithN: (unsigned int)N alternativeSpinStructure: (BOOL)spinStructure sender: (id <ShowsProgress>)sender
{
	MutableAdinkra *theAdinkra = [MutableAdinkra adinkra];
	
	NSArray *basicInvolutions = [Clifford basicCommutingInvolutionsWithN: N];
	
	int generatorArray[16] = { 1, 2, 3, 5, 9, 10, 11, 13, 17, 18, 19, 21, 25, 26, 27, 29 };
	
	int numberOfGenerators = N - [basicInvolutions count];
	
	unsigned long value = 0;
	unsigned long max = 1L << numberOfGenerators;
	
	[sender setProgressValue: value maxValue: max message: @"Adding vertices"];

	unsigned int vertexNumber;
	for ( vertexNumber = 0; vertexNumber < ( 1L << numberOfGenerators ); vertexNumber++ ) {
//		unsigned long binaryForm = 0;
		int degree = 0;
		
		Clifford *theTag = [Clifford one];
		
		int index;
		for ( index = 0; index < numberOfGenerators; index++ )
			if ( vertexNumber & ( 1 << index) ) {
				//binaryForm |= ( 1 << ( generatorArray[index] - 1) );
				theTag = [theTag times: [Clifford gamma:generatorArray[index]]];
				degree = (degree + 1) % 2;
			}

		[theAdinkra addVertexWithDegree: vertexNumber ? -1 : 0
							  isFermion: degree
	//							 forTag: [Clifford cliffordWithBinaryForm: binaryForm isNegative: NO] ];
									tag: theTag ];
	}
	
	[sender setProgressValue: value maxValue: max message: @"Adding edges"];
	
	for ( Clifford *oneTag in [ theAdinkra tags ]) {
		Vertex *aVertex = [theAdinkra vertexWithTag: oneTag];
		
		if ( !(++value & 0x00007fL ) )
			[sender setProgressValue: value maxValue: max message: @"Adding edges"];
			
		int Q;
		for ( Q = 1; Q <= N; Q++ ) {
			Clifford *newTag;
			
			newTag = [ [Clifford gamma:Q] times: oneTag ];
			
			NSEnumerator *basisEnumerator = [basicInvolutions reverseObjectEnumerator];
			Clifford *basisElement;
			while ( basisElement = [basisEnumerator nextObject] ) {
				Clifford *product = [ newTag times: basisElement ];
				if ( [product isLessThan: newTag] )
					newTag = product;
			}
			
			[theAdinkra addEdgeFromVertex: aVertex toVertexWithTag: newTag Q: Q];
		}
	}
	
	[sender setProgressValue: max maxValue: max message: @"Ordering vertices"];
	
	[theAdinkra makeSingleSourceVertex: [theAdinkra vertexWithTag: [Clifford one]]];
	
//	[theAdinkra setHorizontal];
	
	return [Adinkra adinkraWithAdinkra: theAdinkra];
}

/*
// DN
+ (Adinkra *)extendedAdinkraDN: (unsigned int)N sender: (id <ShowsProgress>)sender
{
	if ( N <= 3 ) {
		return [Adinkra exteriorAdinkraWithN: N sender: sender];
	}
	else {
		unsigned int k = (N - 2) / 2;
		NSMutableArray *commutingInvolutions = [NSMutableArray arrayWithCapacity: k];
		
		int i;
		for ( i = 0; i < k; i++ )
			[commutingInvolutions addObject: [Clifford gamma: 2*i+1 gamma: 2*i+2 gamma: 2*i+3 gamma: 2*i+4]];
				
		Adinkra *theAdinkra = [Adinkra quotientAdinkraWithN: N
									   commutingInvolutions: commutingInvolutions
													 sender: sender];
		
		return [theAdinkra makeSingleSourceVertex: [theAdinkra vertexWithTag: [Clifford one]]];
	}
}
*/

+ (Adinkra *)quotientAdinkraWithN: (unsigned int)N commutingInvolutions: (NSArray *)involutions sender: (id <ShowsProgress>)sender
{
	unsigned long max = 2L << (N - [involutions count]);
	unsigned long value = 0L;

	MutableAdinkra *theAdinkra = [MutableAdinkra adinkra];
	
	NSSet *commutingInvolutions = [Clifford commutingInvolutionsWithBasis:involutions];
	
	NSMutableSet *cliffordUsed = [NSMutableSet setWithCapacity: 1L << N];
	
	long binaryForm;
	
	for ( binaryForm = 0; binaryForm < (1L << N); binaryForm++ ) {
		int degree = 0;
		int temp = binaryForm;
		
		while ( temp ) {
			degree += (temp & 1L);
			temp >>= 1;
		}

		Clifford *element = [Clifford cliffordWithBinaryForm: binaryForm isNegative: NO];
		
		if ( ![cliffordUsed containsObject: element] &&
			 ![cliffordUsed containsObject: [element negative] ] ) {
			
			NSSet *coset = [element timesSet: commutingInvolutions];
			
			[theAdinkra addVertexWithDegree: degree % 2
								  isFermion: degree % 2
									    tag: element ];
			
			[cliffordUsed unionSet: coset];
			
			if ( !(++value & 0x000000fL ) )
				[sender setProgressValue: value maxValue: max message: @"Adding vertices"];
			
		/*	if ( value == 1L << 0 )
				binaryForm = (1L << 0) - 1L;
			if ( value == 1L << 1 )
				binaryForm = (1L << 1) - 1L;
			if ( value == 1L << 2 )
				binaryForm = (1L << 2) - 1L;
			if ( value == 1L << 3 )
				binaryForm = (1L << 4) - 1L;
			if ( value == 1L << 4 )
				binaryForm = (1L << 8) - 1L;
			if ( value == 1L << 5 )
				binaryForm = (1L << 9) - 1L;
			if ( value == 1L << 6 )
				binaryForm = (1L << 10) - 1L;
			if ( value == 1L << 7 )
				binaryForm = (1L << 12) - 1L;
			if ( value == 1L << 8 )
				binaryForm = (1L << 16) - 1L;
			if ( value == 1L << 9 )
				binaryForm = (1L << 17) - 1L;
			if ( value == 1L << 10 )
				binaryForm = (1L << 18) - 1L;
			if ( value == 1L << 11 )
				binaryForm = (1L << 20) - 1L;
			if ( value == 1L << 12 )
				binaryForm = (1L << 24) - 1L;
			if ( value == 1L << 13 )
				binaryForm = (1L << 25) - 1L;
			if ( value == 1L << 14 )
				binaryForm = (1L << 26) - 1L;
			if ( value == 1L << 15 )
				binaryForm = (1L << 28) - 1L;
			if ( value == 1L << 16 )
				binaryForm = (1L << 32) - 1L;
		*/		
		//	if ( [cliffordUsed count] - 1L > binaryForm )
		//		binaryForm = [cliffordUsed count] - 1L;
			if ( [cliffordUsed count] == 1L << N )
				binaryForm = 1L << N;
		}
	}

	Clifford *gamma[33];		
	Clifford *minusGamma[33];		
	int Q;
	for ( Q = 1; Q <= N; Q++ ) {
		gamma[Q] = [Clifford gamma:Q];
		minusGamma[Q] = [gamma[Q] negative];
	}

	Vertex *theVertex;
	for ( id theTag in [ theAdinkra tags ]) {
			
		if ( !(++value & 0x000000fL ) )
			[sender setProgressValue: value maxValue: max message: @"Adding edges"];
			
		theVertex = [theAdinkra vertexWithTag: theTag];
		
		int Q;
				
		for ( Q = 1; Q <= N; Q++ ) {
			Clifford *element;
			
			element = [ [ gamma[Q] times: theTag ] cosetRepresentativeTimesSet: commutingInvolutions ];
			
			[theAdinkra addEdgeFromVertex: theVertex toVertexWithTag: element Q: Q];
		}
	}
	
	[theAdinkra setHorizontal];
	
	return [Adinkra adinkraWithAdinkra: theAdinkra];
}

// EN
+ (Adinkra *)extendedIrreducibleAdinkraWithN: (unsigned int)N
									  sender: (id <ShowsProgress>)sender
{
	int numberOfGenerators;
	
	numberOfGenerators = ( N + 3 ) / 8 * 4;
	if ( ( N % 8 ) <= 3 )
		numberOfGenerators += ( N % 8 );
	if ( ( N % 8 ) == 4 )
		numberOfGenerators += 3;
	
	NSMutableArray *commutingSubset = [NSMutableArray arrayWithCapacity: 2 * numberOfGenerators];
		
	if ( ( N % 8 ) == 4 ) {
		[commutingSubset addObject: [Clifford gamma: numberOfGenerators / 4 * 4 + 1
											  gamma: numberOfGenerators / 4 * 4 + 2
											  gamma: numberOfGenerators / 4 * 4 + 3]];
		N = N - 1;
	}
	
	int i;
	for ( i = N - numberOfGenerators /* ( numberOfGenerators / 4 ) * 4 */; i >= 1; i-- )
		[commutingSubset addObject: [[Clifford gamma: i] hodgeStarWithN: ( numberOfGenerators / 4 ) * 4]];

	return [Adinkra exteriorAdinkraWithN: numberOfGenerators
			  commutingThreeModFourForms: commutingSubset
								  sender: sender];
}

+ (Adinkra *)exteriorAdinkraWithN: (unsigned int)N
	   commutingThreeModFourForms: (NSArray *)commutingSubset
						   sender: (id <ShowsProgress>)sender
{
	unsigned long max = 1L << N;
	unsigned long value = 0L;
	
	MutableAdinkra *theAdinkra = [MutableAdinkra adinkra];
	
	[sender setProgressValue: 0 maxValue: 1 message:@"Adding vertices"];
	
	long binaryForm;	
	for ( binaryForm = 0; binaryForm < (1L << N); binaryForm++ ) {
		int degree = 0;
		int temp = binaryForm;
		
		while ( temp ) {
			degree += (temp & 1L);
			temp >>= 1;
		}
		
		[theAdinkra addVertexWithDegree: binaryForm ? -1 : 0
							  isFermion: degree % 2
									tag: [Clifford cliffordWithBinaryForm: binaryForm isNegative: NO] ];
	}
	
	int i;
	
	NSMutableArray *operationArray = [NSMutableArray arrayWithCapacity: 2 * N];
	
	for ( i = 1; i <= N; i++ )
		[operationArray addObject: [CliffordOperation leftMultiplicationBy: [Clifford gamma: i]]];
	
	NSEnumerator *elementEnumerator = [commutingSubset objectEnumerator];
	Clifford *element;
	while ( element = [elementEnumerator nextObject] )
		[operationArray addObject: [CliffordOperation rightMultiplicationBy: element] ];
	
	CliffordOperation *operations[32];
	
	[operationArray getObjects: operations];
	
	[sender setProgressValue: value maxValue: max message: @"Adding edges"];
	
	for ( id theTag in [ theAdinkra tags ]) {
		Vertex *theVertex = [theAdinkra vertexWithTag: theTag];
		
		if ( !(++value & 0x000001fL ) )
			[sender setProgressValue: value maxValue: max message: @"Adding edges"];
		
		int Q;
		for ( Q = 1; Q <= [operationArray count]; Q++ )
			[theAdinkra addEdgeFromVertex: theVertex toVertexWithTag: [ operations[Q-1] applyToClifford: theTag ] Q: Q];
	}
	
	[sender setProgressValue: max maxValue: max message: @"Ordering vertices"];
	[theAdinkra makeSingleSourceVertex: [theAdinkra vertexWithTag: [Clifford one]]];
//	[theAdinkra setHorizontal];
	return [Adinkra adinkraWithAdinkra: theAdinkra];	
}

+ (Adinkra *)adinkraWithCode: (DoublyEvenCode *)code sender: (id <ShowsProgress>)sender
{
	int N = [code codimension];
	
	unsigned long max = 1L << N;
	unsigned long value = 0L;
	
	MutableAdinkra *theAdinkra = [MutableAdinkra adinkra];
	
	[sender setProgressValue: 0 maxValue: 1 message:@"Adding vertices"];
	
	long binaryForm;	
	for ( binaryForm = 0; binaryForm < (1L << N); binaryForm++ ) {
		int degree = 0;
		int temp = binaryForm;
		
		while ( temp ) {
			degree += (temp & 1L);
			temp >>= 1;
		}
		
		[theAdinkra addVertexWithDegree: binaryForm ? -1 : 0
							  isFermion: degree % 2
									tag: [Clifford cliffordWithBinaryForm: binaryForm isNegative: NO] ];
	}
	
	NSArray *operationArray = [code cliffordOperations];
	
	CliffordOperation *operations[32];
	[operationArray getObjects: operations];
	
	[sender setProgressValue: value maxValue: max message: @"Adding edges"];
	
	for ( id theTag in [ theAdinkra tags ]) {
		Vertex *theVertex = [theAdinkra vertexWithTag: theTag];
		
		if ( !(++value & 0x000001fL ) )
			[sender setProgressValue: value maxValue: max message: @"Adding edges"];
		
		int Q;
		for ( Q = 1; Q <= [operationArray count]; Q++ )
			[theAdinkra addEdgeFromVertex: theVertex toVertexWithTag: [ operations[Q-1] applyToClifford: theTag ] Q: Q];
	}
	
	[sender setProgressValue: max maxValue: max message: @"Ordering vertices"];
	[theAdinkra makeSingleSourceVertex: [theAdinkra vertexWithTag: [Clifford one]]];
	return [Adinkra adinkraWithAdinkra: theAdinkra];	
}

- (Adinkra *)initWithCode: (DoublyEvenCode *)code
{
	int N = [code codimension];
	
	MutableAdinkra *theAdinkra = [MutableAdinkra adinkra];
	
	long binaryForm;	
	for ( binaryForm = 0; binaryForm < (1L << N); binaryForm++ ) {
		int degree = 0;
		int temp = binaryForm;
		
		while ( temp ) {
			degree += (temp & 1L);
			temp >>= 1;
		}
		
		[theAdinkra addVertexWithDegree: binaryForm ? -1 : 0
							  isFermion: degree % 2
									tag: [Clifford cliffordWithBinaryForm: binaryForm isNegative: NO] ];
	}
	
	NSArray *operationArray = [code cliffordOperations];
	
	CliffordOperation *operations[32];
	[operationArray getObjects: operations];
	
    for ( id theTag in [ theAdinkra tags ]) {
		Vertex *theVertex = [theAdinkra vertexWithTag: theTag];
		
		int Q;
		for ( Q = 1; Q <= [operationArray count]; Q++ )
			[theAdinkra addEdgeFromVertex: theVertex toVertexWithTag: [ operations[Q-1] applyToClifford: theTag ] Q: Q];
	}
	
	[theAdinkra makeSingleSourceVertex: [theAdinkra vertexWithTag: [Clifford one]]];
	[theAdinkra setHorizontal];
	
	return [self initWithAdinkra: theAdinkra];	
}

@end
