//
//  ForumViewController.h
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHFKeychainUtils.h"
#import "User.h"

@class Section;
@class SubForum;

@interface ForumViewController : UITableViewController <NSXMLParserDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UISearchBarDelegate> {
    UISearchBar *searchBar;
    NSMutableString *currentString;
    NSMutableData *receivedData;
    NSMutableArray *sections;
    NSString *path;
    UITextField *usernameTextField, *passwordTextField;
    UITableViewCell *loadingCell;
    NSMutableArray *dataArray;
    
    SubForum *currentObject;
    Section *currentSection;
    SubForum *currentFirstLevelForum;
    SubForum *currentSecondLevelForum;
    SubForum *currentThirdLevelForum;
    
    BOOL isSection, isFirstLevelForum, isSecondLevelForum, isThirdLevelForum;
    
    BOOL isForumName;
    BOOL isDescription;
    BOOL isSubForum;
    BOOL isSubOnly;
    BOOL isForumID;
    BOOL isError;
}

@property (retain) UISearchBar *searchBar;
@property (retain) NSMutableString *currentString;
@property (retain) NSMutableData *receivedData;
@property (retain) NSMutableArray *sections;
@property (retain) NSString *path;
@property (retain) NSMutableArray *dataArray;

@property (retain) SubForum *currentObject;
@property (retain) Section *currentSection;
@property (retain) SubForum *currentFirstLevelForum;
@property (retain) SubForum *currentSecondLevelForum;
@property (retain) SubForum *currentThirdLevelForum;

NSString * decodeString(NSString *aString);
NSString * encodeString(NSString *aString);
- (NSString *)decodeString:(NSString *)aString;
- (NSString *)tapatalkPluginPath;
- (void)login;
- (void)logout;
- (void)loadData;
- (void)loginDidFail;
- (void)sendRequestWithXMLString:(NSString *)xmlString cookies:(BOOL)cookies delegate:(id)delegate;

@end
