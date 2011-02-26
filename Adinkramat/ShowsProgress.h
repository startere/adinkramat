//
//  ShowsProgress.h
//  Adinkramatic
//
//  Created by Greg Landweber on 8/13/06.
//  Copyright 2006 Gregory D. Landweber. All rights reserved.
//

@protocol ShowsProgress
	- (void) setProgressValue: (unsigned long)value maxValue: (unsigned long)max message: (NSString *)aString;
@end
