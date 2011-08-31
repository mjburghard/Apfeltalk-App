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
#import "ATContactDataSource.h"
#import "ATContactModel.h"
#import "ATContactPicker.h"
#import "ContentTranslator.h"


@implementation PrivateMessagesViewController
@synthesize boxes, isSending;

- (void)setDefaultBehavior {
    self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    self.isSending = NO;
    self.boxes = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (void)writeMessage {
    TTMessageController *messageController = [[TTMessageController alloc] initWithRecipients:nil];
    messageController.delegate = self;
    ATContactDataSource *dataSource = [[ATContactDataSource alloc] init];
    dataSource.messageController = messageController;
    messageController.dataSource = dataSource;
    messageController.showsRecipientPicker = YES;
    messageController.navigationBarTintColor = ATNavigationBarTintColor;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:messageController];
    navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [messageController release];
    [dataSource release];
}

- (void)loadBoxes {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ATLoginWasSuccessful" object:nil];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    NSString *xmlString = @"<?xml version=\"1.0\"?><methodCall><methodName>get_box_info</methodName></methodCall>";
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

#pragma mark -
#pragma mark TTMessageControllerDelegate

- (void)composeControllerWillCancel:(TTMessageController *)controller {
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)composeControllerShowRecipientPicker:(TTMessageController *)controller {
    ATContactDataSource *dataSource = (ATContactDataSource *)[controller dataSource];
    ATContactModel *model = [dataSource contactModel];
    NSMutableArray *onlineUsers =  model.onlineUsers;
    NSArray *titles = [NSArray arrayWithObjects:ATLocalizedString(@"Online Users", nil), nil];
    NSArray *groups = [NSArray arrayWithObjects:onlineUsers, nil];
    ATContactPicker *contactPicker = [[ATContactPicker alloc] initWithStyle:UITableViewStylePlain groups:groups titles:titles];
    contactPicker.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactPicker];
    navigationController.navigationBar.tintColor = ATNavigationBarTintColor;
    [contactPicker tableView:contactPicker.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [controller presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [contactPicker release];
}

- (void)composeController:(TTMessageController *)controller didSendFields:(NSArray *)fields {
    NSMutableString *recipients = [NSMutableString string];
    for (NSObject *item in [(TTMessageRecipientField *)[fields objectAtIndex:0] recipients]) {
        if ([item isKindOfClass:[TTTableTextItem class]]) {
            [recipients appendString:[NSString stringWithFormat:@"<value><base64>%@</base64></value>", encodeString([(TTTableTextItem *)item text])]];
        } else if ([item isKindOfClass:[NSString class]]) {
            [recipients appendString:[NSString stringWithFormat:@"<value><base64>%@</base64></value>", encodeString((NSString *)item)]];
        }
    }
    ContentTranslator *translator = [ContentTranslator contentTranslator];
    NSString *subject = [(TTMessageTextField *)[fields objectAtIndex:1] text];
    NSString *message = [(TTMessageTextField *)[fields lastObject] text];
    subject = [translator translateStringForAT:subject];
    message = [translator translateStringForAT:message];
    
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>create_message</methodName><params><param><value><array><data>%@</data></array></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", recipients, encodeString(subject), encodeString(message)];
    self.isSending = YES;
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

#pragma mark -
#pragma mark ATContactPickerDelegate

- (void)contactPicker:(ATContactPicker *)contactPicker didSelectContact:(NSString *)contactName {
    TTMessageController *messageController = (TTMessageController *)[[(UINavigationController *)self.modalViewController viewControllers] objectAtIndex:0];
    [messageController addRecipient:contactName forFieldAtIndex:0];
    [messageController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark XMLRPCResponseDelegate

- (void)parserDidFinishWithObject:(NSObject *)dictionaryOrArray ofType:(XMLRPCResultType)type {
    if (type == XMLRPCResultTypeDictionary) {
        NSDictionary *dictionary = (NSDictionary *)dictionaryOrArray;
        if (self.isSending) {
            self.isSending = NO;
            [self.modalViewController dismissModalViewControllerAnimated:YES];
            if (![[dictionary valueForKey:@"result"] boolValue]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ATLocalizedString(@"Error", nil) message:[dictionary valueForKey:@"result_text"] delegate:nil cancelButtonTitle:ATLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
            } 
            return;
        }
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
    if (![[User sharedUser] isLoggedIn]) {
        [self.tableView reloadData];
        self.boxes = [NSMutableArray array];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
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
    if (![[User sharedUser] isLoggedIn]) 
        return 1;
    return [self.boxes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (![[User sharedUser] isLoggedIn]) {
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = ATLocalizedString(@"Please log in", nil);
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        return cell;
    }
    
    // Configure the cell...
    Box *box = [self.boxes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = box.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld|%ld", box.numberOfUnreadMessages, box.numberOfMessages];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    if (![[User sharedUser] isLoggedIn]) {
        [self login];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    BoxViewController *boxViewController = [[BoxViewController alloc] initWithNibName:@"BoxViewController" bundle:nil box:[self.boxes objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:boxViewController animated:YES];
    [boxViewController release];
     
}

@end
