//
//  ATMXMLUtilities.h
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 21.09.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>


@interface ATMXMLUtilities : NSObject
{
    xmlDocPtr theXMLDoc;
}

@property (nonatomic, retain) NSDictionary *xPaths;

+ (ATMXMLUtilities *)xmlUtilitiesWithURLString:(NSString *)urlString;

- (id)initWithURLString:(NSString *)urlString;

- (NSString *)authorName;
- (NSString *)articleContent;
- (NSArray *)articlePagesLinks;
- (NSInteger)topicIDOfCommentsTopic;

- (NSString *)extractTextForQuery:(NSString *)query;

@end

NSString *extractTextFromHTMLForQuery (NSString *htmlInput, NSString *query);
NSArray *extractNodesFromHTMLForQuery (NSString *htmlInput, NSString *query);