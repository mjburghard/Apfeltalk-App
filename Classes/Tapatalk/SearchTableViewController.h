//
//  SearchTableViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 29.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicParser.h"

@class ForumViewController;

@interface SearchTableViewController : UITableViewController <TopicParserDelegate> {
    NSMutableData *receivedData;
    NSMutableArray *topics;
    UITableViewCell *loadingCell;
    ForumViewController *forumViewController;
    BOOL showLoadingCell;
}


@property (retain) NSMutableData *receivedData;
@property (retain) NSMutableArray *topics;
@property (retain) ForumViewController *forumViewController;
@property (assign) BOOL showLoadingCell;
@end
