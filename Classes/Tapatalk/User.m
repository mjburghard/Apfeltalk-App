//
//  User.m
//  Tapatalk
//
//  Created by Manuel Burghard on 25.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@implementation User
SYNTHESIZE_SINGLETON_FOR_CLASS(User)
@synthesize loggedIn;

- (void)dealloc {
    self.loggedIn = NO;
    [super dealloc];
}

@end
