//
//  User.m
//  Tapatalk
//
//  Created by Manuel Burghard on 25.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "ForumViewController.h"

@implementation User
SYNTHESIZE_SINGLETON_FOR_CLASS(User)
@synthesize loggedIn, username, password, path, parser, currentString, receivedData;

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.parser = [[NSXMLParser alloc] initWithData:self.receivedData];
    [parser setDelegate:self];
    [parser parse];
    self.parser = nil;
    self.receivedData = nil;
    [pool release];
}

- (void)deleteKeychainItem {
    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"ATUsername"] andServiceName:@"Apfeltalk" error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"ATUsername"];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)storeKeychainItem {
    NSError *error = nil;
    [SFHFKeychainUtils storeUsername:self.username andPassword:self.password forServiceName:@"Apfeltalk" updateExisting:NO error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:self.username forKey:@"ATUsername"];
    }
}

- (void)deleteCookies {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://.apfeltalk.de"]];
    for (NSHTTPCookie *c in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:c];
    }
}

- (void)login {
    if (self.username == nil || self.password ==nil) {
        NSLog(@"No username or password set");
        return;
    } else if (self.loggedIn) {
        return;
    }

    NSURL *url = [NSURL URLWithString:@"http://apfeltalk.de/forum/mobiquo/mobiquo.php/"];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>login</methodName><params><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", encodeString(self.username), encodeString(self.password)];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.receivedData = [[NSMutableData alloc] init];
    [connection start];
    [connection release];
}

- (void)logout {
    self.username = nil;
    self.password = nil;
    self.loggedIn = NO;
    NSURL *url = [NSURL URLWithString:@"http://www.apfeltalk.de/forum/mobiquo/mobiquo.php"];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>logout_user</methodName></methodCall>"];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:nil];
    [connection start];
    [connection release];
    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"ATUsername"] andServiceName:@"Apfeltalk" error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"ATUsername"];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [self deleteCookies];
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.path = [self.path stringByAppendingPathComponent:elementName];
    self.currentString = [NSMutableString new];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"] && [self.currentString isEqualToString:@"result"]) {
        isResult = YES;
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/boolean"] && isResult) {
        isResult = NO;
        if ([self.currentString isEqualToString:@"1"]) {
            [[User sharedUser] setLoggedIn:YES];
            [self storeKeychainItem];
        }
        if ([self.currentString isEqualToString:@"0"]) {
            [[User sharedUser] setLoggedIn:NO];
            NSNotification *notfification = [NSNotification notificationWithName:@"ATLoginDidFail" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notfification];
        }
    }
    self.path = [self.path stringByDeletingLastPathComponent];
    self.currentString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *headers = [httpResponse allHeaderFields];
    NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:[NSURL URLWithString:@"http://.apfeltalk.de"]];
    if ([all count] > 0) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:all forURL:[NSURL URLWithString:@"http://.apfeltalk.de"] mainDocumentURL:nil]; 
    }
}

- (void)connection:(NSURLConnection *)connvection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(parse) object:nil];
    [thread start];
    [thread release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
    NSLog(@"Connection error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark init & dealloc

- (id)init {
    self = [super init];
    if (self) {
        self.path = [[NSMutableString alloc] init];
        self.username = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ATUsername"];
        if (username != nil && ![username isEqualToString:@""]) {
            NSError *error = nil;
            self.password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:@"Apfeltalk" error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
    }
    return self;
}

- (void)dealloc {
    self.parser = nil;
    self.currentString = nil;
    self.receivedData = nil;
    self.path = nil;
    self.username = nil;
    self.password = nil;
    self.loggedIn = NO;
    [super dealloc];
}

@end
