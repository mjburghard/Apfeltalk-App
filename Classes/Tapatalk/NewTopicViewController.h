//
//  NewTopicViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 14.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnswerViewController.h"
#import "SubForum.h"

@interface NewTopicViewController : AnswerViewController <NSXMLParserDelegate> {
    SubForum *forum;
    NSMutableData *receivedData;
    UITextField *topicField;
}

@property (retain) SubForum *forum;
@property (retain) NSMutableData *receivedData;
@property (retain) UITextField *topicField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forum:(SubForum *)aForum;

@end
