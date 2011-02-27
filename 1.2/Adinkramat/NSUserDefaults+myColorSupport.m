//
//  NSUserDefaults+myColorSupport.m
//  Adinkramatic
//
//  Created by Greg Landweber on 8/10/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

#import "NSUserDefaults+myColorSupport.h"

@implementation NSUserDefaults(myColorSupport)
 
- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey
{
    NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey
{
    NSColor *theColor=nil;
    NSData *theData=[self dataForKey:aKey];
	
    if (theData != nil)
        theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
	
    return theColor;
}
 
@end