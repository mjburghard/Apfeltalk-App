//
//  SubscriptionsViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 14.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"

@interface SubscriptionsViewController : ATTableViewController {
    BOOL isUnsubscribingTopic;
    NSInteger numberOfTopics;
    NSMutableArray *topics;
}

@property (assign) BOOL isUnsubscribingTopic;
@property (assign) NSInteger numberOfTopics;
@property (retain) NSMutableArray *topics;

@end
