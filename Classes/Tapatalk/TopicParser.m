//
//  TopicParser.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 29.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TopicParser.h"

@implementation TopicParser
@synthesize basePath, delegate, currentTopic, topics, path, currentString, intPath, stringPath, base64Path, booleanPath, namePath, xmlParser, numberOfTopics;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithData:(NSData *)data 
         basePath:(NSString *)aBasePath 
            delegate:(id)aDelegate {
    self = [self init];
    if (self && aBasePath) {
        self.basePath = aBasePath;
        self.delegate = aDelegate;
        self.xmlParser = [[[NSXMLParser alloc] initWithData:data] autorelease];
        [self.xmlParser setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    self.numberOfTopics = 0;
    self.xmlParser = nil;
    self.namePath = nil;
    self.intPath = nil;
    self.booleanPath = nil;
    self.base64Path = nil;
    self.stringPath = nil;
    self.currentString = nil;
    self.path = nil;
    self.currentTopic = nil;
    self.topics = nil;
    self.delegate = nil;
    self.basePath = nil;
    [super dealloc];
}

- (BOOL)parse {
    return [xmlParser parse];
}

#pragma mark -
#pragma mark Base 64 decoding

/*NSString * decodeString(NSString *aString) {
    NSData *stringData = [aString dataUsingEncoding:NSASCIIStringEncoding];
    size_t decodedDataSize = EstimateBas64DecodedDataSize([stringData length]);
    uint8_t *decodedData = calloc(decodedDataSize, sizeof(uint8_t));
    Base64DecodeData([stringData bytes], [stringData length], decodedData, &decodedDataSize);
    
    stringData = [NSData dataWithBytesNoCopy:decodedData length:decodedDataSize freeWhenDone:YES];
    
    NSString *s = [[[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding] autorelease];
    
    
    return s;
    
}*/

#pragma mark-
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
    self.path = [[[NSMutableString alloc] init] autorelease];
    self.topics = [[[NSMutableArray alloc] init] autorelease];
    
    self.stringPath =  [NSString stringWithFormat:@"%@/value/struct/member/value/string", basePath];
    self.intPath =     [NSString stringWithFormat:@"%@/value/struct/member/value/int", basePath];
    self.booleanPath = [NSString stringWithFormat:@"%@/value/struct/member/value/boolean", basePath];
    self.base64Path =  [NSString stringWithFormat:@"%@/value/struct/member/value/base64", basePath];
    self.namePath =    [NSString stringWithFormat:@"%@/value/struct/member/name", basePath];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict {
    self.currentString = [[[NSMutableString alloc] init] autorelease];
    
    if ([self.path isEqualToString:basePath]) {
        if (!isPrefixes) {
            self.currentTopic = [[[Topic alloc] init] autorelease];
        }
    }
    self.path = [self.path stringByAppendingPathComponent:elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"] && [self.currentString isEqualToString:@"total_topic_num"]) {
        isTotalTopicNumber = YES;
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/int"] && isTotalTopicNumber) {
        isTotalTopicNumber = NO;
        self.numberOfTopics = [self.currentString integerValue];
    }
    
    if ([self.path isEqualToString:self.namePath]) {
        if ([self.currentString isEqualToString:@"topic_id"]) {
            isTopicID = YES;
        } else if ([self.currentString isEqualToString:@"topic_title"]) {
            isTopicTitle = YES;
        } else if ([self.currentString isEqualToString:@"forum_id"]) {
            isForumID = YES;
        } else if ([self.currentString isEqualToString:@"new_post"]) {
            isNewPost = YES;
        } else if ([self.currentString isEqualToString:@"reply_number"]) {
            isReplyNumber = YES;
        } else if ([self.currentString isEqualToString:@"is_closed"]) {
            isClosed = YES;
        } else if ([self.currentString isEqualToString:@"is_subscribed"]) {
            isSubscribed = YES; 
        }
    } else if ([self.path isEqualToString:self.base64Path]) {
        // First decode base64 data
        self.currentString = (NSMutableString *)decodeString(self.currentString);
        if (isTopicTitle) {
            isTopicTitle = NO;
            self.currentTopic.title = self.currentString;
        }
        
    } else if ([self.path isEqualToString:self.stringPath]) {
        if (isForumID) {
            isForumID = NO;
            self.currentTopic.forumID = [self.currentString intValue];
        }
        
        if (isTopicID) {
            isTopicID = NO;
            self.currentTopic.topicID = [self.currentString intValue];
        }
        
    } else if ([self.path isEqualToString:self.booleanPath]) {
        if (isNewPost) {
            isNewPost = NO;
            self.currentTopic.hasNewPost = [self.currentString boolValue];
        } else if (isClosed) {
            isClosed = NO;
            self.currentTopic.closed = [self.currentString boolValue];
        } else if (isSubscribed) {
            isSubscribed = NO;
            self.currentTopic.subscribed = [self.currentString boolValue];
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"] && [self.currentString isEqualToString:@"prefixes"]) {
        isPrefixes = YES;
    } else if ([self.path isEqualToString:self.intPath]) {
        if (isReplyNumber) {
            isReplyNumber = NO;
            self.currentTopic.numberOfPosts = [self.currentString integerValue]+1;
        }
    }
    
    self.path = [self.path stringByDeletingLastPathComponent];
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value"] && isPrefixes) {
        isPrefixes = NO;
    } else if ([self.path isEqualToString:self.basePath]) {
        if (self.currentTopic != nil)
            [self.topics addObject:self.currentTopic];
    }
    
    self.currentString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.delegate topicParserDidFinish:self.topics];
    self.currentTopic = nil;
    self.topics = nil;
    self.path = nil;
    self.basePath = nil;
    self.base64Path = nil;
    self.booleanPath = nil;
    self.intPath = nil;
    self.stringPath = nil;
}
@end
