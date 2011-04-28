//
//  ForumViewController.h
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserXMLParser.h"

@class Section;
@class SubForum;
@class User;

@interface ForumViewController : UITableViewController <NSXMLParserDelegate, UserXMLParserDelegate> {
    NSMutableString *currentString;
    NSMutableData *receivedData;
    NSMutableArray *sections;
    NSString *path;
    UITextField *usernameTextField, *passwordTextField;
    UITableViewCell *loadingCell;
    UserXMLParser *userXMLParser;
    
    Section *currentSection;
    SubForum *currentSubForum;
    SubForum *currentSubSubForum;
    
    BOOL isForumName;
    BOOL isDescription;
    BOOL isChild;
    BOOL isSubForum;
    BOOL isSubOnly;
    BOOL isForumID;
    BOOL isChildForumName, isChildDescription, isChildSubForum, isChildSubOnly, isChildForumID;
    
    BOOL isChildChildForumName, isChildChildDescription, isChildChildSubForum, isChildChildSubOnly, isChildChildForumID;
    
}

@property (retain) NSMutableString *currentString;
@property (retain) NSMutableData *receivedData;
@property (retain) NSMutableArray *sections;
@property (retain) NSString *path;

@property (retain) Section *currentSection;
@property (retain) SubForum *currentSubForum;
@property (retain) SubForum *currentSubSubForum;

NSString * decodeString(NSString *aString);
NSString * encodeString(NSString *aString);
- (NSString *)decodeString:(NSString *)aString;
- (NSString *)tapatalkPluginPath;

@end
