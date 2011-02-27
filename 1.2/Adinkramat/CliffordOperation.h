//
//  CliffordOperation.h
//  Adinkramatic
//
//  Created by Greg Landweber on 9/18/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Clifford.h"

@interface CliffordOperation : NSObject {
	Clifford *element;
	BOOL left;
}

+ (CliffordOperation *)leftMultiplicationBy: (Clifford *)a;
+ (CliffordOperation *)rightMultiplicationBy: (Clifford *)a;

- (CliffordOperation *)initWithElement: (Clifford *)newElement left: (BOOL)newLeft;

- (Clifford *)applyToClifford: (Clifford *)b;
@end
