//
//  Box.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 23.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BoxTypeNone,
    BoxTypeInbox,
    BoxTypeSentBox
} BoxType;

@interface Box : NSObject {
    NSInteger boxID;
    NSInteger numberOfMessages;
    NSInteger numberOfUnreadMessages;
    NSString *title;
    BoxType boxType;
}

@property (assign) NSInteger boxID;
@property (assign) NSInteger numberOfMessages;
@property (assign) NSInteger numberOfUnreadMessages;
@property (copy) NSString *title;
@property (assign) BoxType boxType;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
