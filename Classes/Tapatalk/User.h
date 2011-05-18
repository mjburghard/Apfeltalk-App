//
//  User.h
//  Tapatalk
//
//  Created by Manuel Burghard on 25.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "SFHFKeychainUtils.h"


@interface User : NSObject <NSXMLParserDelegate> {
    BOOL loggedIn;
    NSString *username;
    NSString *password;
    
    NSMutableString *currentString;
    NSMutableData *receivedData;
    NSString *path;
    NSXMLParser *parser;
    BOOL isResult;
}

@property (assign, getter=isLoggedIn) BOOL loggedIn;
@property (retain) NSString *username;
@property (retain) NSString *password;
@property (retain) NSMutableString *currentString;
@property (retain) NSMutableData *receivedData;
@property (retain) NSString *path;
@property (retain) NSXMLParser *parser;

+ (User*)sharedUser;

- (void)login;
- (void)logout;

@end
