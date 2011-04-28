//
//  UserXMLParser.m
//  Tapatalk
//
//  Created by Manuel Burghard on 25.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserXMLParser.h"
#import "User.h"


@implementation UserXMLParser
@synthesize currentString, receivedData, path, delegate;

#pragma mark-
#pragma mark init & dealloc

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)theDelegate {
    self = [super init];
    if (self) {
        self.delegate = theDelegate;
        self.path = @"";
        self.receivedData = [NSMutableData data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.path = nil;
    self.receivedData = nil;
    self.currentString = nil;
    [super dealloc];
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    /*NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
     for (NSString *s in [headerFields allKeys]) {
     NSLog(@"%@", s);
     }
     for (NSString *s in [headerFields allValues]) {
     NSLog(@"%@", s);
     }*/
}

- (void)connection:(NSURLConnection *)connvection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.receivedData];
    [parser setDelegate:self];
    [parser parse];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
    NSLog(@"Connection error: %@", [error localizedDescription]);
}


#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.path = [self.path stringByAppendingPathComponent:elementName];
    self.currentString = [NSMutableString new];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentString appendString:string];
    //NSLog(@"%@, %@", self.path, self.currentString);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"] && [self.currentString isEqualToString:@"result"]) {
        isResult = YES;
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/boolean"] && isResult) {
        isResult = NO;
        if ([self.currentString isEqualToString:@"1"]) {
            [[User sharedUser] setLoggedIn:YES];
        }
        if ([self.currentString isEqualToString:@"0"]) {
            [[User sharedUser] setLoggedIn:NO];
        }
        
        BOOL result = [[User sharedUser] isLoggedIn];
        
        [self.delegate userIsLoggedIn:result];
    
    }
    
    self.path = [self.path stringByDeletingLastPathComponent];
    self.currentString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.delegate userXMLParserDidFinish];
}

@end
