//
//  ForumViewController.h
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "SearchTableViewController.h"


@class Section;
@class SubForum;

@interface ForumViewController : ATTableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
    UISearchBar *searchBar;
    NSMutableArray *sections;
    
    SearchTableViewController *searchTableViewController;
    
    BOOL searchButtonClicked;
}

@property (retain) UISearchBar *searchBar;
@property (retain) NSMutableArray *sections;
@property (retain) SearchTableViewController *searchTableViewController;

@end
