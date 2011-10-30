//
//  ATTableViewController.m
//  
//
//  Created by Manuel Burghard on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATTableViewController.h"

@implementation ATTableViewController
@synthesize receivedData, usernameTextField, passwordTextField, isNotLoggedIn, requestParameters, isSending;

#pragma mark -
#pragma mark Memory managment methods

- (void)setDefaultBehavior {
    self.hidesBottomBarWhenPushed = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideTabBar"];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setDefaultBehavior];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setDefaultBehavior];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self setDefaultBehavior];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaultBehavior];
    }
    return self;
}

- (void)dealloc {
    self.isSending = NO;
    self.requestParameters = nil;
    self.isNotLoggedIn = NO;
    self.usernameTextField = nil;
    self.passwordTextField = nil;
    self.receivedData = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Public & private methods

- (NSString *)tapatalkPluginPath {
    return ATTapatalkPluginPath;
}

- (void)showAlertViewWithErrorString:(NSString *)errorString {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ATLocalizedString(@"Error", nil) message:errorString delegate:nil cancelButtonTitle:ATLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

- (void)showAlertViewWithError:(NSError *)error {
    [self showAlertViewWithErrorString:[error localizedDescription]];
}

- (void)handleErrorString:(NSString *)errorString {
    NSLog(@"%@: %@", ATLocalizedString(@"Error", nil), errorString);
    [self showAlertViewWithErrorString:errorString];
}

- (void)handleError:(NSError *)error {
    [self handleErrorString:[error localizedDescription]];
}

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    XMLRPCResponseParser *parser = [[XMLRPCResponseParser alloc] initWithData:self.receivedData delegate:self];
    [parser parse];
    [parser release];
    self.receivedData = nil;
    [pool release];
}

- (void)sendRequestWithXMLString:(NSString *)xmlString cookies:(BOOL)cookies delegate:(id)delegate {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:xmlString forKey:@"XMLString"];
    [dict setValue:[NSNumber numberWithBool:cookies] forKey:@"Cookies"];
    [dict setValue:delegate forKey:@"Delegate"];
    self.requestParameters = dict;
    [dict release];
    NSURL *url = [NSURL URLWithString:[self tapatalkPluginPath]];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if ([[User sharedUser] isLoggedIn] && cookies) {
        NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://.apfeltalk.de"]];
        NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
        [request setAllHTTPHeaderFields:headers];
    }
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
}

- (void)sendRequestAgain {
    if (isNotLoggedIn) {
        NSLog(@"Sent request again");
        self.isNotLoggedIn = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ATLoginWasSuccessful" object:nil];
        NSString *xmlString = [self.requestParameters valueForKey:@"XMLString"];
        BOOL cookies = [(NSNumber *)[self.requestParameters valueForKey:@"cookies"] boolValue];
        id delegate = [self.requestParameters valueForKey:@"Delegate"];
        
        [self sendRequestWithXMLString:xmlString cookies:cookies delegate:delegate];
    }
}

- (void)login {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Please login...", @"ATLocalizable", @"") 
                                                        message:@"\n\n\n" 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") 
                                              otherButtonTitles:NSLocalizedStringFromTable(@"Login", @"ATLocalizable", @""), nil];
    alertView.tag = 0;
    UITextField *uField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    UITextField *pField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 75.0, 260.0, 25.0)];
    self.usernameTextField = uField;
    self.passwordTextField = pField;
    [usernameTextField setBackgroundColor:[UIColor whiteColor]];
    [passwordTextField setBackgroundColor:[UIColor whiteColor]];
    usernameTextField.placeholder = NSLocalizedStringFromTable(@"Username", @"ATLocalizable", @"");
    passwordTextField.placeholder = NSLocalizedStringFromTable(@"Password", @"ATLocalizable", @"");
    passwordTextField.secureTextEntry = YES;
    
    [alertView addSubview:usernameTextField];
    [alertView addSubview:passwordTextField];
    [usernameTextField becomeFirstResponder];
    
    [alertView show];
    [alertView release];
    [uField release];
    [pField release];
}

- (void)logout {
    [[User sharedUser] logout];
}

- (void)showActionSheet {
    
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 0:
            if (buttonIndex == 1 && [usernameTextField.text length] != 0 &&  [passwordTextField.text length] != 0) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidFail) name:@"ATLoginDidFail" object:nil];
                [[User sharedUser] setUsername:usernameTextField.text];
                [[User sharedUser] setPassword:passwordTextField.text];
                [[User sharedUser] login];
            } 
            
            [usernameTextField resignFirstResponder];
            [passwordTextField resignFirstResponder];
            self.usernameTextField = nil;
            self.passwordTextField = nil;
            break;
        case 1:
            if (buttonIndex == 1) {
                [self login];
            }
            break;
        default:
            break;
    }
}

#pragma mark -

- (void)loginDidFail {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"ATLocalizable", @"") 
                                                        message:NSLocalizedStringFromTable(@"Wrong username or password", @"ATLocalizable", @"") 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") 
                                              otherButtonTitles:NSLocalizedStringFromTable(@"Retry", @"ATLocalizable", @""), nil];
    alertView.tag = 1;
    [alertView show];
    [alertView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ATLoginDidFail" object:nil];
}

#pragma mark -
#pragma mark XMLRPCResponseDelegate

- (void)parserDidFinishWithObject:(NSObject *)dictionaryOrArray ofType:(XMLRPCResultType)type {

}

- (void)parser:(XMLRPCResponseParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self handleError:parseError];
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
        self.isNotLoggedIn = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendRequestAgain) name:@"ATLoginWasSuccessful" object:nil];
        [[User sharedUser] setLoggedIn:NO];
        [[User sharedUser] login];
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connvection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    unsigned long length = [self.receivedData length];
    NSLog(@"Received length: %lu", length);
    if ([self.receivedData length] != 0) {
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(parse) object:nil];
        [thread start];
        [thread release];
    } else {
        [self.tableView reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
    [self handleError:error];
}

#pragma mark -
#pragma mark TTMessageControllerDelegate

- (void)composeControllerWillCancel:(TTMessageController *)controller {
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)composeControllerShowRecipientPicker:(TTMessageController *)controller {
    ATContactDataSource *dataSource = (ATContactDataSource *)[controller dataSource];
    ATContactModel *model = [dataSource contactModel];
    NSMutableArray *onlineUsers =  model.onlineUsers;
    NSArray *titles = [NSArray arrayWithObjects:ATLocalizedString(@"Online Users", nil), nil];
    NSArray *groups = [NSArray arrayWithObjects:onlineUsers, nil];
    ATContactPicker *contactPicker = [[ATContactPicker alloc] initWithStyle:UITableViewStylePlain groups:groups titles:titles];
    contactPicker.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactPicker];
    navigationController.navigationBar.tintColor = ATNavigationBarTintColor;
    [contactPicker tableView:contactPicker.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [controller presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [contactPicker release];
}

- (void)composeController:(TTMessageController *)controller didSendFields:(NSArray *)fields {
    NSMutableString *recipients = [NSMutableString string];
    for (NSObject *item in [(TTMessageRecipientField *)[fields objectAtIndex:0] recipients]) {
        if ([item isKindOfClass:[TTTableTextItem class]]) {
            [recipients appendString:[NSString stringWithFormat:@"<value><base64>%@</base64></value>", encodeString([(TTTableTextItem *)item text])]];
        } else if ([item isKindOfClass:[NSString class]]) {
            [recipients appendString:[NSString stringWithFormat:@"<value><base64>%@</base64></value>", encodeString((NSString *)item)]];
        }
    }
    ContentTranslator *translator = [ContentTranslator contentTranslator];
    NSString *subject = [(TTMessageTextField *)[fields objectAtIndex:1] text];
    NSString *message = [(TTMessageTextField *)[fields lastObject] text];
    subject = [translator translateStringForAT:subject];
    message = [translator translateStringForAT:message];
    
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>create_message</methodName><params><param><value><array><data>%@</data></array></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", recipients, encodeString(subject), encodeString(message)];
    self.isSending = YES;
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

#pragma mark -
#pragma mark ATContactPickerDelegate

- (void)contactPicker:(ATContactPicker *)contactPicker didSelectContact:(NSString *)contactName {
    TTMessageController *messageController = (TTMessageController *)[[(UINavigationController *)self.modalViewController viewControllers] objectAtIndex:0];
    [messageController addRecipient:contactName forFieldAtIndex:0];
    [messageController dismissModalViewControllerAnimated:YES];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = NSLocalizedStringFromTable(@"Back", @"ATLocalizable", @"");
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[SHKActivityIndicator currentIndicator] hide];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (loadingCell  == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
    }
    return loadingCell;
}

#pragma mark -
#pragma mark Orientation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
