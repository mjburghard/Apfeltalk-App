//
//  Message.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATMessage.h"

@implementation ATMessage
@synthesize state, messageID, content, sender, subject, sentDate, recipients;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.state = ATMessageStateNone;
        self.state = [[dictionary valueForKey:@"msg_state"] integerValue];
        self.messageID = [[dictionary valueForKey:@"msg_id"] integerValue];
        self.content = [dictionary valueForKey:@"text_body"];
        self.sender = [dictionary valueForKey:@"msg_from"];
        self.subject = [dictionary valueForKey:@"msg_subject"];
        
        NSString *dateString = [[dictionary valueForKey:@"post_time"] stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange(20, 1)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"];
        [dateFormatter setLocale:locale];
        NSString *dateFormat = @"yyyyMMdd'T'HH:mm:ssZZZ";
        [dateFormatter setDateFormat:dateFormat];
        self.sentDate = [dateFormatter dateFromString:dateString];
        [dateFormatter release];
        [locale release];
        
        self.recipients = [NSMutableArray array];
        for (NSString *s in [dictionary valueForKey:@"msg_to"]) {
            [self.recipients addObject:s];
        }
        
    }
    
    return self;
}

- (void)dealloc {
    self.state = ATMessageStateNone;
    self.messageID = 0;
    self.content = nil;
    self.sender = nil;
    self.subject = nil;
    self.sentDate = nil;
    self.recipients = nil;
    [super dealloc];
}

@end
