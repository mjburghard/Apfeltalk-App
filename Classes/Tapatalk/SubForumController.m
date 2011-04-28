//
//  SubForumController.m
//  Tapatalk
//
//  Created by Manuel Burghard on 19.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubForumController.h"

@implementation SubForumController
@synthesize subForum, currentTopic, topics;

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
        self.receivedData = [[NSMutableData alloc] init];
    }
    
    [connection start];
}

- (void)loadData {
    [self loadPinnedTopics];
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connvection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"%@", [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]);
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(parse) object:nil];
    [thread start];
    [thread release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.subForum.name;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.subForum.subFora count] != 0 && section == 0) {
        return NSLocalizedString(@"Subforums", @"");
    }
    return NSLocalizedString(@"Threads", @"");
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
    return [self.topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0 && [self.subForum.subFora count] != 0) {
        cell.textLabel.text = [(SubForum *)[self.subForum.subFora objectAtIndex:indexPath.row] name];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    cell.textLabel.text = [(Topic *)[self.topics objectAtIndex:indexPath.row] title];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    // Configure the cell...
    
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
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
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
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"] && [self.currentString isEqualToString:@"prefixes"]) {
        isPrefixes = YES;
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
    [super parserDidEndDocument:parser];
    [self performSelectorOnMainThread:@selector(loadStandartTopics) withObject:nil waitUntilDone:NO];
}

@end
