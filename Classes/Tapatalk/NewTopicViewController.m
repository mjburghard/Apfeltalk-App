//
//  NewTopicViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 14.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewTopicViewController.h"
#import "SubForumController.h"


@implementation NewTopicViewController
@synthesize forum, topicField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forum:(SubForum *)aForum
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.forum = aForum;
    }
    return self;
}

- (void)dealloc
{
    self.topicField = nil;
    self.forum = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)cancel {
    [super cancel];
}

- (void)reply {
    if ([self.topicField.text length] == 0 || [self.textView.text length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"ATLocalizable", @"") message:NSLocalizedStringFromTable(@"No title or text entered", @"ATLocalizable", @"") delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
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
    
    ContentTranslator *translator = [ContentTranslator new];
    
    NSString *title = [translator translateStringForAT:self.topicField.text];
    NSString *content = [translator translateStringForAT:self.textView.text];
    [translator release];
    NSURL *url = [NSURL URLWithString:@"http://www.apfeltalk.de/forum/mobiquo/mobiquo.php"];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>new_topic</methodName><params><param><value><string>%i</string></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", self.forum.forumID, 
                           encodeString(title), 
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.topicField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 0, self.view.frame.size.width-20.0, 31)];
    self.topicField.placeholder = NSLocalizedStringFromTable(@"Title", @"ATLocalizable", @"");
    self.topicField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.textView resignFirstResponder];
    [self.topicField becomeFirstResponder];
    
    [self.view addSubview:self.topicField];
    
    CGFloat keyboardHeight;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        NSLog(@"Landscape");
        keyboardHeight = 194.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            keyboardHeight = 384.0;
        } 
    } else {
        keyboardHeight = 248.0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            keyboardHeight = 296.0;
        }
    }
    CGFloat height = self.view.frame.size.height - keyboardHeight;
    
    self.textView.frame = CGRectMake(0.0, 32.0, self.view.frame.size.width, height);
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 31.0, self.view.frame.size.width, 1.0)];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    seperator.backgroundColor = [UIColor grayColor];
    [self.view addSubview:seperator];
    [seperator release];
    self.navigationItem.title = NSLocalizedStringFromTable(@"New Topic", @"ATLocalizable", @"");
    self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Create", @"ATLocalizable", @"");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect frame = self.textView.frame;
    CGFloat keyboardHeight;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        NSLog(@"Landscape");
        keyboardHeight = 194.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            keyboardHeight = 384.0;
        } 
    } else {
        keyboardHeight = 248.0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            keyboardHeight = 296.0;
        }
    }
    frame.size.height = self.view.frame.size.height-keyboardHeight;
    self.textView.frame = frame;
}

@end
