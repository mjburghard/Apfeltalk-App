//
//  AnswerViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 14.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic.h"
#import "XMLRPCResponseParser.h"
#import "ATActivityIndicator.h"

@interface AnswerViewController : UIViewController <XMLRPCResponseParserDelegate, UIAlertViewDelegate> {
    UITextView *textView;
    Topic *topic;
    NSMutableData *receivedData;
    BOOL isNotLoggedIn;
    
    ATActivityIndicator *activityIndicator;
}

@property (retain) UITextView *textView;
@property (retain) Topic *topic;
@property (retain) NSMutableData *receivedData;
@property (retain) ATActivityIndicator *activityIndicator;

- (void)cancel;

@end
