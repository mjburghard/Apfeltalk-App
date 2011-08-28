//
//  Section.h
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Section : NSObject {
    NSMutableArray *subFora;
    NSString *title;
    NSInteger forumID;
    BOOL subForaOnly;
}

@property (retain) NSMutableArray *subFora;
@property (copy) NSString *title;
@property (assign) BOOL subForaOnly;
@property (assign) NSInteger forumID;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
