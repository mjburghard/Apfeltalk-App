//
//  Section.m
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Section.h"


@implementation Section
@synthesize subFora, subForaOnly, name, forumID;

- (void)dealloc {
    self.subForaOnly = NO;
    self.forumID = 0;
    self.subFora = nil;
    self.name = nil;
    [super dealloc];
}
@end
