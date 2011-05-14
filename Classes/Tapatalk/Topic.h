//
//  Topic.h
//  Tapatalk
//
//  Created by Manuel Burghard on 20.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Topic : NSObject {
    NSInteger numberOfPosts;
    int topicID;
    NSString *title;
    int forumID;
    BOOL hasNewPost;
}

@property (copy) NSString *title;
@property (assign) int topicID;
@property (assign) int forumID;
@property (assign) BOOL hasNewPost;
@property (assign) NSInteger numberOfPosts;

@end
