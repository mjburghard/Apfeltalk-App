//
//  AnswerViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 14.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnswerViewController.h"
#import "DetailThreadController.h"
#import "Apfeltalk_MagazinAppDelegate.h"

@implementation AnswerViewController
@synthesize textView, topic, receivedData, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topic:(Topic *)aTopic
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.topic = aTopic;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)dealloc
{
    self.activityIndicator = nil;
    self.receivedData = nil;
    self.textView = nil;
    self.topic = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Private Methods

- (void)handleError:(NSError *)error {
    NSLog(@"%@: %@", ATLocalizedString(@"Error", nil), [error localizedDescription]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ATLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:ATLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reply {
    if ([self.textView.text length] ==0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"ATLocalizable", @"") message:NSLocalizedStringFromTable(@"No text entered", @"ATLocalizable", @"") delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    if (![[User sharedUser] isLoggedIn]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"ATLocalizable", @"") message:NSLocalizedStringFromTable(@"Please login...", @"ATLocalizable", @"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    if (!activityIndicator) {
        self.activityIndicator = [ATActivityIndicator alloc];
        self.activityIndicator.messageLabel.text = ATLocalizedString(@"Sending...", nil);
        self.activityIndicator.center = self.view.center;
        [self.activityIndicator startAnimating];
        [self.view addSubview:self.activityIndicator];
    }
    
    [self.textView resignFirstResponder];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.textView.editable = NO;
    
    ContentTranslator *translator = [[ContentTranslator alloc] init];
    
    NSString *content = [translator translateStringForAT:self.textView.text];
    [translator release];
    NSURL *url = [NSURL URLWithString:ATTapatalkPluginPath];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>reply_post</methodName><params><param><value><string>%i</string></value></param><param><value><string>%i</string></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", self.topic.forumID, 
                           self.topic.topicID, 
                           encodeString(@"answer"), 
                           encodeString(content)];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    
    NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://apfeltalk.de"]];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];    
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    if (connection) {
        self.receivedData = [NSMutableData data];
    }
}

- (void)parse {
    XMLRPCResponseParser *parser = [XMLRPCResponseParser parserWithData:self.receivedData delegate:self];
    [parser parse];
    self.receivedData = nil;
}
#pragma mark -
#pragma mark XMLRPCResponseDelegate

- (void)parserDidFinishWithObject:(NSObject *)dictionaryOrArray ofType:(XMLRPCResultType)type {
    NSLog(@"%@", dictionaryOrArray);
    if (isNotLoggedIn) {
        isNotLoggedIn = NO;
        [self reply];
    } else if (type == XMLRPCResultTypeDictionary) {
        NSDictionary *dictionary = (NSDictionary *)dictionaryOrArray;
        [self.activityIndicator stopAnimating];
        [self.activityIndicator dismiss];
        self.activityIndicator = nil;
        if ([[dictionary valueForKey:@"result"] boolValue]) {
            [self cancel];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ATLocalizedString(@"Error", nil) message:ATLocalizedString(@"An unexpected error occurred. Please try later.", nil) delegate:self cancelButtonTitle:ATLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        }
    }
}

- (void)parser:(XMLRPCResponseParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self handleError:parseError];
}

#pragma mark-
#pragma mark UIAlertViewDelegate 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self cancel];
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
    
    if ([[headers valueForKey:@"Mobiquo_is_login"] isEqualToString:@"false"] && [[User sharedUser] isLoggedIn]) {
        [[User sharedUser] setLoggedIn:NO];
        [[User sharedUser] login];
        isNotLoggedIn = YES;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self parse];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self handleError:error];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Answer", @"ATLocalizable", @"");
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Answer", @"ATLocalizable", @"") style:UIBarButtonItemStyleDone target:self action:@selector(reply)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    [rightBarButton release];
    [leftBarButton release];
    self.textView = [[[UITextView alloc] init] autorelease];
    
    CGFloat keyboardHeight;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        keyboardHeight = 162.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            keyboardHeight = 352.0;
        } 
    } else {
        keyboardHeight = 216.0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            keyboardHeight = 264.0;
        }
    }
    CGFloat height = self.view.frame.size.height - keyboardHeight;
    
    self.textView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, height);
    self.textView.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.textView];
    [self.textView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect frame = self.textView.frame;
    CGFloat keyboardHeight;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        keyboardHeight = 162.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
             keyboardHeight = 352.0;
        } 
    } else {
        keyboardHeight = 216.0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            keyboardHeight = 264.0;
        }
    }
    frame.size.height = self.view.frame.size.height-keyboardHeight;
    self.textView.frame = frame;
}

@end
