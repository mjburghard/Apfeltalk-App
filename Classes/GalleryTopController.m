//
//  GalleryTopController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 12.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GalleryTopController.h"
#import "GalleryController.h"
#import "ATMXMLUtilities.h"
#import "Gallery.h"


@implementation GalleryTopController
@synthesize galleries, receivedData, rootPopoverButtonItem, popoverController, indexOfCurrentGallery;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    self.indexOfCurrentGallery = 0;
    self.receivedData = nil;
    self.galleries = nil;
    [super dealloc];
}

- (IBAction)openSafari:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apfeltalk.de"]];
}

#pragma mark -

- (IBAction)about:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedStringFromTable(@"Help for forum", @"ATLocalizable", @"")
						  message:NSLocalizedStringFromTable(@"HELP_TEXT", @"ATLocalizable", @"")
						  delegate:self
						  cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"")
						  otherButtonTitles:NSLocalizedStringFromTable(@"Contact", @"ATLocalizable", @"")
						  ,nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1)
	{
		NSArray *recipients = [[NSArray alloc] initWithObjects:@"info@apfeltalk.de", nil];
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
		controller.mailComposeDelegate = self;
		[controller setToRecipients:recipients];
		[recipients release];
		[self presentModalViewController:controller animated:YES];
		[controller release];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.galleries = [NSMutableArray array];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.apfeltalk.de/gallery/index.php"]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    self.contentSizeForViewInPopover = CGSizeMake(320.0, self.tableView.rowHeight*19);
    self.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(@"Help", @"ATLocalizable", @"");
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
    return (self.galleries.count == 0 ? 1 : self.galleries.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = ((Gallery *)[self.galleries objectAtIndex:indexPath.row]).title;
    
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
    self.indexOfCurrentGallery = indexPath.row;
    GalleryController *galleryController = [[GalleryController alloc] initWithNibName:@"DetailViewController" bundle:nil gallery:[self.galleries objectAtIndex:indexPath.row ]];
    galleryController.popoverController = self.popoverController;
    [self.navigationController pushViewController:galleryController animated:YES];
    [galleryController release];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	self.receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *string = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
	NSArray *ids = extractNodesFromHTMLForQuery(string, @"//li[@class='forumbit_post L2']/@id");
    NSArray *titles = extractNodesFromHTMLForQuery(string, @"//li[@class='forumbit_post L2']/div/div//div/div/div/h2/a/text()");
    for (NSUInteger i = 0;i < titles.count; i++) {
        NSString *urlString = [NSString stringWithFormat:@"http://www.apfeltalk.de/gallery/external.php?type=RSS2&cat=%@",[[ids objectAtIndex:i] substringFromIndex:3]];
        Gallery *gallery = [[Gallery alloc] initWithTitle:[titles objectAtIndex:i] URL:urlString];
        if ([[ids objectAtIndex:i] isEqualToString:@"cat500"]) {
            gallery.URLString = @"http://www.apfeltalk.de/gallery/external.php?type=RSS2"; //Mitgliedergallerie doesn't return all pictures if the cat parameter is included.
        }
        [self.galleries addObject:gallery];
        [gallery release];
    }
    self.receivedData = nil;
    [string release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
    self.receivedData = nil;
}

#pragma mark -
#pragma mark UISplitViewControllerDelegate 

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
    
    // Keep references to the popover controller and the popover button, and tell the detail view controller to show the button.
    barButtonItem.title = @"Gallery";
    self.popoverController = pc;
    self.rootPopoverButtonItem = barButtonItem;
    UIViewController <SubstitutableDetailViewController> *detailViewController = [self.splitViewController.viewControllers objectAtIndex:1];
    [detailViewController showRootPopoverButtonItem:barButtonItem];
}


- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Nil out references to the popover controller and the popover button, and tell the detail view controller to hide the button.
    UIViewController <SubstitutableDetailViewController> *detailViewController = [self.splitViewController.viewControllers objectAtIndex:1];
    [detailViewController invalidateRootPopoverButtonItem:barButtonItem];
    self.popoverController = nil;
    self.rootPopoverButtonItem = nil;
}

@end
