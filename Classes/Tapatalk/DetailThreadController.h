//
//  DetailThreadController.h
//  Tapatalk
//
//  Created by Manuel Burghard on 21.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "Topic.h"
#import "Post.h"
#import "ContentCell.h"
#import "GCImageViewer.h"
#import "ATActivityIndicator.h"

@class ATTableViewController;

@interface DetailThreadController : ATTableViewController <ContentCellDelegate> {
    NSInteger numberOfPosts;
    Topic *topic;
    NSMutableArray *posts;
    UIView *activeView;
    ContentCell *answerCell;
    NSInteger site;
    BOOL isAnswering, isSubscribing;
    NSString *username;
}

@property (retain) Topic *topic;
@property (retain) NSMutableArray *posts;
@property (retain) Post *currentPost;
@property (assign) NSInteger site;
@property (assign) NSInteger numberOfPosts;
@property (retain) ContentCell *answerCell;
@property (retain) NSString *username;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topic:(Topic *)aTopic;
- (void)loadLastSite;

@end
