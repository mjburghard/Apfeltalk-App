//
//  AnswerViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 14.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic.h"


@interface AnswerViewController : UIViewController <UIAlertViewDelegate> {
    UITextView *textView;
    Topic *topic;
}

@property (retain) UITextView *textView;
@property (retain) Topic *topic;

@end