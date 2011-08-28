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
    
    NSMutableData *receivedData;
    
    BOOL isResult;
}

@property (assign, getter=isLoggedIn) BOOL loggedIn;
@property (copy) NSString *username;
@property (copy) NSString *password;
@property (retain) NSMutableData *receivedData;


+ (User*)sharedUser;

- (void)login;
- (void)logout;

@end
