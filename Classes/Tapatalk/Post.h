//
//  Post.h
//  Tapatalk
//
//  Created by Manuel Burghard on 21.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Post : NSObject {
    NSInteger postID;
    NSString *title;
    NSString *content;
    NSString *author;
    NSDate *postDate;
    NSInteger authorID;
    BOOL userIsOnline;
}

@property (assign) NSInteger postID;
@property (assign) NSInteger authorID;
@property (copy) NSString *title;
@property (copy) NSString *content;
@property (copy) NSString *author;
@property (retain) NSDate *postDate;
@property (assign) BOOL userIsOnline;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
