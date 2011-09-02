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
    ATActivityIndicator *activityIndicator;
    ContentCell *answerCell;
    //UITableViewCell *loadingCell;
    NSInteger site;
    BOOL isAnswering, didRotate, isSubscribing;
}

@property (retain) Topic *topic;
@property (retain) NSMutableArray *posts;
@property (retain) Post *currentPost;
@property (retain) ATActivityIndicator *activityIndicator;
@property (assign) NSInteger site;
@property (assign) NSInteger numberOfPosts;
@property (assign) BOOL didRotate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topic:(Topic *)aTopic;
- (void)loadLastSite;

@end
