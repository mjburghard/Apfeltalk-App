//
//  BoxViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 25.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "Box.h"
#import "Three20/Three20.h"
#import "ATContactPicker.h"

@interface BoxViewController : ATTableViewController <TTMessageControllerDelegate, ATContactPickerDelegate> {
    NSMutableArray *messages;
    Box *box;
    BOOL isSending;
}

@property (retain) NSMutableArray *messages;
@property (retain) Box *box;
@property (assign) BOOL isSending;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil box:(Box *)aBox;

@end
