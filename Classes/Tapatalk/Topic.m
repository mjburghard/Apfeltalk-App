//
//  Topic.m
//  Tapatalk
//
//  Created by Manuel Burghard on 20.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Topic.h"


@implementation Topic
@synthesize topicID, title, forumID, hasNewPost, numberOfPosts, userCanPost, closed, subscribed;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.title = [dictionary valueForKey:@"topic_title"];
        self.topicID = [[dictionary valueForKey:@"topic_id"] integerValue];
        self.forumID = [[dictionary valueForKey:@"forum_id"] integerValue];
        self.hasNewPost = [[dictionary valueForKey:@"new_post"] boolValue];
        self.numberOfPosts = [[dictionary valueForKey:@"reply_number"] integerValue];
        self.closed = [[dictionary valueForKey:@"is_closed"] boolValue];
        self.subscribed = [[dictionary valueForKey:@"is_subscribed"] boolValue];
    }
    return self;
}

- (void)dealloc {
    self.subscribed = NO;
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
