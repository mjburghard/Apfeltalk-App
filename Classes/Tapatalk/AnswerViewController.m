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
@synthesize textView, topic, receivedData;

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
    
    ContentTranslator *translator = [[ContentTranslator alloc] init];
    
    NSString *content = [translator translateStringForAT:self.textView.text];
    [translator release];
    NSURL *url = [NSURL URLWithString:@"http://www.apfeltalk.de/forum/mobiquo/mobiquo.php"];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>reply_post</methodName><params><param><value><string>%i</string></value></param><param><value><string>%i</string></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", self.topic.forumID, 
                           self.topic.topicID, 
                           encodeString(@"answer"), 
                           encodeString(content)];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    
    NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://www.apfeltalk.de"]];
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
        self.receivedData = [[NSMutableData alloc] init];
    }
}

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.receivedData];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    [pool release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ForumViewController *forumViewController = (ForumViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    [forumViewController login];
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
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(parse) object:nil];
    [thread start];
    [thread release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Answer", @"ATLocalizable", @"");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Answer", @"ATLocalizable", @"") style:UIBarButtonItemStyleDone target:self action:@selector(reply)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.textView = [[UITextView alloc] init];
    
    CGFloat keyboardHeight;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        NSLog(@"Landscape");
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
    /*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);*/
    return YES;
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

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (isNotLoggedIn) {
        isNotLoggedIn = NO;
        [self reply];
    } else {
        [self.textView performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(cancel) withObject:nil waitUntilDone:NO];
    }
}

@end
