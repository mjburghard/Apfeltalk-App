//
//  DetailMessageViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailMessageViewController.h"
#import "ContentCell.h"
#import "ATContactDataSource.h"
#import "ATContactModel.h"

@implementation DetailMessageViewController
@synthesize message;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    self.message = nil;
    [super dealloc];
}

#pragma mark -

- (void)loadMessage {
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_message</methodName><params><param><value><string>%i</string></value></param><param><value><string>%i</string></value></param></params></methodCall>", self.message.messageID, self.message.boxID];
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}
/*
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
*/
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
    NSString *messageString = [(TTMessageTextField *)[fields lastObject] text];
    subject = [translator translateStringForAT:subject];
    messageString = [translator translateStringForAT:messageString];
    
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>create_message</methodName><params><param><value><array><data>%@</data></array></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param><param><value><int>%i</int></value></param><param><value><string>%i</string></value></param></params></methodCall>", recipients, encodeString(subject), encodeString(messageString), 1, self.message.messageID];
    self.isSending = YES;
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}
/*
#pragma mark -
#pragma mark ATContactPickerDelegate

- (void)contactPicker:(ATContactPicker *)contactPicker didSelectContact:(NSString *)contactName {
    TTMessageController *messageController = (TTMessageController *)[[(UINavigationController *)self.modalViewController viewControllers] objectAtIndex:0];
    [messageController addRecipient:contactName forFieldAtIndex:0];
    [messageController dismissModalViewControllerAnimated:YES];
}
*/
#pragma mark -
#pragma mark XMLRPCResponseParserDelegate

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
        ContentTranslator *translator = [ContentTranslator contentTranslator];
        self.message.content = [translator translateStringForiOS:[dictionary valueForKey:@"text_body"]];
        [self.tableView reloadData];
    }
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.message.subject;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadMessage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];

}

#pragma mark -

- (CGFloat)groupedCellMarginWithTableWidth:(CGFloat)tableViewWidth
{
    CGFloat marginWidth;
    if(tableViewWidth > 20)
    {
        if(tableViewWidth < 400)
        {
            marginWidth = 10;
        }
        else
        {
            marginWidth = MAX(31, MIN(45, tableViewWidth*0.06));
        }
    }
    else
    {
        marginWidth = tableViewWidth - 10;
    }
    return marginWidth;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1 || self.message.content == nil) {
        return nil;
    }
    return self.message.subject;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.message.content == nil)
        return 1;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            if (self.message.content == nil) 
                return tableView.rowHeight;
            CGFloat margin = [self groupedCellMarginWithTableWidth:CGRectGetWidth(self.tableView.frame)];
            CGFloat width = CGRectGetWidth(self.tableView.frame) - 2 * margin - 16.0;
            CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
            CGFloat fontSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"fontSize"];
            CGSize size = [self.message.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:fontSize] constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];   
            return size.height + 16.0;
            break;
        } case 1: {
            return tableView.rowHeight;
            break;
        } default: {
            return tableView.rowHeight;
            break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContentCellIdentifier = @"ContentCellIdentifier";
    static NSString *AnswerCellIdentifier = @"AnswerCellIdentifier";
    
    if (self.message.content == nil) {
        if(loadingCell == nil)
            [[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
        
        return loadingCell;
    }
    
    switch (indexPath.section) {
        case 0: {
            ContentCell *contentCell = (ContentCell *)[tableView dequeueReusableCellWithIdentifier:ContentCellIdentifier];
            
            if (contentCell == nil) {
                contentCell = [[[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContentCellIdentifier tableViewWidth:CGRectGetWidth(self.tableView.frame)] autorelease];
            }
            
            contentCell.textView.text = self.message.content;
            return contentCell;
            break;
        } case 1: {
            UITableViewCell *answerCell = [tableView dequeueReusableCellWithIdentifier:AnswerCellIdentifier];
            if (answerCell == nil) {
                answerCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AnswerCellIdentifier] autorelease];
            }
            
            answerCell.textLabel.text = ATLocalizedString(@"Answer", nil);
            answerCell.textLabel.textAlignment = UITextAlignmentCenter;
            return answerCell;
            break;
        } default: {
            break;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        } case 1: {
            NSArray *recipients = [NSArray arrayWithObject:self.message.sender];
            TTMessageController *messageController = [[TTMessageController alloc] initWithRecipients:recipients];
            messageController.delegate = self;
            ATContactDataSource *dataSource = [[ATContactDataSource alloc] init];
            dataSource.messageController = messageController;
            messageController.dataSource = dataSource;
            messageController.showsRecipientPicker = YES;
            messageController.navigationBarTintColor = ATNavigationBarTintColor;
            
            NSString *reIdentifier = ATLocalizedString(@"Re", nil);
            
            if ([self.message.subject rangeOfString:reIdentifier].location == 0) {
                messageController.subject = self.message.subject;
            } else {
                messageController.subject = [NSString stringWithFormat:@"%@: %@", ATLocalizedString(@"Re", nil), self.message.subject];
            }
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:messageController];
            [self presentModalViewController:navigationController animated:YES];
            [navigationController release];
            [messageController release];
            [dataSource release];
            break;
        } default: {
            break;
        }
    }
}

@end
