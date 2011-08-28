//
//  Post.m
//  Tapatalk
//
//  Created by Manuel Burghard on 21.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Post.h"
#import "ContentTranslator.h"


@implementation Post
@synthesize postID, title, content, author, authorID, postDate, userIsOnline;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.author = [dictionary valueForKey:@"post_author_name"];
        self.authorID = [[dictionary valueForKey:@"post_author_id"] integerValue];
        self.title = [dictionary valueForKey:@"post_title"];
        ContentTranslator *contentTranslator = [[ContentTranslator alloc] init];
        self.content = [contentTranslator translateStringForiOS:[dictionary valueForKey:@"post_content"]];
        [contentTranslator release];
        self.userIsOnline = [[dictionary valueForKey:@"is_online"] boolValue];
        self.postID = [[dictionary valueForKey:@"post_id"] integerValue];
        
        NSString *dateString = [[dictionary valueForKey:@"post_time"] stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange(20, 1)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"];
        [dateFormatter setLocale:locale];
        NSString *dateFormat = @"yyyyMMdd'T'HH:mm:ssZZZ";
        [dateFormatter setDateFormat:dateFormat];
        self.postDate = [dateFormatter dateFromString:dateString];
        [dateFormatter release];
        [locale release];
    }
    return self;
}

- (void)dealloc {
    self.userIsOnline = NO;
    self.postDate = nil;
    self.authorID = 0;
    self.postID = 0;
    self.title = nil;
    self.content = nil;
    self.author = nil;
    [super dealloc];
}

@end
