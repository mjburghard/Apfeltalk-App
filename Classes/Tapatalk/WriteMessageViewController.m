//
//  WriteMessageViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 21.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WriteMessageViewController.h"
#import "ContentTranslator.h"
#import "User.h"

@implementation WriteMessageViewController
@synthesize receivedData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    self.receivedData = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Private methods

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)send {
    /*NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>create_message</methodName><params><param><value><array><data><value><string>Unkaputtbar</string></value></data></array></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", encodeString(@"Test"), encodeString(@"Test")];
    NSURL *url = [NSURL URLWithString:ATTapatalkPluginPath];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if ([[User sharedUser] isLoggedIn] && YES) {
        NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://.apfeltalk.de"]];
        NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
        [request setAllHTTPHeaderFields:headers];
    }
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    [self cancel];*/
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.receivedData = [NSMutableData data];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *headers = [httpResponse allHeaderFields];
    NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:[NSURL URLWithString:@"http://.apfeltalk.de"]];
    if ([all count] > 0) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:all forURL:[NSURL URLWithString:@"http://.apfeltalk.de"] mainDocumentURL:nil]; 
    }
    if ([[headers valueForKey:@"Mobiquo_is_login"] isEqualToString:@"false"] && [[User sharedUser] isLoggedIn]) {
        [[User sharedUser] setLoggedIn:NO];
        [[User sharedUser] login];
    }
}

- (void)connection:(NSURLConnection *)connvection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    unsigned long length = [self.receivedData length];
    NSLog(@"Received length: %lu", length);
    if ([self.receivedData length] != 0) {
    } else {
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
    NSLog(@"%@", [error localizedDescription]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", ATLocalizable, @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:ATLocalizedString(@"Send", @"") style:UIBarButtonItemStyleDone target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    [sendButton release];
    [cancelButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;

    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
