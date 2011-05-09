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
    id <UserXMLParserDelegate> delegate;
    
    BOOL isResult;
}

@property (retain) NSMutableString *currentString;
@property (retain) NSMutableData *receivedData;
@property (retain) NSString *path;
@property (retain) id <UserXMLParserDelegate> delegate;
@property (retain) NSXMLParser *parser;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)theDelegate;
- (void)abortParsing;
@end
