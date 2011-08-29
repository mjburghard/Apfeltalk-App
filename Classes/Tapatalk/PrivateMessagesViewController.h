//
//  PrivateMessagesViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 21.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"

@interface PrivateMessagesViewController : ATTableViewController {
    NSMutableArray *boxes;
}

@property (retain) NSMutableArray *boxes;

@end
