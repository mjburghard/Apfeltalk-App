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
@synthesize loggedIn, username, password, receivedData;

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    XMLRPCResponseParser *parser = [XMLRPCResponseParser parserWithData:self.receivedData delegate:self];
    [parser parse];
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
    if (self.username == nil || self.password == nil) {
        NSLog(@"No username or password set");
        return;
    } else if (self.loggedIn) {
        return;
    }

    NSURL *url = [NSURL URLWithString:ATTapatalkPluginPath];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>login</methodName><params><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", encodeString(self.username), encodeString(self.password)];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.receivedData = [NSMutableData data];
    [connection start];
    [connection release];
}

- (void)logout {
    self.username = nil;
    self.password = nil;
    self.loggedIn = NO;
    NSURL *url = [NSURL URLWithString:ATTapatalkPluginPath];
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

- (void)parserDidFinishWithObject:(NSObject *)dictionaryOrArray ofType:(XMLRPCResultType)type {
    if (type == XMLRPCResultTypeDictionary) {
        NSDictionary *dictionary = (NSDictionary *)dictionaryOrArray;
        NSNotification *notification;
        if ([[dictionary valueForKey:@"result"] boolValue]) {
            [[User sharedUser] setLoggedIn:YES];
            [self storeKeychainItem];
            notification = [NSNotification notificationWithName:@"ATLoginWasSuccessful" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        } else {
            [[User sharedUser] setLoggedIn:NO];
            notification = [NSNotification notificationWithName:@"ATLoginDidFail" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        
        notification = [NSNotification notificationWithName:@"ATLoginDidFinish" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)parser:(XMLRPCResponseParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@: %@", ATLocalizedString(@"Error", nil), [parseError localizedDescription]);
    [[User sharedUser] setLoggedIn:NO];
    NSNotification *notification = [NSNotification notificationWithName:@"ATLoginDidFail" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    notification = [NSNotification notificationWithName:@"ATLoginDidFinish" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
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
    self.receivedData = nil;
    self.username = nil;
    self.password = nil;
    self.loggedIn = NO;
    [super dealloc];
}

@end
