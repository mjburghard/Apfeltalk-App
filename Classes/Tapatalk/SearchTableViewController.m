//
//  SearchTableViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 29.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchTableViewController.h"
#import "User.h"
#import "DetailThreadController.h"
#import "ForumViewController.h"


@implementation SearchTableViewController
@synthesize receivedData, topics, forumViewController, showLoadingCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.showLoadingCell = NO;
    self.forumViewController = nil;
    self.topics = nil;
    self.receivedData = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    TopicParser *topicParser = [[TopicParser alloc] initWithData:self.receivedData basePath:@"methodResponse/params/param/value/struct/member/value/array/data" delegate:self];
    [topicParser parse];
    [topicParser release];
    self.receivedData = nil;
    [pool release];
}

#pragma mark-
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.showLoadingCell = YES;
	self.receivedData = [[NSMutableData alloc] init];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *headers = [httpResponse allHeaderFields];
    NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:[NSURL URLWithString:@"http://www.apfeltalk.de"]];
    if ([all count] > 0) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:all forURL:[NSURL URLWithString:@"http://www.apfeltalk.de"] mainDocumentURL:nil]; 
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
    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", ATLocalizable, @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];*/
}

#pragma mark -

- (void)topicParserDidFinish:(NSMutableArray *)_topics {
    self.topics = _topics;
    self.showLoadingCell = NO;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if ([self.topics count] == 0 && showLoadingCell) 
        return 1;
    return [topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
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
    if (t.closed) {
        cell.imageView.image = [UIImage imageNamed:@"thread_dot_lock.png"];
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
    if ([self.topics count] == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    [self.forumViewController.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    [detailThreadController loadLastSite];
    [self.forumViewController.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
}

@end
