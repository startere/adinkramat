//
//  Adinkra+Clifford.h
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Adinkra.h"
#import "Clifford.h"
#import "DoublyEvenCode.h"

@interface Adinkra (Clifford)

+ (Adinkra *)exteriorAdinkraWithN: (unsigned int)N 
						   sender: (id <ShowsProgress>)sender;
						   
+ (Adinkra *)quotientAdinkraWithN: (unsigned int)N
			 commutingInvolutions: (NSArray *)involutions
						   sender: (id <ShowsProgress>)sender;
	
+ (Adinkra *)exteriorAdinkraWithN: (unsigned int)N
	   commutingThreeModFourForms: (NSArray *)commutingSubset
						   sender: (id <ShowsProgress>)sender;

+ (Adinkra *)cliffordAdinkraWithN: (unsigned int)N
						   sender: (id <ShowsProgress>)sender;

+ (Adinkra *)adinkraWithCode: (DoublyEvenCode *)code sender: (id <ShowsProgress>)sender;

// E8 x E8 x ... x E8
+ (Adinkra *)irreducibleAdinkraWithN: (unsigned int)N
			alternativeSpinStructure: (BOOL)spinStructure
							  sender: (id <ShowsProgress>)sender;

// EN
+ (Adinkra *)extendedIrreducibleAdinkraWithN: (unsigned int)N
									  sender: (id <ShowsProgress>)sender;

// DN
+ (Adinkra *)adinkraDN: (unsigned int)N sender: (id <ShowsProgress>)sender;
+ (Adinkra *)adinkraE8timesE8: (unsigned int)N sender: (id <ShowsProgress>)sender;
+ (Adinkra *)adinkraEN: (unsigned int)N sender: (id <ShowsProgress>)sender;

- (Adinkra *)initWithCode: (DoublyEvenCode *)code;

@end

@interface MutableAdinkra (Clifford)

- (void)addEdgeFromVertex: (Vertex *)fromVertex toVertexWithTag: (Clifford *)element Q: (int)Q;

@end