//
//  Section.m
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Section.h"
#import "SubForum.h"


@implementation Section
@synthesize subFora, subForaOnly, title, forumID;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.subForaOnly = [[dictionary valueForKey:@"sub_only"] boolValue];
        self.forumID = [[dictionary valueForKey:@"forum_id"] integerValue];
        self.title = [dictionary valueForKey:@"forum_name"];
        self.subFora = [NSMutableArray array];
        NSArray *array = [dictionary valueForKey:@"child"];
        if ([array count] > 0) {
            for (NSDictionary *dict in array) {
                SubForum *subForum = [[SubForum alloc] initWithDictionary:dict];
                [self.subFora addObject:subForum];
                [subForum release];
            }
        }
    }
    return self;
}

- (void)dealloc {
    self.subForaOnly = NO;
    self.forumID = 0;
    self.subFora = nil;
    self.title = nil;
    [super dealloc];
}
@end
