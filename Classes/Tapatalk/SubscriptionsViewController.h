//
//  SubscriptionsViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 14.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubForumController.h"

@interface SubscriptionsViewController : SubForumController {
    BOOL isUnsubscribingTopic;
}

@property (assign) BOOL isUnsubscribingTopic;

@end
