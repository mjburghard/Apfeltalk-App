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
#import "XMLRPCResponseParser.h"

@interface User : NSObject <XMLRPCResponseParserDelegate> {
    BOOL loggedIn;
    NSString *username;
    NSString *password;
    NSMutableArray *friends;
    
    NSMutableData *receivedData;
    
    BOOL isLoadingFriends;
}

@property (assign, getter=isLoggedIn) BOOL loggedIn;
@property (copy) NSString *username;
@property (copy) NSString *password;
@property (retain) NSMutableArray *friends;
@property (retain) NSMutableData *receivedData;
@property (assign) BOOL isLoadingFriends;


+ (User*)sharedUser;

- (void)login;
- (void)logout;

@end
