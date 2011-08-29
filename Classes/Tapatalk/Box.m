//
//  Box.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 23.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Box.h"

@implementation Box
@synthesize boxID, title, numberOfMessages, numberOfUnreadMessages, boxType;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.title = [dictionary valueForKey:@"box_name"];
        self.numberOfUnreadMessages = [[dictionary valueForKey:@"unread_count"] integerValue];
        self.numberOfMessages = [[dictionary valueForKey:@"msg_count"] integerValue];
        self.boxID = [[dictionary valueForKey:@"box_id"] integerValue];
        self.boxType = BoxTypeNone;
        NSString *boxTypeString = [dictionary valueForKey:@"box_type"];
        if ([boxTypeString isEqualToString:@"INBOX"])
            self.boxType = BoxTypeInbox;
        else if ([boxTypeString isEqualToString:@"SENT"])
            self.boxType = BoxTypeSentBox;
    }
    return self;
}

- (void)dealloc {
    self.boxID = 0;
    self.title = nil;
    self.numberOfMessages = 0;
    self.numberOfUnreadMessages = 0;
    self.boxType = BoxTypeNone;
    [super dealloc];
}
@end
