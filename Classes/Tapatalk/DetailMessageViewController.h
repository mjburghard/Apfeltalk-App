//
//  DetailMessageViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "ATMessage.h"
#import "Three20/Three20.h"
#import "ATContactPicker.h"


@interface DetailMessageViewController : ATTableViewController <TTMessageControllerDelegate, ATContactPickerDelegate> {
    ATMessage *message;
    BOOL isSending;
}

@property (retain) ATMessage *message;
@property (assign) BOOL isSending;

@end
