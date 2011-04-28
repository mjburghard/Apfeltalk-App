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
#import "User.h"
#import "UserXMLParser.h"

@implementation ForumViewController
@synthesize receivedData, sections, currentString, path, currentSection, currentSubForum, currentSubSubForum;

#pragma mark -
#pragma mark init & dealloc

- (void)dealloc {
    self.currentSubSubForum = nil;
    self.path = nil;
    self.currentSection = nil;
    self.currentSubForum = nil;
    self.currentString = nil;
    self.sections = nil;
    self.receivedData = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public & private methods

- (NSString *)tapatalkPluginPath {
    return @"http://apfeltalk.de/forum/mobiquo/mobiquo.php/";
}

NSString * decodeString(NSString *aString) {
    NSData *stringData = [aString dataUsingEncoding:NSASCIIStringEncoding];
    size_t decodedDataSize = EstimateBas64DecodedDataSize([stringData length]);
    uint8_t *decodedData = calloc(decodedDataSize, sizeof(uint8_t));
    Base64DecodeData([stringData bytes], [stringData length], decodedData, &decodedDataSize);
    
    stringData = [NSData dataWithBytesNoCopy:decodedData length:decodedDataSize freeWhenDone:YES];
    
    NSString *s = [[[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding] autorelease];
    
    
    return s;
    
}

NSString * encodeString(NSString *aString) {
    NSData *stringData = [aString dataUsingEncoding:NSUTF8StringEncoding];
    size_t encodedDataSize = EstimateBas64EncodedDataSize([stringData length]);
    char *encodedData = malloc(encodedDataSize);
    Base64EncodeData([stringData bytes], [stringData length], encodedData, &encodedDataSize);
    
    stringData = [NSData dataWithBytesNoCopy:encodedData length:encodedDataSize freeWhenDone:YES];
    
    return [[[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] autorelease];
    
}

- (NSString *)decodeString:(NSString *)aString {
    return decodeString(aString);
}

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.receivedData];
    [parser setDelegate:self];
    [parser parse];
    self.receivedData = nil;
    [pool release];
}

- (void)loadData {
    NSURL *url = [NSURL URLWithString:[self tapatalkPluginPath]];
    NSData *data = [@"<?xml version=\"1.0\"?><methodCall><methodName>get_forum</methodName></methodCall>" dataUsingEncoding:NSASCIIStringEncoding];
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

- (void)login {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Bitte melde Dich an...", @"") 
                                                        message:@"\n\n\n" 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"") 
                                              otherButtonTitles:NSLocalizedString(@"Anmelden", @""), nil];
    alertView.tag = 0;
    usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [usernameTextField setBackgroundColor:[UIColor whiteColor]];
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 75.0, 260.0, 25.0)];
    [passwordTextField setBackgroundColor:[UIColor whiteColor]];
    usernameTextField.placeholder = NSLocalizedString(@"Username", @"");
    passwordTextField.placeholder = NSLocalizedString(@"Password", @"");
    passwordTextField.secureTextEntry = YES;
    
    [alertView addSubview:usernameTextField];
    [alertView addSubview:passwordTextField];
    [usernameTextField becomeFirstResponder];
    
    [alertView show];
    [alertView release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 0:
            if (buttonIndex == 1 && [usernameTextField.text length] != 0 &&  [passwordTextField.text length] != 0) {
                NSURL *url = [NSURL URLWithString:[self tapatalkPluginPath]];
                NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>login</methodName><params><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", encodeString(usernameTextField.text), encodeString(passwordTextField.text)];
                NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:data];
                [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
                if (userXMLParser != nil) {
                    [userXMLParser release];
                    userXMLParser = nil;
                }
                userXMLParser = [[UserXMLParser alloc] initWithRequest:request delegate:self];
                
            } else if (buttonIndex == 0 ) {
                [usernameTextField release];
                [passwordTextField release];
            }
            break;
        case 1:
            if (buttonIndex == 1) {
                [self login];
            }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UserXMLParserDelegate

- (void)userIsLoggedIn:(BOOL)isLoggedIn {
    if (isLoggedIn) {
        NSLog(@"YES");
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Logout", @"");
        [usernameTextField release];
        [passwordTextField release];
    } else {
        NSLog(@"NO");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fehler", @"") 
                                                        message:NSLocalizedString(@"Wrong username or password", @"") 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                              otherButtonTitles:NSLocalizedString(@"Retry", @""), nil];
        alertView.tag = 1;
        [alertView show];
        [alertView release];
    }
}

- (void)userXMLParserDidFinish {
    [userXMLParser release];
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
    self.receivedData = nil;
    NSLog(@"%@", [error localizedDescription]);
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Forum";
    self.sections = [NSMutableArray array];
    self.path = @"";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = NSLocalizedString(@"Back", @"");
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    NSString *buttonTitle;
    if ([[User sharedUser] isLoggedIn]) {
        buttonTitle = NSLocalizedString(@"Logout", @"");
    } else {
        buttonTitle = NSLocalizedString(@"Login", @"");
    }
    
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(login)];
    self.navigationItem.rightBarButtonItem = loginButton;
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [(Section *)[self.sections objectAtIndex:section] name];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    
    cell.textLabel.text = [(SubForum *)[[(Section *)[self.sections objectAtIndex:indexPath.section] subFora] objectAtIndex:indexPath.row] name];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
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

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark-
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict {
    self.currentString = [NSMutableString new];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data"]) {
        self.currentSection = [[Section alloc] init];
        self.currentSection.subFora = [NSMutableArray array];
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data"]) {
        self.currentSubForum = [[SubForum alloc] init];
        self.currentSubForum.subFora = [NSMutableArray array];
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data"]) {
        self.currentSubSubForum = [[SubForum alloc] init];
    }
    
    self.path = [self.path stringByAppendingPathComponent:elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/name"]) {
        if ([self.currentString isEqualToString:@"forum_name"]) {
            isForumName = YES;
        } else if ([self.currentString isEqualToString:@"description"]) {
            isDescription = YES;
        } else if ([self.currentString isEqualToString:@"sub_only"]) {
            isSubOnly = YES;
        } else if ([self.currentString isEqualToString:@"child"]) {
            isChild = YES;
        } else if ([self.currentString isEqualToString:@"forum_id"]) {
            isForumID = YES;
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/base64"]) {
        // First decode base64 data
        
        self.currentString = (NSMutableString *)decodeString(self.currentString);
        
        if (isForumName) {
            isForumName = NO;
            self.currentSection.name = self.currentString;
        }
        
        if (isDescription) {
            isDescription = NO;
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/string"]) {
        if (isForumID) {
            isForumID = NO;
            self.currentSection.forumID = [self.currentString intValue];
        }
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/boolean"]) {
        if (isSubOnly) {
            isSubOnly = NO;
            if ([self.currentString isEqualToString:@"1"]) {
                self.currentSection.subForaOnly = YES;
            } else {
                self.currentSection.subForaOnly = NO;
            }
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/name"]) {
        if ([self.currentString isEqualToString:@"forum_name"]) {
            isChildForumName = YES;
        } else if ([self.currentString isEqualToString:@"description"]) {
            isChildDescription = YES;
        } else if ([self.currentString isEqualToString:@"sub_only"]) {
            isChildSubOnly = YES;
        } else if ([self.currentString isEqualToString:@"forum_id"]) {
            isChildForumID = YES;
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/base64"]) {
        // First decode base64 data
        
        self.currentString = (NSMutableString *)decodeString(self.currentString);
        if (isChildForumName) {
            isChildForumName = NO;
            self.currentSubForum.name = self.currentString;
        }
        
        if (isChildDescription) {
            isChildDescription = NO;
            
            self.currentSubForum.description = self.currentString;
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/string"]) {
        if (isChildForumID) {
            isChildForumID = NO;
            self.currentSubForum.forumID = [self.currentString intValue];
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/boolean"]) {
        if (isChildSubOnly) {
            isChildSubOnly = NO;
            if ([self.currentString isEqualToString:@"1"]) {
                self.currentSubForum.subForaOnly = YES;
            } else {
                self.currentSubForum.subForaOnly = NO;
            }
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data/value/struct/member/name"]) {
        if ([self.currentString isEqualToString:@"forum_name"]) {
            isChildChildForumName = YES;
        } else if ([self.currentString isEqualToString:@"description"]) {
            isChildChildDescription = YES;
        } else if ([self.currentString isEqualToString:@"sub_only"]) {
            isChildChildSubOnly = YES;
        } else if ([self.currentString isEqualToString:@"forum_id"]) {
            isChildChildForumID = YES;
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data/value/struct/member/value/base64"]) {
        // First decode base64 data
        
        self.currentString = (NSMutableString *)decodeString(self.currentString);
        if (isChildChildForumName) {
            isChildChildForumName = NO;
            self.currentSubSubForum.name = self.currentString;
        }
        
        if (isChildChildDescription) {
            isChildChildDescription = NO;
            
            self.currentSubSubForum.description = self.currentString;
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data/value/struct/member/value/string"]) {
        if (isChildChildForumID) {
            isChildChildForumID = NO;
            self.currentSubSubForum.forumID = [self.currentString intValue];
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data/value/struct/member/value/boolean"]) {
        if (isChildChildSubOnly) {
            isChildChildSubOnly = NO;
            if ([self.currentString isEqualToString:@"1"]) {
                self.currentSubSubForum.subForaOnly = YES;
            } else {
                self.currentSubSubForum.subForaOnly = NO;
            }
        }
    } 
    
    
    self.path = [self.path stringByDeletingLastPathComponent];
    if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data"]) {
        [self.sections addObject:self.currentSection];
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data"]) {
        [self.currentSection.subFora addObject:self.currentSubForum];
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/array/data/value/struct/member/value/array/data"]) {
        [self.currentSubForum.subFora addObject:self.currentSubSubForum];
    }
    
    self.currentString = nil;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

@end
