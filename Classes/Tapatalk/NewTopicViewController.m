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
@synthesize forum, receivedData, topicField;

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
    self.receivedData = nil;
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
    if (![[User sharedUser] isLoggedIn]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"ATLocalizable", @"") message:NSLocalizedStringFromTable(@"Please login...", @"ATLocalizable", @"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    ContentTranslator *translator = [ContentTranslator new];
    
    NSString *title = [translator translateStringForAT:self.topicField.text];
    NSString *content = [translator translateStringForAT:self.textView.text];
    
    NSURL *url = [NSURL URLWithString:@"http://apfeltalk.de/forum/mobiquo/mobiquo.php/"];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>new_topic</methodName><params><param><value><string>%i</string></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", self.forum.forumID, 
                           encodeString(title), 
                           encodeString(content)];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    if (connection) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    self.textView.text = @"";
    NSArray *viewControllers = self.navigationController.viewControllers;
    [(SubForumController *)[viewControllers objectAtIndex:[viewControllers count]-2] loadData];
    [self cancel];
}

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.receivedData];
    [parser setDelegate:self];
    [parser parse];
    
    [pool release];
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *s = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);
    
    /*NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(parse) object:nil];
    [thread start];
    [thread release];*/
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.topicField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 0, self.view.frame.size.width-20.0, 31)];
    self.topicField.placeholder = NSLocalizedStringFromTable(@"Title", @"ATLocalizable", @"");
    [self.topicField becomeFirstResponder];
    
    [self.view addSubview:self.topicField];
    
    self.textView.frame = CGRectMake(0.0, 32.0, self.view.frame.size.width, self.view.frame.size.height-302.0);
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 31.0, self.view.frame.size.width, 1.0)];
    seperator.backgroundColor = [UIColor grayColor];
    [self.view addSubview:seperator];
    self.navigationItem.title = NSLocalizedStringFromTable(@"New Topic", @"ATLocalizable", @"");
    self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Create", @"ATLocalizable", @"");
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
/*
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
    [parser release];
}
*/
@end
