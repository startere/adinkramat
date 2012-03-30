//
//  Adinkra+Extension.h
//  Adinkramatic
//
//  Created by James on 7/5/11.
//  Copyright 2011 university of md college park. All rights reserved.
//
//  This category adds functionality onto the Adinkra class. It performs 
//  checks on whether an Adinkra extends to d higher dimensions.
//  It depends on the fact that the array of edges are properly ordered
//  by their corresponding Qs. It also depends on the fact that the
//  Gammas are symmetric.
//

#import <Foundation/Foundation.h>
#import "Adinkra.h"
#import "Gamma.h"


@interface Adinkra (Extension)

-(void) checkExtension;
-(BOOL) checkExtensionWithGamma:(Gamma *) gamma;

// Helper methods
-(void) addFactor:(NSInteger)factor toVertex:(Vertex *)v inDictionary:(NSMutableDictionary *)dict;
//-(void) computeTermWithVertex:(Vertex *)v I:(NSInteger)i J:(NSInteger) j upFirst:(BOOL) inDictionary:(NSDictionary *)dict;

@end