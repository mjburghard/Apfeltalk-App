//
//  Message.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ATMessageStateNone = 0,
    ATMessageStateUnread = 1,
    ATMessageStateRead = 2,
    ATMessageStateReplied = 3,
    ATMessageStateForwarded = 4
} ATMessageState;

@interface ATMessage : NSObject {
    NSInteger messageID;
    ATMessageState state;
    NSDate *sentDate;
    NSString *sender;
    NSMutableArray *recipients;
    NSString *subject;
    NSString *content;
    NSInteger boxID;
}

@property (assign) ATMessageState state;
@property (assign) NSInteger messageID;
@property (retain) NSDate *sentDate;
@property (copy) NSString *sender;
@property (retain) NSMutableArray *recipients;
@property (copy) NSString *subject;
@property (copy) NSString *content;
@property (assign) NSInteger boxID;


- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
