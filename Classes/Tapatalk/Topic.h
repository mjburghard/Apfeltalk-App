//
//  Topic.h
//  Tapatalk
//
//  Created by Manuel Burghard on 20.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Topic : NSObject {
    int topicID;
    NSString *title;
    int forumID;
}

@property (copy) NSString *title;
@property (assign) int topicID;
@property (assign) int forumID;

@end
