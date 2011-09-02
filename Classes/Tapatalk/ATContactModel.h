//
//  ATContactModel.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLRPCResponseParser.h"
#import "Three20/Three20.h"
#import "Three20/Three20+Additions.h"

@interface ATContactModel : NSObject <TTModel, XMLRPCResponseParserDelegate> {
    NSMutableArray* delegates;
    NSMutableArray *searchResults;
    NSMutableData *receivedData;
    NSMutableArray *onlineUsers;
    BOOL isLoading;
}

@property (nonatomic, retain) NSMutableArray* searchResults;
@property (retain) NSMutableData *receivedData;
@property (retain) NSMutableArray *onlineUsers;
@property (assign) BOOL isLoading;

- (void)search:(NSString*)text;

@end
