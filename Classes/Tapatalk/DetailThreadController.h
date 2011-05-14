//
//  DetailThreadController.h
//  Tapatalk
//
//  Created by Manuel Burghard on 21.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumViewController.h"
#import "Topic.h"
#import "Post.h"
#import "ContentCell.h"
#import "SubjectCell.h"
#import "GCImageViewer.h"

@interface DetailThreadController : ForumViewController <ContentCellDelegate, SubjectCellDelegate> {
    NSInteger numberOfPosts;
    Topic *topic;
    NSMutableArray *posts;
    Post *currentPost;
    UIView *activeView;
    ContentCell *answerCell;
    NSInteger site;
    
    BOOL isPostTitle, isPostID, isPostAuthor, isPostAuthorID, isPostContent, isNumberOfPosts;
}

@property (retain) Topic *topic;
@property (retain) NSMutableArray *posts;
@property (retain) Post *currentPost;
@property (assign) NSInteger site;
@property (assign) NSInteger numberOfPosts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topic:(Topic *)aTopic;
- (void)loadLastSite;

@end
