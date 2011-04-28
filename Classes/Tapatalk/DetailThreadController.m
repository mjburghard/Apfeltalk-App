//
//  DetailThreadController.m
//  Tapatalk
//
//  Created by Manuel Burghard on 21.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailThreadController.h"
#import "User.h"
#import "ATWebViewController.h"

#define DEFAULT_ROW_HEIGHT 44.0


@implementation DetailThreadController
@synthesize topic, posts, currentPost;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topic:(Topic *)aTopic {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.topic = aTopic;
        self.posts = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    self.currentPost = nil;
    self.posts = nil;
    self.topic = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Private Methods

- (void)loadData {
    NSURL *url = [NSURL URLWithString:[self tapatalkPluginPath]];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_thread</methodName><params><param><value><string>%i</string></value></param><param><value><int>0</int></value></param><param><value><int>19</int></value></param></params></methodCall>", self.topic.topicID];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
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

- (void)endEditing:(UIBarButtonItem *)sender {
    [activeView resignFirstResponder];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    self.navigationItem.hidesBackButton = NO;
}

- (void)reply {
    if (![[User sharedUser] isLoggedIn]) return;
    
    NSLog(@"Content: %@", answerCell.textView.text);
    
    NSURL *url = [NSURL URLWithString:[self tapatalkPluginPath]];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>reply_post</methodName><params><param><value><string>%i</string></value></param><param><value><string>%i</string></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", self.topic.forumID, 
                           self.topic.topicID, 
                           encodeString(@"answer"), 
                           encodeString(answerCell.textView.text)];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    if (connection) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    
    [self endEditing:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];
    NSString *s = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);
}

#pragma mark -
#pragma mark ContentCellDelegate & SubjectCellDelegate

- (BOOL)contentCell:(ContentCell *)cell shouldLoadRequest:(NSURLRequest *)aRequest {
    // This methode will open a GalleryView or a webView! 
    NSString *extension = [[[aRequest URL] absoluteString] pathExtension];
    
    BOOL isImage = NO;
    NSArray *extensions = [NSArray arrayWithObjects:@"tiff", @"tif", @"jpg", @"jpeg", @"gif", @"png",@"bmp", @"BMPf", @"ico", @"cur", @"xbm", nil];
    
    for (NSString *e in extensions) {
        if ([extension isEqualToString:e]) {
            isImage = YES;
        }
    }
    
    if (isImage) {
        GCImageViewer *imageViewer = [[GCImageViewer alloc] initWithURL:[aRequest URL]];
        [self.navigationController pushViewController:imageViewer animated:YES];
        [imageViewer release];
    }
    
    ATWebViewController *webViewController = [[ATWebViewController alloc] initWithNibName:@"ATWebViewController" bundle:nil URL:[aRequest URL]];
    [self.navigationController pushViewController:webViewController animated:YES];
    [webViewController release];
    
    return NO;
}

- (void)contentCellDidBeginEditing:(ContentCell *)cell {
    activeView = cell.textView;
    if (self.navigationItem.hidesBackButton) {
        return;
    }
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditing:)] 
                                     animated:YES];
}

- (void)subjectCellDidBeginEditing:(SubjectCell *)cell {
    activeView = cell.subjectField;
    if (self.navigationItem.hidesBackButton) {
        return;
    }
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditing:)] 
                                     animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = topic.title;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.posts count] == 0) {
        return DEFAULT_ROW_HEIGHT;
    }
    
    if (indexPath.section == [self.posts count] +1) return DEFAULT_ROW_HEIGHT;
    if ([self.posts count] != 0 && indexPath.row == 0) {
        if (indexPath.section == [self.posts count]) return 100.0;
        if (indexPath.section == [self.posts count]) return DEFAULT_ROW_HEIGHT;
        return 22.0;
    } else if (indexPath.row == 1) {
        if (indexPath.section == [self.posts count]) return DEFAULT_ROW_HEIGHT;
        CGSize size = [[(Post *)[self.posts objectAtIndex:indexPath.section] content] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0] constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
        return size.height; // Row is to high. But I don't know why.
    }
    
    return DEFAULT_ROW_HEIGHT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == [self.posts count]) {
        if ([self.posts count] != 0) 
            return NSLocalizedString(@"Answer", @"");
        return nil;
    } else if (section == [self.posts count] +1) return nil;
    return [(Post *)[self.posts objectAtIndex:section] title];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.posts count] == 0) {
        return 1;
    }
    return [self.posts count]+2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == [self.posts count]) {
        if ([self.posts count] == 0) {
            return 1;
        }
        return 2;
    }
    if (section == [self.posts count]+1) {
        return 1;
    }
    return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AuthorCellIdentifier = @"AuthorCell";
    static NSString *ContentCellIdentifier = @"ContentCell";
    static NSString *ActionsCellIdentifier = @"ActionsCell";
    static NSString *CellIdentifier = @"Cell"; // Will be removed in the final app!
    
    Post *p;
    
    if ([self.posts count] != 0 && indexPath.section < [self.posts count]) {
        p = (Post *)[self.posts objectAtIndex:indexPath.section];
    }
    
	if (indexPath.row == 0) {
		if (indexPath.section == [self.posts count] && [self.posts count] == 0) { // For the loading cell
			if(loadingCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
            }
            
            return loadingCell;
		}
        
        if (indexPath.section == [self.posts count] +1) {
            UITableViewCell *loadMoreCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (loadMoreCell == nil) {
                loadMoreCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            loadMoreCell.textLabel.text = @"Load more";
            return loadMoreCell;
        }
        
        if (indexPath.section == [self.posts count] && [self.posts count] != 0) {
            answerCell = (ContentCell *)[tableView dequeueReusableCellWithIdentifier:ContentCellIdentifier];
            if (answerCell == nil) {
                answerCell = [[[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContentCellIdentifier] autorelease];
            }
            answerCell.textView.editable = YES;
            answerCell.delegate = self;
            return answerCell;
        }
		
		UITableViewCell *authorCell = [tableView dequeueReusableCellWithIdentifier:AuthorCellIdentifier];
		if (authorCell == nil) {
			authorCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AuthorCellIdentifier] autorelease];
		}
		authorCell.textLabel.text = p.author;
        authorCell.detailTextLabel.textColor = authorCell.textLabel.textColor;
        authorCell.detailTextLabel.text = @"Datum";
        
		return authorCell;
	}
    if (indexPath.row == 1) {
        if (indexPath.section == [self.posts count] && [self.posts count] != 0) {
            UITableViewCell *actionsCell = [tableView dequeueReusableCellWithIdentifier:ActionsCellIdentifier];
            if (actionsCell == nil) {
                actionsCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActionsCellIdentifier] autorelease];
            }
            actionsCell.textLabel.text = @"Answer";
            actionsCell.textLabel.textAlignment = UITextAlignmentCenter;
            return actionsCell;
        }
        
		ContentCell *contentCell = (ContentCell *)[tableView dequeueReusableCellWithIdentifier:ContentCellIdentifier];
		if (contentCell == nil) {
			contentCell = [[[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContentCellIdentifier] autorelease];
		}
        contentCell.textView.text = p.content;
        contentCell.delegate = self;
		return contentCell;
	} 
    if (indexPath.row == 2) {
		UITableViewCell *actionsCell = [tableView dequeueReusableCellWithIdentifier:ActionsCellIdentifier];
		if (actionsCell == nil) {
			actionsCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActionsCellIdentifier] autorelease];
		}
		actionsCell.textLabel.text = @"Answer";
        actionsCell.textLabel.textAlignment = UITextAlignmentCenter;
		return actionsCell;
	}
    
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self.posts count] && [self.posts count] != 0) {
        [self reply];
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark-
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict {
    self.currentString = [NSMutableString new];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data"]) {
        self.currentPost = [[Post alloc] init];
    }
    
    self.path = [self.path stringByAppendingPathComponent:elementName];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/name"]) {
        if ([self.currentString isEqualToString:@"post_id"]) {
            isPostID = YES;
        } else if ([self.currentString isEqualToString:@"post_title"]) {
            isPostTitle = YES;
        } else if ([self.currentString isEqualToString:@"post_content"]) {
            isPostContent = YES;
        } else if ([self.currentString isEqualToString:@"post_author_id"]) {
            isPostAuthorID = YES;
        } else if ([self.currentString isEqualToString:@"post_author_name"]) {
            isPostAuthor = YES;
        }
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/value/base64"]) {
        // First decode base64 data
        
        self.currentString = (NSMutableString *)decodeString(self.currentString);
        
        if (isPostTitle) {
            isPostTitle = NO;
            self.currentPost.title = self.currentString;
        } else if (isPostContent) {
            isPostContent = NO;
            self.currentPost.content = self.currentString;
        } else if (isPostAuthor) {
            self.currentPost.author = self.currentString;
        }
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/value/string"]) {
        if (isPostID) {
            isPostID = NO;
            self.currentPost.postID = [self.currentString intValue];
        } else if (isPostAuthorID) {
            isPostAuthorID = NO;
            self.currentPost.authorID = [self.currentString intValue];
        }
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/value/boolean"]) {
    }
    
    self.path = [self.path stringByDeletingLastPathComponent];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data"]) {
        [self.posts addObject:self.currentPost];
    } 
    
    self.currentString = nil;
}

@end
