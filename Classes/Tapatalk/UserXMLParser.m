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
@synthesize currentString, receivedData, path, delegate, parser, connection;

#pragma mark-
#pragma mark init & dealloc

- (id)init {
    self = [super init];
    if (self) {
        isLoading = NO;
        isParsing = NO;
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)theDelegate {
    self = [self init];
    if (self) {
        self.delegate = theDelegate;
        self.path = @"";
        self.receivedData = [NSMutableData data];
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self.connection start];
        isLoading = YES;
        isParsing = NO;
    }
    return self;
}

- (void)abortParsing {
    [self.parser abortParsing];
}

- (void)dealloc {
    self.connection = nil;
    self.parser = nil;
    self.delegate = nil;
    self.path = nil;
    self.receivedData = nil;
    self.currentString = nil;
    [super dealloc];
}

- (BOOL)isWorking {
    BOOL isWorking = isParsing || isLoading;
    if (isWorking) {
        NSLog(@"Is working");
    } else {
        NSLog(@"Is not working");
    }
    return isWorking;
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *headers = [httpResponse allHeaderFields];
    NSLog(@"Response: %@", headers);
    NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:[NSURL URLWithString:@"http://www.apfeltalk.de"]];
    if ([all count] > 0) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:all forURL:[NSURL URLWithString:@"http://www.apfeltalk.de"] mainDocumentURL:nil]; 
    }
}

- (void)connection:(NSURLConnection *)connvection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.parser = [[[NSXMLParser alloc] initWithData:self.receivedData] autorelease];
    [parser setDelegate:self];
    isParsing = YES;
    isLoading = NO;
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
    isParsing = NO;
}

@end
