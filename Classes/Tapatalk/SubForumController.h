//
//  SubForumController.h
//  Tapatalk
//
//  Created by Manuel Burghard on 19.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "SubForum.h"
#import "Topic.h"
#import "DetailThreadController.h"

@interface SubForumController : ATTableViewController {
    SubForum *subForum;
    Topic *currentTopic;
    NSMutableArray *topics;
    NSMutableArray *dataArray;
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
@property (retain) NSMutableArray *dataArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil subForum:(SubForum *)aSubForum;

@end
