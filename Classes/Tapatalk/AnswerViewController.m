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
    NSURL *url = [NSURL URLWithString:@"http://apfeltalk.de/forum/mobiquo/mobiquo.php/"];
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
        self.receivedData = [[NSMutableData alloc] init];
    }
    self.textView.text = @"";
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
    NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:[NSURL URLWithString:@"http://.apfeltalk.de"]];
    if ([all count] > 0) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:all forURL:[NSURL URLWithString:@"http://.apfeltalk.de"] mainDocumentURL:nil]; 
    }
    
    if ([[headers valueForKey:@"Mobiquo_is_login"] isEqualToString:@"false"] && [[User sharedUser] isLoggedIn]) {
        [(Apfeltalk_MagazinAppDelegate *)[UIApplication sharedApplication].delegate login];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Answer", @"Atlocalizable", @"") style:UIBarButtonItemStyleDone target:self action:@selector(reply)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 10.0, self.view.frame.size.width, self.view.frame.size.height-270.0)];
    self.textView.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    
    [self.view addSubview: self.textView];
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [self cancel];
}

@end
