//
//  LivetickerController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Laurids Düllmann, Jesper Frommherz (Graphics),
//						Patrick Rollbis (Graphics),
//
//	This program is free software; you can redistribute it and/or
//	modify it under the terms of the GNU General Public License
//	as published by the Free Software Foundation; either version 2
//	of the License, or (at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software
//	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.//
//

#import "LivetickerController.h"
#import "LivetickerNavigationController.h"
#import "DetailLiveticker.h"
#import "Story.h"


#define TIMELABEL_TAG 1
#define TITLELABEL_TAG 2


@implementation LivetickerController

@synthesize stories;
@synthesize shortTimeFormatter;
@synthesize displayedStoryIndex;
@synthesize rootPopoverButtonItem, popoverController, xmlData;


- (void)dealloc
{
    [xmlData release];
    [popoverController release];
    [rootPopoverButtonItem release];
    [stories release];
    [shortTimeFormatter release];

    [super dealloc];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(320.0, self.tableView.rowHeight*5);
    [self setDisplayedStoryIndex:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"HH:mm"];
    [self setShortTimeFormatter:formatter];
    [formatter release];

    [self setStories:[NSArray array]];
}

- (void)selectFirstRow {
    NSLog(@"LivetickerController:selectFirstFow");
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (NSDictionary *) desiredKeys {
	// :below:20091018 Somewhat ugly...
	NSArray      *names = [NSArray arrayWithObjects:@"title", @"link", @"pubDate", @"dc:creator", @"content:encoded", nil];
	NSArray      *keys = [NSArray arrayWithObjects:@"title", @"link", @"date", @"author", @"summary", nil];
	NSDictionary *elementKeys = [NSDictionary dictionaryWithObjects:keys forKeys:names];
	
	return elementKeys;
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	long long length = [response expectedContentLength];
	if (length == NSURLResponseUnknownLength)
		length = 1024;
	[xmlData release];
	xmlData = [[NSMutableData alloc] initWithCapacity:length];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	ATXMLParser *parser = [[ATXMLParser alloc] initWithData:xmlData];
    [parser setDesiredElementKeys:[self desiredKeys]];
    [parser setStoryClass:[Story self]];
    [parser setDelegate:self];
    [parser parse];
    [parser release];	
	[xmlData release];
	xmlData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// !!!:below:20091021 Can someone add error handling, please?
}

#pragma mark -

- (void)reloadTickerEntries:(NSTimer *)timer
{
    /*ATXMLParser *parser = [ATXMLParser parserWithURLString:@"http://www.apfeltalk.de/live/?feed=rss2"];
	[parser setDesiredElementKeys:[self desiredKeys]];
	[parser setDelegate:self];
    //[NSThread detachNewThreadSelector:@selector(parseInBackgroundWithDelegate:) toTarget:parser withObject:self];
    NSThread *thread = [[NSThread alloc] initWithTarget:parser selector:@selector(parseInBackgroundWithDelegate:) object:self];
    [thread start];
    [thread release];*/
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.apfeltalk.de/live/?feed=rss2"]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    [connection release];
}



- (void)changeStory:(id)sender
{
    NSUInteger  newIndex = [self displayedStoryIndex];
    Story      *newStory;

    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 0)
        newIndex--;

    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 1)
        newIndex++;

    if ([(UISegmentedControl *)sender selectedSegmentIndex] != UISegmentedControlNoSegment)
    {
        [self setDisplayedStoryIndex:newIndex];
        newStory = [[self stories] objectAtIndex:newIndex];
        DetailLiveticker *detailLiveticker = [[[self navigationController] viewControllers] lastObject];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            detailLiveticker = [self.splitViewController.viewControllers objectAtIndex:1];
        }
        [detailLiveticker setStory:newStory];
        [detailLiveticker updateInterface];
    }

    [(UISegmentedControl *)sender setEnabled:([self displayedStoryIndex] > 0) forSegmentAtIndex:0];
    [(UISegmentedControl *)sender setEnabled:!([self displayedStoryIndex] == ([[self stories] count] - 1)) forSegmentAtIndex:1];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdendifier = @"Cell";
    if ([stories count] == 0 && stories != nil) {
        if(loadingCell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
        }
        
        return loadingCell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdendifier];

    UILabel *timeLabel;
    UILabel *titleLabel;

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdendifier] autorelease];

        CGRect contentRect = [[cell contentView] frame];

        // Creating the time label
        timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 50.0, contentRect.size.height)] autorelease];
        [timeLabel setTag:TIMELABEL_TAG];
        [timeLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [timeLabel setTextColor:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0]];
        [timeLabel setHighlightedTextColor:[UIColor whiteColor]];
        [timeLabel setTextAlignment:UITextAlignmentLeft];
        [timeLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight];
        [timeLabel setBackgroundColor:[UIColor clearColor]];

        [[cell contentView] addSubview:timeLabel];

        // Creating the title label
        titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50.0, 0.0, contentRect.size.width - 60.0, contentRect.size.height)] autorelease];
        [titleLabel setTag:TITLELABEL_TAG];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setHighlightedTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [titleLabel setBackgroundColor:[UIColor clearColor]];

        [[cell contentView] addSubview:titleLabel];
    }
    else
    {
        timeLabel = (UILabel *)[[cell contentView] viewWithTag:TIMELABEL_TAG];
        titleLabel = (UILabel *)[[cell contentView] viewWithTag:TITLELABEL_TAG];
    }

    Story *story = [stories objectAtIndex:[indexPath row]];

    [timeLabel setText:[[self shortTimeFormatter] stringFromDate:[story date]]];
    [titleLabel setText:[story title]];

    return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([stories count] == 0 && stories != nil) { 
        return 1;
    }
    
    return [stories count];
}



/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([stories count] && stories != nil)
        return nil;
    else
        return NSLocalizedStringFromTable(@"LivetickerController.noTicker", @"ATLocalizable", @"");
}*/

#pragma mark -
#pragma mark UISplitViewControllerDelegate 

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
    
    // Keep references to the popover controller and the popover button, and tell the detail view controller to show the button.
    barButtonItem.title = @"Liveticker";
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

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([stories count] == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    [self setDisplayedStoryIndex:[indexPath row]];

    Story            *story = [stories objectAtIndex:[indexPath row]];
    DetailLiveticker *detailController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        detailController = [[DetailLiveticker alloc] initWithNibName:@"DetailView" bundle:nil story:story];
        detailController.hidesBottomBarWhenPushed = YES;
        [[self navigationController] pushViewController:detailController animated:YES];
        [detailController release];
    } else {
        detailController = [self.splitViewController.viewControllers lastObject];
        [detailController setStory:story];
        [detailController updateInterface];
        if (popoverController != nil) {
            [popoverController dismissPopoverAnimated:YES];
        }
        /*
        if (rootPopoverButtonItem != nil) {
            [detailController showRootPopoverButtonItem:self.rootPopoverButtonItem];
        }*/
    }
}


#pragma mark -
#pragma mark ATXMLParserDelegateProtocol

- (void)parser:(ATXMLParser *)parser didFinishedSuccessfull:(BOOL)success
{
    if (success) {
    }
    else
        [(LivetickerNavigationController *)[self navigationController] setReloadTimer:nil];
}



- (void)parser:(ATXMLParser *)parser setParsedStories:(NSArray *)parsedStories
{
    if ([self.stories count] == 0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self setStories:parsedStories];
        [self.tableView reloadData];
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        DetailLiveticker *detailLiveticker = [self.splitViewController.viewControllers objectAtIndex:1];
        [[detailLiveticker storyControl] setEnabled:YES forSegmentAtIndex:1];
        return;
    }
    
    [self setStories:parsedStories];
    [self.tableView reloadData];
}

- (void)parser:(ATXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [(LivetickerNavigationController *)[self navigationController] setReloadTimer:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Content konnte nicht geladen werden", nil) message:@"Der Feed ist im Moment nicht verfügbar. Versuche es bitte später erneut."
													   delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [[[[loadingCell.subviews lastObject] subviews] lastObject] removeFromSuperview];
    [loadingCell.textLabel setText:NSLocalizedStringFromTable(@"LivetickerController.noTicker", @"ATLocalizable", @"")];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

@end
