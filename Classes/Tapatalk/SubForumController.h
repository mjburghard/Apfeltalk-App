//
//  SubForumController.h
//  Tapatalk
//
//  Created by Manuel Burghard on 19.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumViewController.h"
#import "SubForum.h"
#import "Topic.h"
#import "DetailThreadController.h"

@interface SubForumController : ForumViewController <UIActionSheetDelegate> {
    SubForum *subForum;
    Topic *currentTopic;
    NSMutableArray *topics;
    NSInteger numberOfTopics;
    
    BOOL isTopicID, isTopicTitle, isPrefixes, isNewPost, isReplyNumber, isClosed, isSubscribed;
    BOOL isLoadingPinnedTopics;
    BOOL isTotalTopicNumber;
}

@property (retain) SubForum *subForum;
@property (retain) Topic *currentTopic;
@property (retain) NSMutableArray *topics;
@property (assign) BOOL isLoadingPinnedTopics;
@property (assign) NSInteger numberOfTopics;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil subForum:(SubForum *)aSubForum;

@end
