//
//  NewPostsViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 21.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "DetailThreadController.h"
#import "Topic.h"

@interface NewPostsViewController : ATTableViewController {
    NSMutableArray *topics;
    NSInteger numberOfTopics;
}

@property (retain) NSMutableArray *topics;
@property (assign) NSInteger numberOfTopics;

@end
