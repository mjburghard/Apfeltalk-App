//
//  Topic.m
//  Tapatalk
//
//  Created by Manuel Burghard on 20.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Topic.h"


@implementation Topic
@synthesize topicID, title, forumID, hasNewPost, numberOfPosts, userCanPost, closed;

- (void)dealloc {
    self.closed = NO;
    self.userCanPost = NO;
    self.numberOfPosts = 0;
    self.hasNewPost = NO;
    self.title = nil;
    self.topicID = 0;
    self.forumID = 0;
    [super dealloc];
}


@end
