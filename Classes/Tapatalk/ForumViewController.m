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
#import "SubscriptionsViewController.h"
#import "XMLRPCResponseParser.h"

@implementation ForumViewController
@synthesize sections, searchBar, searchTableViewController;

#pragma mark -
#pragma mark init & dealloc

- (void)dealloc {
    self.searchTableViewController = nil;
    self.searchBar = nil;
    self.sections = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public & private methods

- (void)loadForum {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ATLoginDidFinish" object:nil];
    NSString *xmlString = @"<?xml version=\"1.0\"?><methodCall><methodName>get_config</methodName></methodCall>";
    [self sendRequestWithXMLString:xmlString cookies:NO delegate:nil];
    
    xmlString = @"<?xml version=\"1.0\"?><methodCall><methodName>get_forum</methodName></methodCall>";
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

- (void)addSearchBar {    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 1.0, 320.0, 45.0)] autorelease];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate = self;
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.tintColor = self.navigationController.navigationBar.tintColor;
    self.searchBar.placeholder = ATLocalizedString(@"At least five characters", @"");
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.contentOffset = CGPointMake(0.0, 45.0);
    
    self.searchTableViewController = [[[SearchTableViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    searchDisplayController.delegate = self;
    self.searchTableViewController.tableView = searchDisplayController.searchResultsTableView;
    searchDisplayController.searchResultsTableView.delegate = self.searchTableViewController;
    searchDisplayController.searchResultsTableView.dataSource = self.searchTableViewController;
    self.searchTableViewController.forumViewController = self;
    [searchDisplayController release];
    
}

- (void)showActionSheet {
    NSString *loginButtonTitle, *subscriptionsButtonTitle;
    if ([[User sharedUser] isLoggedIn]) {
        loginButtonTitle = NSLocalizedStringFromTable(@"Logout", @"ATLocalizable", @"");
        subscriptionsButtonTitle = ATLocalizedString(@"Subscriptions", @"");
    } else {
        loginButtonTitle = NSLocalizedStringFromTable(@"Login", @"ATLocalizable", @"");
        subscriptionsButtonTitle = nil;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") destructiveButtonTitle:nil otherButtonTitles:loginButtonTitle, NSLocalizedStringFromTable(@"New Posts", @"ATLocalizable", @""), subscriptionsButtonTitle, nil];
    [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    [actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UINavigationController *navController;
    NewPostsViewController *newPostsViewController;
    SubscriptionsViewController *subscriptionsViewController;
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
            navController = [[UINavigationController alloc] initWithRootViewController:newPostsViewController];
            navController.navigationBar.tintColor = [UIColor colorWithRed:0.673 green:0.038 blue:0.053 alpha:1.000];
            [self presentModalViewController:navController animated:YES];
            [newPostsViewController release];
            [navController release];
            break;
        case 2:
            if (![[User sharedUser] isLoggedIn]) {
                return;
            }
            subscriptionsViewController = [[SubscriptionsViewController alloc] initWithNibName:@"SubscriptionsViewController" bundle:nil];
            navController = [[UINavigationController alloc] initWithRootViewController:subscriptionsViewController];
            navController.navigationBar.tintColor = [UIColor colorWithRed:0.673 green:0.038 blue:0.053 alpha:1.000];
            [self presentModalViewController:navController animated:YES];
            [subscriptionsViewController release];
            [navController release];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark XMLRPCResponseDelegate

- (void)parserDidFinishWithObject:(NSObject *)dictionaryOrArray ofType:(XMLRPCResultType)type {
    if (type == XMLRPCResultTypeArray) {
        for (NSDictionary *dictionary in (NSArray *)dictionaryOrArray) {
            Section *section = [[Section alloc] initWithDictionary:dictionary];
            [self.sections addObject:section];
            [section release];
        }
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
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
                                                            message:NSLocalizedStringFromTable(@"Please enter at least five characters...", ATLocalizable, @"ATLocalizable") 
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
    self.sections = [NSMutableArray array];
    self.title = @"Forum";
    [self addSearchBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadForum) name:@"ATLoginDidFinish" object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.searchDisplayController.active) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.sections count] == 0) {
        return nil;
    }
    return [(Section *)[self.sections objectAtIndex:section] title];
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
    
    cell.textLabel.text = [(SubForum *)[[(Section *)[self.sections objectAtIndex:indexPath.section] subFora] objectAtIndex:indexPath.row] title];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
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

@end
