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
@synthesize subForum, currentTopic, topics, isLoadingPinnedTopics, numberOfTopics, dataArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil subForum:(SubForum *)aSubForum {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.subForum = aSubForum;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.numberOfTopics = -1;
    }
    return self;
}

- (void)dealloc
{
    self.dataArray = nil;
    self.numberOfTopics = 0;
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
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_topic</methodName><params><param><value><string>%i</string></value></param><param><value><int>0</int></value></param><param><value><int>19</int></value></param><param><value><string></string></value></param></params></methodCall>", self.subForum.forumID];
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

- (void)loadPinnedTopics {
    self.dataArray = [NSMutableArray array];
    self.isLoadingPinnedTopics = YES;
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_topic</methodName><params><param><value><string>%i</string></value></param><param><value><int>0</int></value></param><param><value><int>19</int></value></param><param><value><string>TOP</string></value></param></params></methodCall>", self.subForum.forumID];
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

- (void)loadSubForum {
    [self loadPinnedTopics];
}

- (void)newTopic {
    NewTopicViewController *newTopicViewController = [[NewTopicViewController alloc] initWithNibName:@"NewTopicViewController" bundle:nil forum:self.subForum];
    [self.navigationController pushViewController:newTopicViewController animated:YES];
    [newTopicViewController release];
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

#pragma mark -
#pragma mark XMLRPCResponseDelegate

- (void)parserDidFinishWithObject:(NSObject *)dictionaryOrArray ofType:(XMLRPCResultType)type {
    if (type  == XMLRPCResultTypeDictionary) {
        if (isLoadingPinnedTopics)
            self.numberOfTopics = 0;
        NSDictionary *dictionary = (NSDictionary *)dictionaryOrArray;
        self.numberOfTopics += [[dictionary valueForKey:@"total_topic_num"] integerValue];
        
        NSArray *array = [dictionary valueForKey:@"topics"];
        
        for (NSDictionary *dict in array) {
            Topic *topic = [[Topic alloc] initWithDictionary:dict];
            [self.dataArray addObject:topic];
            [topic release];
        }
    }
    if (isLoadingPinnedTopics) {
        isLoadingPinnedTopics = NO;
        [self loadStandartTopics];
    } else {
        if (self.dataArray.count == 0) {
            self.numberOfTopics = 0;
        }
        self.topics = self.dataArray;
        [self.tableView reloadData];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.subForum.title;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadSubForum];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Einblenden der TabBar bei verlassen des Forums	
    self.hidesBottomBarWhenPushed = NO;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    
    if (indexPath.section == 0 && [self.subForum.subFora count] != 0) {
        cell.textLabel.text = [(SubForum *)[self.subForum.subFora objectAtIndex:indexPath.row] title];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    if (self.numberOfTopics == 0) {
        cell.textLabel.text = NSLocalizedStringFromTable(@"There are no topics", @"ATLocalizable", @"");
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
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
    // Navigation logic may go here. Create and push another view controller.
    
    
    if (indexPath.section == 0 && [self.subForum.subFora count] != 0) {
        SubForumController *subForumController = [[SubForumController alloc] initWithNibName:@"SubForumController" 
                                                                                      bundle:nil 
                                                                                    subForum:(SubForum *)[self.subForum.subFora objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:subForumController animated:YES];
        [subForumController release];
        return;
    }
    
    if ([self.topics count] == 0 || self.numberOfTopics == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    //Ausblenden der TabBar im beim lesen der Themen
    //detailThreadController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    [detailThreadController loadLastSite];
    [self.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
}

@end
