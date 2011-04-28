//
//  Post.h
//  Tapatalk
//
//  Created by Manuel Burghard on 21.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Post : NSObject {
    int postID;
    NSString *title;
    NSString *content;
    NSString *author;
    int authorID;
}

@property (assign) int postID;
@property (assign) int authorID;
@property (copy) NSString *title;
@property (copy) NSString *content;
@property (copy) NSString *author;


@end
