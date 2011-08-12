//
//  UserXMLParser.h
//  Tapatalk
//
//  Created by Manuel Burghard on 25.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserXMLParser;

@protocol UserXMLParserDelegate

@required

- (void)userIsLoggedIn:(BOOL)isLoggedIn;
- (void)userXMLParserDidFinish;


@end

@interface UserXMLParser : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentString;
    NSMutableData *receivedData;
    NSString *path;
    NSXMLParser *parser;
    NSURLConnection *connection;
    id <UserXMLParserDelegate> delegate;
    
    BOOL isResult;
    BOOL isParsing;
    BOOL isLoading;
}

@property (retain) NSMutableString *currentString;
@property (retain) NSMutableData *receivedData;
@property (retain) NSString *path;
@property (assign) id <UserXMLParserDelegate> delegate;
@property (retain) NSXMLParser *parser;
@property (retain) NSURLConnection *connection;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)theDelegate;
- (void)abortParsing;
- (BOOL)isWorking;
@end
