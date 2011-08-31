//
//  ATContactModel.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATContactModel.h"

@implementation ATContactModel

@synthesize searchResults, receivedData, onlineUsers, isLoading;

- (id)init {
    if (self = [super init]) {
        TT_RELEASE_SAFELY(delegates);
        self.searchResults = nil;
        self.isLoading = YES;
        self.onlineUsers = [NSMutableArray array];
        
        NSURL *url = [NSURL URLWithString:ATTapatalkPluginPath];
        NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_online_users</methodName></methodCall>"];
        NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
    }
    return self;
}

- (void)dealloc {
    self.isLoading = NO;
    self.onlineUsers = nil;
    self.receivedData = nil;
    TT_RELEASE_SAFELY(delegates);
    self.searchResults = nil;
    [super dealloc];
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    XMLRPCResponseParser *parser = [XMLRPCResponseParser parserWithData:self.receivedData delegate:self];
    [parser parse];
    self.receivedData = nil;
    self.isLoading = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    ATLogError(error);
    self.isLoading = NO;
}

#pragma mark -
#pragma mark XMLRPCResponseParserDelegate

- (void)parserDidFinishWithObject:(NSObject *)dictionaryOrArray ofType:(XMLRPCResultType)type {
    NSDictionary *dictionary = (NSDictionary *)dictionaryOrArray;
    [self.onlineUsers removeAllObjects];
    for (NSDictionary *dict in [dictionary valueForKey:@"list"]) {
        [self.onlineUsers addObject:[dict valueForKey:@"user_name"]];
    }
}

- (void)parser:(XMLRPCResponseParser *)parser parseErrorOccurred:(NSError *)parseError {
    ATLogError(parseError);
}

- (NSMutableArray*)delegates {
    if (!delegates) {
        delegates = TTCreateNonRetainingArray();
    }
    return delegates;
}

- (BOOL)isLoadingMore {
    return NO;
}

- (BOOL)isOutdated {
    return NO;
}

- (BOOL)isLoaded {
    return !isLoading;
}

- (BOOL)isEmpty {
    return !searchResults.count;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}

- (void)invalidate:(BOOL)erase {
    
}

- (void)cancel {
    [delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}


- (void)search:(NSString*)text {
    [self cancel];
    
    if (text.length) {
        [delegates perform:@selector(modelDidStartLoad:) withObject:self];
        self.searchResults = [NSMutableArray array];
        for (NSString *name in self.onlineUsers) {
            if ([name rangeOfString:text options:NSCaseInsensitiveSearch].location == 0) {
                [self.searchResults addObject:name];
            }
        }
        [delegates perform:@selector(modelDidFinishLoad:) withObject:self];
        
    } else {
        self.searchResults = nil;
    }
    [delegates perform:@selector(modelDidChange:) withObject:self];
} 

@end