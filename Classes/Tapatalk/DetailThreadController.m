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
#import "ATActivityIndicator.h"

@implementation DetailThreadController
@synthesize topic, posts, currentPost, site, numberOfPosts;

const CGFloat kDefaultRowHeight = 44.0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topic:(Topic *)aTopic {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.topic = aTopic;
        self.posts = [NSMutableArray array];
        self.site = 0;
        self.numberOfPosts = 0;
    }
    return self;
}

- (void)dealloc {
    self.site = 0;
    self.numberOfPosts = 0;
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
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_thread</methodName><params><param><value><string>%i</string></value></param><param><value><int>%i</int></value></param><param><value><int>%i</int></value></param></params></methodCall>", self.topic.topicID, self.site*10, self.site*10+9];
    NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if (connection) {
        self.posts = [NSMutableArray array];
        [self.tableView reloadData];
    }
    
    [connection start];
}

- (void)endEditing:(UIBarButtonItem *)sender {
    [activeView resignFirstResponder];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    self.navigationItem.hidesBackButton = NO;
}

- (void)reply {
    if (![[User sharedUser] isLoggedIn]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"ATLocalizable", @"") message:NSLocalizedStringFromTable(@"Please login...", @"ATLocalizable", @"") delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    
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
    }
    answerCell.textView.text = @"";
    [self endEditing:nil];
}

- (void)back {
    if (site > 0) {
        site--;
        [self loadData];
        ATActivityIndicator *at = [ATActivityIndicator activityIndicator];
        int numberOfSites;
        if (numberOfPosts % 10 == 0) {
            numberOfSites = numberOfPosts / 10;
        } else {
            numberOfSites = numberOfPosts / 10 + 1;
        }
        at.message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Site %i of %i", @"ATLocalizable", @""), site+1, numberOfSites];
        [at showSpinner];
        [at show];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)last {
    
}

- (void)next {
    int numberOfSites;
    if (numberOfPosts % 10 == 0) {
        numberOfSites = numberOfPosts / 10;
    } else {
        numberOfSites = numberOfPosts / 10 + 1;
    }
    if (site < numberOfSites-1) {
        site++;
        [self loadData];
        ATActivityIndicator *at = [ATActivityIndicator activityIndicator];
        at.message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Site %i of %i", @"ATLocalizable", @""), site+1, numberOfSites];
        [at showSpinner];
        [at show];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
        return NO;
    }
    
    ATWebViewController *webViewController = [[ATWebViewController alloc] initWithNibName:@"ATWebViewController" bundle:nil URL:[aRequest URL]];
    [self.navigationController pushViewController:webViewController animated:YES];
    [webViewController release];
    
    return NO;
}

- (void)contentCellDidBeginEditing:(ContentCell *)cell {
    [self.tableView scrollRectToVisible:[self.tableView rectForSection:[self.tableView numberOfSections] -2] animated:YES];
    
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

#pragma mark -
#pragma mark UISwipeGestureRecognizer

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self next];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (site >0 ) {
            [self back];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = topic.title;
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.tableView addGestureRecognizer:leftSwipeGestureRecognizer];
    [leftSwipeGestureRecognizer release];
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.tableView addGestureRecognizer:rightSwipeGestureRecognizer];
    [rightSwipeGestureRecognizer release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [self.posts count] && [self.posts count] != 0) {
        return 57.0;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == [self.posts count] && [self.posts count] != 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 47.0)];
        view.backgroundColor = [UIColor clearColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedStringFromTable(@"Back", @"ATLocalizable", @"") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(10, 10, 280/3.0, 37.0)];
        [view addSubview:button];
        
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedStringFromTable(@"Last", @"ATLocalizable", @"") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(last) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(280/3.0 + 20, 10, 280/3.0, 37.0)];
        button.enabled = NO;
        [view addSubview:button];
        
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedStringFromTable(@"Next", @"ATLocalizable", @"") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(310 - 280/3.0, 10, 280/3.0, 37.0)];
        [view addSubview:button];
        
        return view;
    }
    return nil;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.posts count] == 0) {
        return kDefaultRowHeight;
    }
    
    if (indexPath.section == [self.posts count] +1) return kDefaultRowHeight;
    if ([self.posts count] != 0 && indexPath.row == 0) {
        if (indexPath.section == [self.posts count]) return 100.0;
        if (indexPath.section == [self.posts count]) return kDefaultRowHeight;
        return 30.0;
    } else if (indexPath.row == 1) {
        if (indexPath.section == [self.posts count]) return kDefaultRowHeight;
        ContentCell *contentCell = [[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CalculateCell"];
        contentCell.textView.text = [(Post *)[self.posts objectAtIndex:indexPath.section] content];
        CGFloat height = contentCell.textView.contentSize.height+7;
        [contentCell release];
        return height;
    }
    
    return kDefaultRowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == [self.posts count]) {
        if ([self.posts count] != 0) 
            return NSLocalizedStringFromTable(@"Direct response", @"ATLocalizable", @"");
        return nil;
    } else if (section == [self.posts count] +1) return nil;
    return [(Post *)[self.posts objectAtIndex:section] title];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.posts count] == 0) {
        return 1;
    }
    return [self.posts count]+1;
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
        
        NSDateFormatter *outFormatter = [[NSDateFormatter alloc] init];
        [outFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
		authorCell.textLabel.text = p.author;
        authorCell.detailTextLabel.textColor = authorCell.textLabel.textColor;
        authorCell.detailTextLabel.text = [outFormatter stringFromDate:p.postDate];
        authorCell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        authorCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
		return authorCell;
	}
    if (indexPath.row == 1) {
        if (indexPath.section == [self.posts count] && [self.posts count] != 0) {
            UITableViewCell *actionsCell = [tableView dequeueReusableCellWithIdentifier:ActionsCellIdentifier];
            if (actionsCell == nil) {
                actionsCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActionsCellIdentifier] autorelease];
            }
            actionsCell.textLabel.text = NSLocalizedStringFromTable(@"Answer", @"ATLocalizable", @"");
            actionsCell.textLabel.textAlignment = UITextAlignmentCenter;
            return actionsCell;
        }
        
		ContentCell *contentCell = (ContentCell *)[tableView dequeueReusableCellWithIdentifier:ContentCellIdentifier];
		if (contentCell == nil) {
			contentCell = [[[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContentCellIdentifier] autorelease];
		}
        contentCell.textView.text = p.content;
        contentCell.textView.scrollEnabled = NO;
        contentCell.delegate = self;
		return contentCell;
	} 
    if (indexPath.row == 2) {
		UITableViewCell *actionsCell = [tableView dequeueReusableCellWithIdentifier:ActionsCellIdentifier];
		if (actionsCell == nil) {
			actionsCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActionsCellIdentifier] autorelease];
		}
		actionsCell.textLabel.text = NSLocalizedStringFromTable(@"Answer", @"ATLocalizable", @"");
        actionsCell.textLabel.textAlignment = UITextAlignmentCenter;
		return actionsCell;
	}
    
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self.posts count] && [self.posts count] != 0) {
        if (indexPath.row == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        if (indexPath.row == 1) {
            [self reply];
        }
    }
    if (indexPath.section == [self.posts count] +1) {
        [self loadData];
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
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"]) {
        if ([self.currentString isEqualToString:@"total_post_num"]) {
            isNumberOfPosts = YES;
        }
    }
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/int"] && isNumberOfPosts) {
        isNumberOfPosts = NO;
        self.numberOfPosts = [self.currentString integerValue];
    }
    
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
        
    } else if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data/value/struct/member/value/dateTime.iso8601"]) {
        self.currentString = (NSMutableString *)[self.currentString stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange(20, 1)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"];
        [dateFormatter setLocale:locale];
        NSString *dateFormat = @"yyyyMMdd'T'HH:mm:ssZZZ";
        [dateFormatter setDateFormat:dateFormat];
        self.currentPost.postDate = [dateFormatter dateFromString:self.currentString];
    }
    
    self.path = [self.path stringByDeletingLastPathComponent];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data"]) {
        [self.posts addObject:self.currentPost];
    } 
    
    self.currentString = nil;
}

@end
