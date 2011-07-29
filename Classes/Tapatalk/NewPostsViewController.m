//
//  NewPostsViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 21.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewPostsViewController.h"


@implementation NewPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.numberOfTopics = -1;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadData {
    NSString *xmlString = @"<?xml version=\"1.0\"?><methodCall><methodName>get_new_topic</methodName></methodCall>";
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
}

- (void)done {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)parse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    TopicParser *parser = [[TopicParser alloc] initWithData:self.receivedData basePath:@"methodResponse/params/param/value/array/data" delegate:self];
    [parser parse];
    [parser release];
    self.receivedData = nil;
    [pool release];
}

#pragma mark -
#pragma mark TopicParserDelegate

- (void)topicParserDidFinish:(NSMutableArray *)_topics {
    self.topics = _topics;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"New Posts", @"ATLocalizable", @"");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
    [doneButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
    
    if ([self.topics count] == 0 || self.numberOfTopics == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DetailThreadController *detailThreadController = [[DetailThreadController alloc] initWithNibName:@"DetailThreadController" bundle:nil topic:(Topic *)[self.topics objectAtIndex:indexPath.row]];
    [detailThreadController loadLastSite];
    [self.navigationController pushViewController:detailThreadController animated:YES];
    [detailThreadController release];
}

#pragma mark-
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict {
    self.currentString = [NSMutableString new];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data"]) {
        if (!isPrefixes) {
            self.currentTopic = [[Topic alloc] init];
        }
    }
    self.path = [self.path stringByAppendingPathComponent:elementName];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/name"]) {
        if ([self.currentString isEqualToString:@"topic_id"]) {
            isTopicID = YES;
        } else if ([self.currentString isEqualToString:@"topic_title"]) {
            isTopicTitle = YES;
        } else if ([self.currentString isEqualToString:@"forum_id"]) {
            isForumID = YES;
        } else if ([self.currentString isEqualToString:@"new_post"]) {
            isNewPost = YES;
        } else if ([self.currentString isEqualToString:@"reply_number"]) {
            isReplyNumber = YES;
        } else if ([self.currentString isEqualToString:@"is_closed"]) {
            isClosed = YES;
        } else if ([self.currentString isEqualToString:@"is_subscribed"]) {
            isSubscribed = YES; 
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/base64"]) {
        // First decode base64 data
        self.currentString = (NSMutableString *)decodeString(self.currentString);
        if (isTopicTitle) {
            isTopicTitle = NO;
            self.currentTopic.title = self.currentString;
        }
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/string"]) {
        if (isForumID) {
            isForumID = NO;
            self.currentTopic.forumID = [self.currentString intValue];
        }
        
        if (isTopicID) {
            isTopicID = NO;
            self.currentTopic.topicID = [self.currentString intValue];
        }
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/boolean"]) {
        if (isNewPost) {
            isNewPost = NO;
            self.currentTopic.hasNewPost = [self.currentString boolValue];
        } else if (isClosed) {
            isClosed = NO;
            self.currentTopic.closed = [self.currentString boolValue];
        } else if (isSubscribed) {
            isSubscribed = NO;
            self.currentTopic.subscribed = [self.currentString boolValue];
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"] && [self.currentString isEqualToString:@"prefixes"]) {
        isPrefixes = YES;
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data/value/struct/member/value/int"]) {
        if (isReplyNumber) {
            isReplyNumber = NO;
            self.currentTopic.numberOfPosts = [self.currentString integerValue]+1;
        }
    }
    
    self.path = [self.path stringByDeletingLastPathComponent];
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value"] && isPrefixes) {
        isPrefixes = NO;
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/array/data"]) {
        if (self.currentTopic != nil)
            [self.dataArray addObject:self.currentTopic];
        
    }
    
    self.currentString = nil;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.dataArray = [[NSMutableArray alloc] init];
    self.path = [[NSMutableString alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.currentTopic = nil;
    self.topics = self.dataArray;
    self.dataArray = nil;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

@end
