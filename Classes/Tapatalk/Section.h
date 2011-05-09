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
    NSString *name;
    int forumID;
    BOOL subForaOnly;
}

@property (retain) NSMutableArray *subFora;
@property (copy) NSString *name;
@property (assign) BOOL subForaOnly;
@property (assign) int forumID;

@end
