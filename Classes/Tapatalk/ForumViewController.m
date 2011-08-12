//
//  ForumViewController.m
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ForumViewController.h"
#import "Base64Transcoder.h"
#import "SubForum.h"
#import "Section.h"
#import "SubForumController.h"
#import "Apfeltalk_MagazinAppDelegate.h"
#import "NewPostsViewController.h"

#define ATLocalizable @"ATLocalizable"
#define ATLocalizedString(key, comment) NSLocalizedStringFromTable((key), ATLocalizable, (comment))

@implementation ForumViewController
@synthesize receivedData, sections, currentString, path, currentSection, currentFirstLevelForum, currentSecondLevelForum, currentThirdLevelForum, currentObject, dataArray, searchBar, searchTableViewController;

NSString* const kSectionPath = @"methodResponse/params/param/value/array/data";
NSString* const kFirstLevelForumPath = @"methodResponse/params/param/value/array/data/value/struct/member/value/array/data";
NSString* const kSecondLevelForumPath = @"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data";
NSString* const kThirdLevelForumPath = @"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data";

#pragma mark -
#pragma mark init & dealloc

- (void)dealloc {
    self.searchTableViewController = nil;
    self.searchBar = nil;
    self.dataArray = nil;
    self.currentObject = nil;
    self.currentThirdLevelForum = nil;
    self.currentSecondLevelForum = nil;
    self.path = nil;
    self.currentSection = nil;
    self.currentFirstLevelForum = nil;
    self.currentString = nil;
    self.sections = nil;
    self.receivedData = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public & private methods

- (NSString *)tapatalkPluginPath {
    return @"http://apfeltalk.de/forum/mobiquo/mobiquo.php/";
}

/*NSString * decodeString(NSString *aString) {
    NSData *stringData = [aString dataUsingEncoding:NSASCIIStringEncoding];
    size_t decodedDataSize = EstimateBas64DecodedDataSize([stringData length]);
    uint8_t *decodedData = calloc(decodedDataSize, sizeof(uint8_t));
    Base64DecodeData([stringData bytes], [stringData length], decodedData, &decodedDataSize);
    
    stringData = [NSData dataWithBytesNoCopy:decodedData length:decodedDataSize freeWhenDone:YES];
    
    NSString *s = [[[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding] autorelease];
    
    
    return s;
    
}

NSString * encodeString(NSString *aString) {
    NSData *stringData = [aString dataUsingEncoding:NSUTF8StringEncoding];
    size_t encodedDataSize = EstimateBas64EncodedDataSize([stringData length]);
    char *encodedData = malloc(encodedDataSize);
    Base64EncodeData([stringData bytes], [stringData length], encodedData, &encodedDataSize);
    
    stringData = [NSData dataWithBytesNoCopy:encodedData length:encodedDataSize freeWhenDone:YES];
    
    return [[[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] autorelease];
    
}*/

- (NSString *)decodeString:(NSString *)aString {
    return decodeString(aString);
}

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.receivedData];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    self.receivedData = nil;
    [pool release];
}

- (void)sendRequestWithXMLString:(NSString *)xmlString cookies:(BOOL)cookies delegate:(id)delegate {
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

- (void)loadData {
    NSString *xmlString = @"<?xml version=\"1.0\"?><methodCall><methodName>get_config</methodName></methodCall>";
    [self sendRequestWithXMLString:xmlString cookies:NO delegate:nil];
    
    xmlString = @"<?xml version=\"1.0\"?><methodCall><methodName>get_forum</methodName></methodCall>";
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

- (void)login {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Please login...", @"ATLocalizable", @"") 
                                                        message:@"\n\n\n" 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") 
                                              otherButtonTitles:NSLocalizedStringFromTable(@"Login", @"ATLocalizable", @""), nil];
    alertView.tag = 0;
    usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [usernameTextField setBackgroundColor:[UIColor whiteColor]];
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 75.0, 260.0, 25.0)];
    [passwordTextField setBackgroundColor:[UIColor whiteColor]];
    usernameTextField.placeholder = NSLocalizedStringFromTable(@"Username", @"ATLocalizable", @"");
    passwordTextField.placeholder = NSLocalizedStringFromTable(@"Password", @"ATLocalizable", @"");
    passwordTextField.secureTextEntry = YES;
    
    [alertView addSubview:usernameTextField];
    [alertView addSubview:passwordTextField];
    [usernameTextField becomeFirstResponder];
    
    [alertView show];
    [alertView release];
}

- (void)logout {
    [[User sharedUser] logout];
}

- (void)addSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 1.0, 320.0, 45.0)];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate = self;
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.tintColor = self.navigationController.navigationBar.tintColor;
    self.searchBar.placeholder = NSLocalizedStringFromTable(@"At least five characters", @"ATLocalizable", @"");
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.contentOffset = CGPointMake(0.0, 45.0);
    
    self.searchTableViewController = [[SearchTableViewController alloc] initWithNibName:nil bundle:nil];
    
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    searchDisplayController.delegate = self;
    self.searchTableViewController.tableView = searchDisplayController.searchResultsTableView;
    searchDisplayController.searchResultsTableView.delegate = self.searchTableViewController;
    searchDisplayController.searchResultsTableView.dataSource = self.searchTableViewController;
    self.searchTableViewController.forumViewController = self;
    
}

- (void)showActionSheet {
    NSString *buttonTitle;
    if ([[User sharedUser] isLoggedIn]) {
        buttonTitle = NSLocalizedStringFromTable(@"Logout", @"ATLocalizable", @"");
    } else {
        buttonTitle = NSLocalizedStringFromTable(@"Login", @"ATLocalizable", @"");
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") destructiveButtonTitle:nil otherButtonTitles:buttonTitle, NSLocalizedStringFromTable(@"New Posts", @"ATLocalizable", @""), nil];
    [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    [actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NewPostsViewController *newPostsViewController;
    switch (buttonIndex) {
        case 0:
            if ([[User sharedUser] isLoggedIn]) {
                [self logout];
            } else {
                [self login];
            } 
            break;
        case 1:
            newPostsViewController = [[NewPostsViewController alloc] initWithNibName:@"NewPostsViewController" bundle:nil];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newPostsViewController];
            navController.navigationBar.tintColor = [UIColor colorWithRed:0.673 green:0.038 blue:0.053 alpha:1.000];
            [self presentModalViewController:navController animated:YES];
            [newPostsViewController release];
            [navController release];
            break;
        default:
            break;
    }
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
                [usernameTextField resignFirstResponder];
                [passwordTextField resignFirstResponder];
                [usernameTextField release];
                [passwordTextField release];
            } else if (buttonIndex == 0 ) {
                [usernameTextField resignFirstResponder];
                [passwordTextField resignFirstResponder];
                [usernameTextField release];
                [passwordTextField release];
            }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.receivedData = [[NSMutableData alloc] init];
    
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
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(parse) object:nil];
        [thread start];
        [thread release];
    } else {
        [self.tableView reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
    NSLog(@"%@", [error localizedDescription]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", ATLocalizable, @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

#pragma mark -
#pragma UISearchBarDelegate & UISearchDisplayControllerDelegate

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)aSearchBar {
    if ([aSearchBar.text length] < 5 && searchButtonClicked) {
        searchButtonClicked = NO;
        return NO;
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        self.searchTableViewController.topics = nil;
        [self.searchTableViewController.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    searchButtonClicked = YES;
    if (!([aSearchBar.text length] < 5)) {
        searchButtonClicked = NO;
        NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>search_topic</methodName><params><param><value><base64>%@</base64></value></param><param><value><int>0</int></value></param><param><value><int>19</int></value></param></params></methodCall>", encodeString(aSearchBar.text)];
        [self sendRequestWithXMLString:xmlString cookies:NO delegate:self.searchTableViewController];
        self.searchTableViewController.topics = nil;
        self.searchTableViewController.showLoadingCell = YES;
        [self.searchTableViewController.tableView reloadData];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ATLocalizedString(@"Error", @"") 
<<<<<<< HEAD
                                                            message:NSLocalizedStringFromTable(@"Please enter at least five characters...", ATLocalizable, @"ATLocalizable") 
=======
                                                            message:NSLocalizedStringFromTable(@"Please enter at least five characters", ATLocalizable, @"") 
>>>>>>> a5dab2736282e63b25d9ca2d7f6428d0e05b3f6e
                                                           delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", ATLocalizable, @"") otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

#pragma mark -

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    self.searchTableViewController.topics = nil;
    [self.searchTableViewController.tableView reloadData];
    CGRect rect = self.tableView.frame;
    rect.origin.y += 45;
    [self.tableView scrollRectToVisible:rect animated:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)aTableView {
    self.searchTableViewController.tableView = aTableView;
    aTableView.delegate = self.searchTableViewController;
    aTableView.dataSource = self.searchTableViewController;
    [aTableView reloadData];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sections = [[NSMutableArray alloc] init];
    self.title = @"Forum";
    [self addSearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = NSLocalizedStringFromTable(@"Back", @"ATLocalizable", @"");
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
        
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
    if (self.searchDisplayController.active) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.sections count] == 0) {
        return nil;
    }
    return [(Section *)[self.sections objectAtIndex:section] name];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.sections count] == 0) {
        return 1;
    }
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.sections count] == 0) {
        return 1;
    }
    return [[(Section *)[self.sections objectAtIndex:section] subFora] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.sections count] == 0) {
        if(loadingCell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
		}
		
		return loadingCell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [(SubForum *)[[(Section *)[self.sections objectAtIndex:indexPath.section] subFora] objectAtIndex:indexPath.row] name];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell.
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SubForum *subForum = (SubForum *)[[(Section *)[self.sections objectAtIndex:indexPath.section] subFora] objectAtIndex:indexPath.row];
    
    SubForumController *subForumController = [[SubForumController alloc] initWithNibName:@"SubForumController" bundle:nil subForum:subForum];
    
    //Ausblenden der TabBar furs Forum
    //subForumController.hidesBottomBarWhenPushed = YES;
    
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:subForumController animated:YES];
    [subForumController release];
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark-
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict {
    self.currentString = [NSMutableString string];
    
    if ([self.path isEqualToString:kSectionPath]) {
        isSection = YES;
        self.currentSection = [[[Section alloc] init] autorelease];
        self.currentSection.subFora = [NSMutableArray array];
        self.currentObject = (SubForum *)self.currentSection;
    } else if ([self.path isEqualToString:kFirstLevelForumPath]) {
        isFirstLevelForum = YES;
        self.currentFirstLevelForum = [[[SubForum alloc] init] autorelease];
        self.currentFirstLevelForum.subFora = [NSMutableArray array];
        self.currentObject = self.currentFirstLevelForum;
    } else if ([self.path isEqualToString:kSecondLevelForumPath]) {
        isSecondLevelForum = YES;
        self.currentSecondLevelForum = [[[SubForum alloc] init] autorelease];
        self.currentSecondLevelForum.subFora = [NSMutableArray array];
        self.currentObject = self.currentSecondLevelForum;
    } else if ([self.path isEqualToString:kThirdLevelForumPath]) {
        isThirdLevelForum = YES;
        self.currentThirdLevelForum = [[[SubForum alloc] init] autorelease];
        self.currentObject = self.currentThirdLevelForum;
    } else if ([self.path isEqualToString:@"methodResponse/fault"]) {
        isError = YES;
    }
    
    self.path = [self.path stringByAppendingPathComponent:elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    if (isError && [self.path isEqualToString:@"methodResponse/fault/value/struct/member/value/string"]) {
        isError = NO;
        NSLog(@"Error: %@", self.currentString);
    }
    
    if ([elementName isEqualToString:@"name"]) {
        if ([self.currentString isEqualToString:@"forum_name"]) {
            isForumName = YES;
        } else if ([self.currentString isEqualToString:@"description"]) {
            isDescription = YES;
        } else if ([self.currentString isEqualToString:@"sub_only"]) {
            isSubOnly = YES;
        } else if ([self.currentString isEqualToString:@"forum_id"]) {
            isForumID = YES;
        }
    }
    
    if ([elementName isEqualToString:@"base64"]) {
        // First decode base64 data
        
        self.currentString = (NSMutableString *)decodeString(self.currentString);
        
        if (isForumName) {
            isForumName = NO;
            self.currentObject.name = self.currentString;
        } else if (isDescription) {
            isDescription = NO;
        }
    } else if ([elementName isEqualToString:@"string"]) {
        if (isForumID) {
            isForumID = NO;
            self.currentObject.forumID = [self.currentString intValue];
        }
    } else if ([elementName isEqualToString:@"boolean"]) {
        if (isSubOnly) {
            isSubOnly = NO;
            self.currentObject.subForaOnly = [self.currentString boolValue];
        }
    } 
    
    self.path = [self.path stringByDeletingLastPathComponent];
    
    if ([self.path isEqualToString:kSectionPath]) {
        isSection = NO;
        [self.dataArray addObject:self.currentSection];
    } else if ([self.path isEqualToString:kFirstLevelForumPath]) {
        isFirstLevelForum = NO;
        [self.currentSection.subFora addObject:self.currentFirstLevelForum];
    } else if ([self.path isEqualToString:kSecondLevelForumPath]) {
        isSecondLevelForum = NO;
        [self.currentFirstLevelForum.subFora addObject:self.currentSecondLevelForum];
    } else if ([self.path isEqualToString:kThirdLevelForumPath]) {
        isThirdLevelForum = NO;
        [self.currentSecondLevelForum.subFora addObject:self.currentThirdLevelForum];
    }
    self.currentString = nil;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.dataArray = [NSMutableArray array];
    self.path = [NSMutableString string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.sections = self.dataArray;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    self.dataArray = nil;
    self.path = nil;
    self.currentObject = nil;
    self.currentFirstLevelForum = nil;
    self.currentSecondLevelForum = nil;
    self.currentThirdLevelForum = nil;
    self.currentSection = nil;
}

@end
