//
//  Post.m
//  Tapatalk
//
//  Created by Manuel Burghard on 21.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Post.h"


@implementation Post
@synthesize postID, title, content, author, authorID, postDate, userIsOnline;

- (void)dealloc {
    self.userIsOnline = NO;
    self.postDate = nil;
    self.authorID = 0;
    self.postID = 0;
    self.title = nil;
    self.content = nil;
    self.author = nil;
    [super dealloc];
}

@end
