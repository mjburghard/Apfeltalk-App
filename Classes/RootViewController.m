//
//  RootViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan K√∂nig (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Laurids D√ºllmann, Jesper Frommherz (Graphics),
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

#import "RootViewController.h"
#import "AudioToolbox/AudioToolbox.h"

@interface RootViewController (private)
- (BOOL) openDatabase;
- (NSString *) readDocumentsFilename;
@end


@implementation RootViewController

@synthesize stories;

- (BOOL) shakeToReload {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"shakeToReload"];
}

#pragma mark Instance Methods

- (IBAction)openSafari:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apfeltalk.de"]];
}

- (IBAction)about:(id)sender {
	[newsTable reloadData];
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Impressum"
						  message:@"Diese App ist ein Community-Projekt und steht unter der Lizenz GPL v2. Entwickelt wurde sie mit freundlicher Unterstützung der Apfeltalk GmbH. \n\nDie Forenzugriffs-Schnittstelle stammt von Tapatalk. \n\n Liste der Entwickler unter Einstellungen..."
						  delegate:self
						  cancelButtonTitle:NSLocalizedString(@"OK", @"")
						  otherButtonTitles:NSLocalizedString(@"Contact", @"")
						  ,nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1)
	{
		NSArray *recipients = [[NSArray alloc] initWithObjects:@"info@apfeltalk.de", nil];
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
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

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([stories count] > 1 ? [stories count] : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	/* return the loading cell! */
	if([stories count] == 0) {
		if(loadingCell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
		}
		
		return loadingCell;
	}
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    }
	
	// Configure the cell.
	int storyIndex = [indexPath row];
	
	// Everything below here is customization
	
	NSString * link = [[stories objectAtIndex: indexPath.row] link];
	BOOL read = [self databaseContainsURL:link];
    
	if (read) {
		cell.imageView.image = [UIImage imageNamed:@"thread_dot.png"];
	} else {
		cell.imageView.image = [UIImage imageNamed:@"thread_dot_hot.png"];
	}
    
	cell.textLabel.text = [[stories objectAtIndex: storyIndex] title];
    
    return cell;
}

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/* check if this is a loading cell */
	if([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqual:@"loading"])
		return;
	
	// Navigation logic
	
	Story *story = [stories objectAtIndex: indexPath.row];
	Class dvClass = [self detailControllerClass];
	DetailViewController *detailController = [[dvClass alloc] initWithNibName:@"DetailView" 
																	   bundle:[NSBundle mainBundle]
																		story:story];
    
	NSString * link = [story link];
    
	if ([link length] > 0 && ![self databaseContainsURL:link]) {
		NSDate *date = [[stories objectAtIndex: indexPath.row] date];
		
		const char *sql = "insert into read(url, date) values(?,?)"; 
		sqlite3_stmt *insert_statement;
		int error;
		error = sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL); 
		if (error == SQLITE_OK) {
			sqlite3_bind_text(insert_statement, 1, [link UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_double(insert_statement, 2, [date timeIntervalSinceReferenceDate]);
			error = (sqlite3_step(insert_statement) != SQLITE_DONE);
		}
		if (error == SQLITE_OK)
			error = sqlite3_finalize(insert_statement);	
		
		// This code could be resued in the News Controller
		if (error != SQLITE_OK) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString (@"Database error", @"")
															message:NSLocalizedString (@"An unknown error occurred.", @"")
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString (@"OK", @"") otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
        
		/*
		 *	More thinking needs to go into the deletion of reads
		 *
		 sqlite3_stmt *delete_statement;
		 NSString *deleteSql = [NSString stringWithFormat:@"delete from read where date<%f", [[[self class] oldestStoryDate] timeIntervalSinceReferenceDate]];
		 error = sqlite3_prepare_v2(database, [deleteSql UTF8String], -1, &delete_statement, NULL); 
		 if (error != SQLITE_OK)
		 NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
		 
		 error = sqlite3_step(delete_statement); 
		 error = error != SQLITE_DONE;
		 
		 error = sqlite3_finalize(delete_statement);	
		 if (error != SQLITE_OK)
		 NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
		 */	
		[newsTable reloadData];
		
		// update the number of unread messages in Application Badge
		[self updateApplicationIconBadgeNumber];
	}
    
	[self.navigationController pushViewController:detailController animated:YES];
	[detailController release];
}

#pragma mark -
#pragma mark Database

- (BOOL) openDatabase {
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self readDocumentsFilename]])
	{
		NSError *error;
		NSString *dbResourcePath = [[NSBundle mainBundle] pathForResource:@"gelesen" ofType:@"db"];
		[[NSFileManager defaultManager] copyItemAtPath:dbResourcePath toPath:[self readDocumentsFilename] error:&error];
		// Check for errors...
	}
	
	if (sqlite3_open([[self readDocumentsFilename] UTF8String], &database) 
        == SQLITE_OK)
		return true;
	else 
		return false;
}

/*
 * This funktion checks to see if the given URL is in the database
 */
- (BOOL) databaseContainsURL:(NSString *)link {
	BOOL found = NO;
	
	const char *sql = "select url from read where url=?";
	sqlite3_stmt *statement;
	int error;
	
	error = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
	if (error == SQLITE_OK) {
		error = sqlite3_bind_text (statement, 1, [link UTF8String], -1, SQLITE_TRANSIENT);
		if (error == SQLITE_OK && sqlite3_step(statement) == SQLITE_ROW) {
			found = YES;
		}
	}
	if (error != SQLITE_OK)
		NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
	error = sqlite3_finalize(statement);	
	if (error != SQLITE_OK)
		NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
    
	return found;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    reloading =YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibrateOnReload"]) {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
    [self parseXMLFileAtURL:[self documentPath]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)doneLoadingTableViewData{
	[tableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	reloading =NO;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[tableHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[tableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return reloading;
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; 
	
}

#pragma mark -

- (NSString *) documentPath {
	return @"http://pipes.yahoo.com/pipes/pipe.run?ContextBegin=%3Cdiv+class%3D%22article+cms_clear+restore+postcontainer%22%3E&ContextEnd=%3C%2Fdiv%3E&RssUrl=http%3A%2F%2Ffeeds.apfeltalk.de%2Fapfeltalk-magazin&_id=2b7dd66fad6786fb098d951bad72762c&_render=rss";
}

- (NSString *) supportFolderPath {
	// This could be static
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	assert ([paths count]);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

- (NSString *) readDocumentsFilename {	 
	return [[self supportFolderPath] stringByAppendingPathComponent:@"gelesen.db"];
}

- (Class) detailControllerClass {
	return [DetailViewController self];
}

- (void)viewWillAppear:(BOOL)animated {
	[self openDatabase];
	
	if(self.shakeToReload)
		[self activateShakeToReload:self];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// if our view is not active/visible, we don't want to receive Accelerometer events
	if(self.shakeToReload)
	{
		UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
		accel.delegate = nil;
	}
}

// handle acceleromter event
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	if ([self isShake:acceleration]) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibrateOnReload"]) {
			AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
		}
		[self parseXMLFileAtURL:[self documentPath]];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (tableHeaderView == nil) {
		
		tableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		tableHeaderView.delegate = self;
        tableHeaderView.backgroundColor = self.tableView.backgroundColor;
		[self.tableView addSubview:tableHeaderView];
		
	}
	
	[tableHeaderView refreshLastUpdatedDate];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	if ([stories count] == 0) {
		[self parseXMLFileAtURL:[self documentPath]];
		//[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	int error = sqlite3_close(database);
	assert (error == 0);
}

- (NSString *) dateElementName {
	return @"pubDate";
}

- (NSDictionary *) desiredKeys {
	NSArray      *names = [NSArray arrayWithObjects:@"title", @"link", [self dateElementName], @"dc:creator", @"description", nil];
	NSArray      *keys = [NSArray arrayWithObjects:@"title", @"link", @"date", @"author", @"summary", nil];
	NSDictionary *elementKeys = [NSDictionary dictionaryWithObjects:keys forKeys:names];
	
	return elementKeys;
}

- (void)parseXMLFileAtURL:(NSString *)URLString
{
	NSURL *url = [NSURL URLWithString:URLString];
	if (url == nil)
		return;
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] 
																delegate:self];
	[connection start];
	
}

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
    [parser setDesiredElementKeys:self.desiredKeys];
    [parser setStoryClass:[Story self]];
	[parser setDateElementName:[self dateElementName]];
    [parser setDelegate:self];
    [parser parse];
    [parser release];	
	[xmlData release];
	xmlData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// !!!:below:20091021 Can someone add error handling, please?
}


- (void)updateApplicationIconBadgeNumber {
	//logic is now in each Controllers
}

// activate the UIAcceleromter for Shake To Reload
- (void) activateShakeToReload:(id)delegate
{
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
    accel.delegate = delegate;
    accel.updateInterval = kUpdateInterval;	
}

- (BOOL) isShake:(UIAcceleration *)acceleration
{
	BOOL ret = NO;
	
	if (acceleration.x > kAccelerationThreshold || acceleration.y > kAccelerationThreshold || acceleration.z > kAccelerationThreshold)
	{
		ret = YES;
		NSLog(@"shake was recognized");
	}
	
	return ret;
}


- (void)dealloc
{	
	[stories release];
	[loadingCell release];
	[xmlData release];
	[super dealloc];
}


#pragma mark -
#pragma mark ATXMLParserDelegateProtocol

- (void)parser:(ATXMLParser *)parser setParsedStories:(NSArray *)parsedStories
{
    [self setStories:parsedStories];
    [(UITableView *)[self view] reloadData];
    [self doneLoadingTableViewData];
}



- (void)parser:(ATXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"%@", [parseError localizedDescription]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Content konnte nicht geladen werden", nil)
                                                        message:@"Der Feed ist im Moment nicht verfügbar. Versuche es bitte später erneut."
													   delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark -
#pragma mark Interfacerotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
