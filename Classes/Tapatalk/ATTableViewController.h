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

@interface ATTableViewController : UITableViewController <XMLRPCResponseParserDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    NSMutableData *receivedData;
    UITextField *usernameTextField, *passwordTextField;
    UITableViewCell *loadingCell;
    
}

@property (retain) NSMutableData *receivedData;
@property (retain) UITextField *usernameTextField;
@property (retain) UITextField *passwordTextField;

- (NSString *)tapatalkPluginPath;
- (void)login;
- (void)logout;
- (void)loginDidFail;
- (void)sendRequestWithXMLString:(NSString *)xmlString cookies:(BOOL)cookies delegate:(id)delegate;

@end
