//
//  ATTableViewController.h
//  
//
//  Created by Manuel Burghard on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLRPCResponseParser.h"
#import "User.h"
#import "ContentTranslator.h"
#import "Apfeltalk_MagazinAppDelegate.h"
#import "Three20/Three20.h"
#import "Three20/Three20+Additions.h"
#import "ATContactPicker.h"
#import "ATContactDataSource.h"
#import "ATContactModel.h"

@interface ATTableViewController : UITableViewController <XMLRPCResponseParserDelegate, UIAlertViewDelegate, UIActionSheetDelegate, TTMessageControllerDelegate, ATContactPickerDelegate> {
    NSMutableData *receivedData;
    UITextField *usernameTextField, *passwordTextField;
    UITableViewCell *loadingCell;
    NSDictionary *requestParameters;
    BOOL isNotLoggedIn;
    BOOL isSending;
    
}

@property (retain) NSMutableData *receivedData;
@property (retain) UITextField *usernameTextField;
@property (retain) UITextField *passwordTextField;
@property (assign) BOOL isNotLoggedIn;
@property (retain) NSDictionary *requestParameters;
@property (assign) BOOL isSending;


- (NSString *)tapatalkPluginPath;
- (void)login;
- (void)logout;
- (void)loginDidFail;
- (void)sendRequestWithXMLString:(NSString *)xmlString cookies:(BOOL)cookies delegate:(id)delegate;

@end
