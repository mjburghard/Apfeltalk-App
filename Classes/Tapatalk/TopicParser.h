//
//  TopicParser.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 29.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"
#import "ContentTranslator.h"

@protocol TopicParserDelegate
@required
- (void)topicParserDidFinish:(NSMutableArray *)topics;

@end

@interface TopicParser : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentString;
    NSString *path;
    NSString *basePath;
    NSInteger numberOfTopics;
    NSXMLParser *xmlParser;
    
    id <TopicParserDelegate> delegate;
    Topic *currentTopic;
    NSMutableArray *topics;
    BOOL isForumID, isTopicID, isTopicTitle, isPrefixes, isNewPost, isReplyNumber, isClosed, isSubscribed, isTotalTopicNumber;
    
    NSString *intPath, *stringPath, *booleanPath, *base64Path, *namePath;
}

@property (retain) NSXMLParser *xmlParser;
@property (retain) NSMutableString *currentString;
@property (retain) NSString *path;
@property (retain) NSString *basePath;
@property (assign) NSInteger numberOfTopics;
@property (assign) id <TopicParserDelegate> delegate;
@property (retain) Topic *currentTopic;
@property (retain) NSMutableArray *topics;
@property (retain) NSString *intPath;
@property (retain) NSString *stringPath;
@property (retain) NSString *booleanPath;
@property (retain) NSString *base64Path;
@property (retain) NSString *namePath;

- (id)initWithData:(NSData *)data basePath:(NSString *)aBasePath delegate:(id)aDelegate;
- (BOOL)parse;
@end
