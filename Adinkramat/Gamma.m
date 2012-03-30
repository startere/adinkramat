//
//  Gamma.m
//  Adinkramatic
//
//  Created by James on 7/5/11.
//  Copyright 2011 university of md college park. All rights reserved.
//
//  The values of adjList are shorts, that use signed magnitude. This ensures there is a positive and negative 0.
//

#import "Gamma.h"
#define SHSIZE (8 * sizeof(short))
#define UMASK (SHSIZE - 1)//(-1 >> 1)
#define VMASK (1 << (SHSIZE - 1))
#define MOD4(x) ((x) & (3))


@implementation Gamma

- (id)init {
    return [ self initWithN: 4 ];
}

- (Gamma *)initWithN:(NSInteger) n {
    self = [super init];
    if (self) {
        // Check if N isn't a multiple of 4
        if ( MOD4(n))
            [ NSException raise:NSInvalidArgumentException format:@"Invalid argument N = %d in initWithN:.", N ];
        
        N = n;
        adjList = malloc( N * sizeof(short));
    }
    
    return self;
}

- (Gamma *)initGamma0WithN:(NSInteger) n {
    self = [ self initWithN:n ];
    
    if (self) {
        for ( short i = 0; i < n; i++)
            adjList[i] = i;
    }
    
    return self;
}

- (Gamma *)initGamma1WithN:(NSInteger) n {
    self = [ self initWithN:n ];
    
    if (self) {
        for ( short i = 3; i < n; i += 4) {
            adjList[i - 3] = i - 3;
            adjList[i - 2] = i - 2;
            adjList[i - 1] = i - 1 | VMASK;
            adjList[i] = i | VMASK;
        }
    }
    
    return self;

}

- (Gamma *)initGamma2WithN:(NSInteger) n {
    self = [ self initWithN:n ];
    
    if (self) {
        for ( short i = 3; i < n; i += 4) {
            adjList[i - 3] = i | VMASK;
            adjList[i - 2] = i - 1;
            adjList[i - 1] = i - 2;
            adjList[i] = i - 3 | VMASK;
        }
    }
    
    return self;
}

- (Gamma *)initGamma3WithN:(NSInteger) n {
    self = [ self initWithN:n ];
    
    if (self) {
        for ( short i = 3; i < n; i += 4) {
            adjList[i - 3] = i - 1;
            adjList[i - 2] = i;
            adjList[i - 1] = i - 3;
            adjList[i] = i - 2;
        }
    }
    
    return self;
}

#pragma mark -
#pragma mark Class Methods

- (void)dealloc {
    free(adjList);
    [ super dealloc ];
}

+(NSArray *) generate4DGamma:(NSInteger) n {
    NSMutableArray *gammas = [[ NSMutableArray alloc ] init ];
    
    [ gammas addObject:[[[ Gamma alloc ] initGamma0WithN:n ] autorelease ]];
    [ gammas addObject:[[[ Gamma alloc ] initGamma1WithN:n ] autorelease ]];
    [ gammas addObject:[[[ Gamma alloc ] initGamma2WithN:n ] autorelease ]];
    [ gammas addObject:[[[ Gamma alloc ] initGamma3WithN:n ] autorelease ]];
    
    return [ gammas autorelease ];
}
#if 0
+(NSArray *) generateGamma0:(NSInteger) n {
    Gamma *gamma0 = [[ Gamma alloc ] initWithN:n ];
}

+(NSArray *) generateGamma1:(NSInteger) n {
    
}

+(NSArray *) generateGamma2:(NSInteger) n {
    
}

+(NSArray *) generateGamma3:(NSInteger) n {
    
}
#endif

#pragma mark -
#pragma mark Accessor Methods

-(NSInteger) valueForIndex:(NSInteger) i {
    if ( i < 0 || i >= N)
        [ NSException raise:NSRangeException format:@"Invalid index %d for an N = %d Gamma.", i, N ];
    
    return (NSInteger) (adjList[i] & UMASK);
}

// Checks if the corresponding index has a negative weight.
-(BOOL) isNegativeForIndex:(NSInteger) i {
    if ( i < 0 || i >= N)
        [ NSException raise:NSRangeException format:@"Invalid index %d for an N = %d Gamma.", i, N ];
    
    // Equivalent to (adjList[i] < 0)
    return adjList[i] >> (SHSIZE - 1);
}

-(NSInteger) expectedValueForIndex:(NSInteger) i andIndex:(NSInteger) j {
    // or just i == j???
    NSInteger result = ([ self valueForIndex:i] == j) ? 2 : 0;
    
    if ( [ self isNegativeForIndex:i])
        result *= -1;
    
    return result;
}

-(NSInteger) getN {
    return N;
}

@end
