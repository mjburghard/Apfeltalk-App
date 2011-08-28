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
    NSInteger topicID;
    NSString *title;
    NSInteger forumID;
    BOOL hasNewPost;
    BOOL userCanPost;
    BOOL closed;
    BOOL subscribed;
}

@property (copy) NSString *title;
@property (assign) NSInteger topicID;
@property (assign) NSInteger forumID;
@property (assign) BOOL hasNewPost;
@property (assign) NSInteger numberOfPosts;
@property (assign) BOOL userCanPost;
@property (assign, getter = isClosed) BOOL closed;
@property (assign) BOOL subscribed;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
