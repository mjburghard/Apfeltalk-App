//
//  SubForum.m
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubForum.h"


@implementation SubForum
@synthesize description;

- (void)dealloc {
    self.description = nil;
    [super dealloc];
}
@end
