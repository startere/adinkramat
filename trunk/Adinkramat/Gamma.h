//
//  Gamma.h
//  Adinkramatic
//
//  Created by James on 7/5/11.
//  Copyright 2011 university of md college park. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Gamma : NSObject {
@private
    NSInteger N;
    unsigned short *adjList;
}

// Initialization methods
- (Gamma *)initWithN:(NSInteger) n;
- (Gamma *)initGamma0WithN:(NSInteger) n;
- (Gamma *)initGamma1WithN:(NSInteger) n;
- (Gamma *)initGamma2WithN:(NSInteger) n;
- (Gamma *)initGamma3WithN:(NSInteger) n;

// Class methods
+(NSArray *) generate4DGamma:(NSInteger) n;
#if 0
+(NSArray *) generateGamma0:(NSInteger) n;
+(NSArray *) generateGamma1:(NSInteger) n;
+(NSArray *) generateGamma2:(NSInteger) n;
+(NSArray *) generateGamma3:(NSInteger) n;
#endif

// Accessor methods
-(NSInteger) valueForIndex:(NSInteger) i;
-(BOOL) isNegativeForIndex:(NSInteger) i;
-(NSInteger) expectedValueForIndex:(NSInteger) i andIndex:(NSInteger) j;
-(NSInteger) getN;

@end
