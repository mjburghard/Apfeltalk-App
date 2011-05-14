//
//  SubForumController.m
//  Tapatalk
//
//  Created by Manuel Burghard on 19.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubForumController.h"
#import "NewTopicViewController.h"

@implementation SubForumController
@synthesize subForum, currentTopic, topics, isLoadingPinnedTopics;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil subForum:(SubForum *)aSubForum {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.topics = [NSMutableArray array];
        self.subForum = aSubForum;
    }
    return self;
}

- (void)dealloc
{
    self.isLoadingPinnedTopics = NO;
    self.subForum = nil;
    self.currentTopic = nil;
    self.topics = nil;
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

- (void)loadStandartTopics {
    NSURL *url = [NSURL URLWithString:[self tapatalkPluginPath]];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_topic</methodName><params><param><value><string>%i</string></value></param><param><value><int>0</int></value></param><param><value><int>19</int></value></param><param><value><string></string></value></param></params></methodCall>", self.subForum.forumID];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if (connection) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    
    [connection start];
}

- (void)loadPinnedTopics {
    self.isLoadingPinnedTopics = YES;
    NSURL *url = [NSURL URLWithString:[self tapatalkPluginPath]];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_topic</methodName><params><param><value><string>%i</string></value></param><param><value><int>0</int></value></param><param><value><int>19</int></value></param><param><value><string>TOP</string></value></param></params></methodCall>", self.subForum.forumID];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if (connection) {
    }
    
    [connection start];
}

- (void)loadData {
    self.topics = [NSMutableArray array];
    [self loadPinnedTopics];
}

- (void)newTopic {
    NewTopicViewController *newTopicViewController = [[NewTopicViewController alloc] initWithNibName:@"NewTopicViewController" bundle:nil forum:self.subForum];
    [self.navigationController pushViewController:newTopicViewController animated:YES];
    [newTopicViewController release];
}

- (void)logout {
    NSURL *url = [NSURL URLWithString:[self tapatalkPluginPath]];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>logout_user</methodName></methodCall>"];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:nil];
    [connection start];
    [[User sharedUser] setLoggedIn:NO];
    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"ATUsername"] andServiceName:@"Apfeltalk" error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"ATUsername"];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)showActionSheet {
    NSString *buttonTitle;
    if ([[User sharedUser] isLoggedIn]) {
        buttonTitle = NSLocalizedStringFromTable(@"Logout", @"ATLocalizable", @"");
    } else {
        buttonTitle = NSLocalizedStringFromTable(@"Login", @"ATLocalizable", @"");
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") destructiveButtonTitle:nil otherButtonTitles:buttonTitle, NSLocalizedStringFromTable(@"New", @"ATLocalizable", @""), nil];
    [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    [actionSheet release];
}

#pragma mark -
#pragma mark UserXMLParserDelegate

- (void)userIsLoggedIn:(BOOL)isLoggedIn {
    if (isLoggedIn) {
        NSError *error = nil;
        [[NSUserDefaults standardUserDefaults] setObject:usernameTextField.text forKey:@"ATUsername"];
        [SFHFKeychainUtils storeUsername:usernameTextField.text
                             andPassword:passwordTextField.text forServiceName:@"Apfeltalk" updateExisting:NO error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        [usernameTextField release];
        [passwordTextField release];
    } else {
        [super userIsLoggedIn:isLoggedIn];
    }
    
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if ([[User sharedUser] isLoggedIn]) {
                [self logout];
            } else {
                [self login];
            } 
            break;
        case 1:
            [self newTopic];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2) {
        [self login];
        return;
    } else {
        [super alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connvection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.subForum.name;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    self.navigationItem.rightBarButtonItem = rightButton;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.subForum.subFora count] != 0 && section == 0) {
        return NSLocalizedStringFromTable(@"Subforums", @"ATLocalizable", @"");
    }
    return NSLocalizedStringFromTable(@"Threads", @"ATLocalizable", @"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    
    if ([self.subForum.subFora count] != 0) 
        return 2;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0 && [self.subForum.subFora count] != 0) {
        return [self.subForum.subFora count];
    }
    
    if ([self.topics count] == 0) {
        return 1;
    }
    
    return [self.topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.imageView.image = nil;
    
    if (indexPath.section == 0 && [self.subForum.subFora count] != 0) {
        cell.textLabel.text = [(SubForum *)[self.subForum.subFora objectAtIndex:indexPath.row] name];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    if ([self.topics count] == 0) {
        if(loadingCell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
		}
		
		return loadingCell;
    }
    Topic *t = (Topic *)[self.topics objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [t title];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    if (t.hasNewPost) {
        cell.imageView.image = [UIImage imageNamed:@"thread_dot_hot.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"thread_dot.png"];
    }
    
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    
    if (indexPath.section == 0 && [self.subForum.subFora count] != 0) {
        SubForumController *subForumController = [[SubForumController alloc] initWithNibName:@"SubForumController" 
                                                                                      bundle:nil 
                                                                                    subForum:(SubForum *)[self.subForum.subFora objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:subForumController animated:YES];
        [subForumController release];
        return;
    }
    
    if ([self.topics count] == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    [detailThreadController loadLastSite];
    [self.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
}
#pragma mark-
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict {
    self.currentString = [NSMutableString new];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data"]) {
        if (!isPrefixes) {
            self.currentTopic = [[Topic alloc] init];
        }
    }
    self.path = [self.path stringByAppendingPathComponent:elementName];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/name"]) {
        if ([self.currentString isEqualToString:@"topic_id"]) {
            isTopicID = YES;
        } else if ([self.currentString isEqualToString:@"topic_title"]) {
            isTopicTitle = YES;
        } else if ([self.currentString isEqualToString:@"forum_id"]) {
            isForumID = YES;
        } else if ([self.currentString isEqualToString:@"new_post"]) {
            isNewPost = YES;
        } else if ([self.currentString isEqualToString:@"reply_number"]) {
            isReplyNumber = YES;
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/value/base64"]) {
        // First decode base64 data
        self.currentString = (NSMutableString *)decodeString(self.currentString);
        if (isTopicTitle) {
            isTopicTitle = NO;
            self.currentTopic.title = self.currentString;
        }
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/value/string"]) {
        if (isForumID) {
            isForumID = NO;
            self.currentTopic.forumID = [self.currentString intValue];
        }
        
        if (isTopicID) {
            isTopicID = NO;
            self.currentTopic.topicID = [self.currentString intValue];
        }
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/value/boolean"]) {
        if (isNewPost) {
            isNewPost = NO;
            if ([self.currentString isEqualToString:@"1"]) {
                self.currentTopic.hasNewPost = YES;
            } else {
                self.currentTopic.hasNewPost = NO;
            }
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"] && [self.currentString isEqualToString:@"prefixes"]) {
        isPrefixes = YES;
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/value/int"]) {
        if (isReplyNumber) {
            isReplyNumber = NO;
            self.currentTopic.numberOfPosts = [self.currentString integerValue]+1;
        }
    }
    
    self.path = [self.path stringByDeletingLastPathComponent];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data"]) {
        if (self.currentTopic != nil)
            [self.topics addObject:self.currentTopic];
            
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value"] && isPrefixes)
        isPrefixes = NO;
        
    self.currentString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (self.isLoadingPinnedTopics) {
        self.isLoadingPinnedTopics = NO;
        [self performSelectorOnMainThread:@selector(loadStandartTopics) withObject:nil waitUntilDone:NO];
        return;
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

@end
