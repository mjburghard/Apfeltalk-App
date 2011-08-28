//
//  PrivateMessagesViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 21.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrivateMessagesViewController.h"
#import "WriteMessageViewController.h"
#import "User.h"
#import "Box.h"
#import "BoxViewController.h"

@implementation PrivateMessagesViewController
@synthesize boxes;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    self.boxes = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (void)writeMessage {
    WriteMessageViewController *writeMessageViewController = [[WriteMessageViewController alloc] initWithNibName:@"WriteMessageViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:writeMessageViewController];
    navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [writeMessageViewController release];
}

- (void)loadBoxes {
    NSString *xmlString = @"<?xml version=\"1.0\"?><methodCall><methodName>get_box_info</methodName></methodCall>";
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

#pragma mark -
#pragma mark XMLRPCResponseDelegate

- (void)parserDidFinishWithObject:(NSObject *)dictionaryOrArray ofType:(XMLRPCResultType)type {
    if (type == XMLRPCResultTypeDictionary) {
        NSDictionary *dictionary = (NSDictionary *)dictionaryOrArray;
        NSArray *array = [dictionary valueForKey:@"list"];
        for (NSDictionary *dict in array) {
            Box *box = [[Box alloc] initWithDictionary:dict];
            [self.boxes addObject:box];
            [box release];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = ATLocalizedString(@"Private Messages", @"");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *writeMessageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(writeMessage)];
    self.navigationItem.rightBarButtonItem = writeMessageButton;
    [writeMessageButton release];
    
    self.boxes = [NSMutableArray array];
    self.tabBarItem.title = ATLocalizedString(@"PM", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBoxes) name:@"ATLoginWasSuccessful" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        return  YES;
    
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
    return [self.boxes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    Box *box = [self.boxes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = box.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld|%ld", box.numberOfUnreadMessages, box.numberOfMessages];
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
    
     BoxViewController *boxViewController = [[BoxViewController alloc] initWithNibName:@"BoxViewController" bundle:nil box:[self.boxes objectAtIndex:indexPath.row]];
     [self.navigationController pushViewController:boxViewController animated:YES];
     [boxViewController release];
     
}

@end
