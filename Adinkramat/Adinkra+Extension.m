//
//  Adinkra+Extension.m
//  Adinkramatic
//
//  Created by James on 7/5/11.
//  Copyright 2011 university of md college park. All rights reserved.
//

#import "Adinkra+Extension.h"

// TODO: temporary
#define JPAlert(msg) alert = [ NSAlert alertWithMessageText:@"Dimensional Extension" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:msg ]; [ alert runModal ];

// Use delegate methods??

@implementation Adinkra (Extension)

// JP - 7/13/11
// Checks whether an Adinkra extends to higher dimensions
-(void) checkExtension {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //[[ NSThread currentThread ] setName:@"Extension" ];
    NSArray *gammas = [ Gamma generate4DGamma:4 ];
    
    NSLog(@"Checking Dimensional Extension...");
    
    //sort vertex edges appropriately
    
    //check gamma[0]? d = t
    
    // Send notification to set all statuses as spinning
    
    // TODO: temp
    NSAlert *alert;
    
    // Check 2 dimensions.
    if ( ![ self checkExtensionWithGamma:[ gammas objectAtIndex:1 ]]) {
        
        NSLog(@"Does not enhance to two dimensions.");
        JPAlert(@"Does not enhance to two dimensions.");
        // Send notification to set all statuses as red

        [pool release];
        return;
    }
    // Send notification to set 2d as green
    NSLog(@"Extends to 2 dimensions.");
    JPAlert(@"Extends to 2 dimensions.");
    
    // Check 3 and 4 dimensions.
    if ( ![ self checkExtensionWithGamma:[ gammas objectAtIndex:2 ]] 
        || ![ self checkExtensionWithGamma:[ gammas objectAtIndex:3 ]]) {
        NSLog(@"Does not enhance to four dimensions.");
        JPAlert(@"Does not enhance to four dimensions.");
        // Send notification to set 4d as red
        
        [pool release];
        return;
    }
    // Send notification to set 4d as green
    NSLog(@"Extends to 4 dimensions.");
    JPAlert(@"Extends to 4 dimensions.");
    
	[pool release];
}

-(BOOL) checkExtensionWithGamma:(Gamma *) gamma {
    NSInteger N = [ gamma getN ];
    NSMutableDictionary *sum = [ NSMutableDictionary dictionaryWithCapacity:N ];
    
    for ( Vertex *v in [ vertices allValues ])
        for ( NSInteger i = 0; i < N; i++)
            for ( NSInteger j = i; j < N; j++) {
                // {u_I,(gamma_JK)d_K} + {u_J,(gamma_IK)d_K} = 2gamma_IJ
                
                //
                // u_I*(gamma_JK)d_K
                Edge *firstEdge = [ v getQ:i+1 ];
                Edge *secondEdge;
                Vertex *u;
                Vertex *destination;
                NSInteger newFactor;
                
                // Make sure edge goes up.
                if ( [ firstEdge isUpFromVertex:v ]) {
                    u = [ firstEdge vertexAdjacentToVertex:v ];
                    secondEdge = [ u getQ:[ gamma valueForIndex:j ]+1 ];
                    
                    // Make sure edge goes down.
                    if ( ![ secondEdge isUpFromVertex:u ]) {
                        destination = [ secondEdge vertexAdjacentToVertex:u ];
                        // firstEdge * secondEdge * gammaSign
                        // 0 => +1
                        // 1 => -1
                        newFactor = ([ firstEdge isNegative ] ^ [ secondEdge isNegative ] ^ [ gamma isNegativeForIndex:j ]) ? -1 : 1;
                        
                        [ self addFactor:newFactor toVertex:destination inDictionary:sum ];
                    }
                    // Otherwise this term is 0 and doesn't contribute.
                }
                // Otherwise this term is 0 and doesn't contribute.
                
                //
                // (gamma_JK)d_K*u_I
                firstEdge = [ v getQ:[ gamma valueForIndex:j ]+1 ];
                
                // Make sure edge goes down.
                if ( ![ firstEdge isUpFromVertex:v ]) {
                    u = [ firstEdge vertexAdjacentToVertex:v ];
                    secondEdge = [ u getQ:i+1 ];
                    
                    // Make sure edge goes up.
                    if ( [ secondEdge isUpFromVertex:u ]) {
                        destination = [ secondEdge vertexAdjacentToVertex:u ];
                        newFactor = ([ firstEdge isNegative ] ^ [ secondEdge isNegative ] ^ [ gamma isNegativeForIndex:j ]) ? -1 : 1;
                        
                        [ self addFactor:newFactor toVertex:destination inDictionary:sum ];
                    }
                }
                
                //
                // u_J*(gamma_IK)d_K
                firstEdge = [ v getQ:j+1 ];
                
                // Make sure edge goes up.
                if ( [ firstEdge isUpFromVertex:v ]) {
                    u = [ firstEdge vertexAdjacentToVertex:v ];
                    secondEdge = [ u getQ:[ gamma valueForIndex:i ]+1 ];
                    
                    // Make sure edge goes down.
                    if ( ![ secondEdge isUpFromVertex:u ]) {
                        destination = [ secondEdge vertexAdjacentToVertex:u ];
                        newFactor = ([ firstEdge isNegative ] ^ [ secondEdge isNegative ] ^ [ gamma isNegativeForIndex:i ]) ? -1 : 1;
                         
                        [ self addFactor:newFactor toVertex:destination inDictionary:sum ];
                    }
                }
                
                //
                // (gamma_IK)d_K*u_J
                firstEdge = [ v getQ:[ gamma valueForIndex:i ]+1 ];
                
                // Make sure edge goes down.
                if ( ![ firstEdge isUpFromVertex:v ]) {
                    u = [ firstEdge vertexAdjacentToVertex:v ];
                    secondEdge = [ u getQ:j+1 ];
                    
                    // Make sure edge goes up.
                    if ( [ secondEdge isUpFromVertex:u ]) {
                        destination = [ secondEdge vertexAdjacentToVertex:u ];
                        newFactor = ([ firstEdge isNegative ] ^ [ secondEdge isNegative ] ^ [ gamma isNegativeForIndex:i ]) ? -1 : 1;
                        
                        [ self addFactor:newFactor toVertex:destination inDictionary:sum ];
                    }
                }

                // Check that they all extend
                for ( u in [ sum allKeys ]) {
                    if ( (u != v)
                        || [ (NSNumber *)[ sum objectForKey:u ] integerValue ] != [ gamma expectedValueForIndex:i andIndex:j ])
                        return NO;
                }
                
                [ sum removeAllObjects ];
            }
    
    return YES;
}

#pragma mark Helper methods

// Add factor to vertex. If new sum is 0, remove from dictionary.
-(void) addFactor:(NSInteger)newFactor toVertex:(Vertex *)v inDictionary:(NSMutableDictionary *)sum {
    NSNumber *factor = [ sum objectForKey:v ];
    
    if (factor)
        newFactor += [ factor integerValue ];
    
    if (newFactor)
        [ sum setObject:[ NSNumber numberWithInteger:newFactor ] forKey:v ];
    else if (factor)
        [ sum removeObjectForKey:v ];
}

// Compute term.

@end