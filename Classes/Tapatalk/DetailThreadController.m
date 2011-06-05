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
#import "ContentTranslator.h"
#import "AnswerViewController.h"
#import "SFHFKeychainUtils.h"
#import "Apfeltalk_MagazinAppDelegate.h"

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
        self.numberOfPosts = self.topic.numberOfPosts;
        isAnswering = NO;
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
#pragma mark Private and Public Methods

- (void)loginWasSuccessful {
    self.topic.userCanPost = YES;
    NSArray *indexes = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:[self.posts count]]];
    [self.tableView performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:indexes waitUntilDone:NO];
}

- (NSInteger)numberOfSites {
    NSInteger numberOfSites;
    if (numberOfPosts % 10 == 0) {
        numberOfSites = numberOfPosts / 10;
    } else {
        numberOfSites = numberOfPosts / 10 + 1;
    }
    return numberOfSites;
}

- (void)loadLastSite {
    site = [self numberOfSites]-1; 
}

- (void)loadData {
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>get_thread</methodName><params><param><value><string>%i</string></value></param><param><value><int>%i</int></value></param><param><value><int>%i</int></value></param></params></methodCall>", self.topic.topicID, self.site*10, self.site*10+9];
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
    if (self.site == [self numberOfSites]-1 && self.topic.hasNewPost) {
        xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>mark_topic_read</methodName><params><param><value><array><data><value><string>%i</string></value></data></array></value></param></params></methodCall>", self.topic.topicID];
        
        [self sendRequestWithXMLString:xmlString cookies:YES delegate:nil];
    }
}

- (void)endEditing:(UIBarButtonItem *)sender {
    [activeView resignFirstResponder];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    self.navigationItem.hidesBackButton = NO;
}

- (void)reply {
    if (![[User sharedUser] isLoggedIn]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"ATLocalizable", @"") message:NSLocalizedStringFromTable(@"Please login...", @"ATLocalizable", @"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
        alertView.tag = 2;
        [alertView show];
        [alertView release];
        return;
    } else if (!self.topic.userCanPost) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"ATLocalizable", @"") message:NSLocalizedStringFromTable(@"You don't have rights to answer", @"ATLocalizable", @"") delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ATLocalizable", @"") otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    ContentTranslator *translator = [[ContentTranslator alloc] init];
    NSString *content = [translator translateStringForAT:answerCell.textView.text];
    [translator release];
    NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>reply_post</methodName><params><param><value><string>%i</string></value></param><param><value><string>%i</string></value></param><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", self.topic.forumID, 
                           self.topic.topicID, 
                           encodeString(@"answer"), 
                           encodeString(content)];
    [self sendRequestWithXMLString:xmlString cookies:YES delegate:self];
    answerCell.textView.text = @"";
    [self endEditing:nil];
    isAnswering = YES;
}

- (void)previous {
    if (site > 0) {
        site--;
        [self loadData];
        ATActivityIndicator *at = [ATActivityIndicator activityIndicator];
        at.message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Site %i of %i", @"ATLocalizable", @""), site+1, [self numberOfSites]];
        [at showSpinner];
        [at show];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)last {
    site = [self numberOfSites]-1;
    [self loadData];
    ATActivityIndicator *at = [ATActivityIndicator activityIndicator];
    at.message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Site %i of %i", @"ATLocalizable", @""), site+1, [self numberOfSites]];
    [at showSpinner];
    [at show];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)next {
    if (site < [self numberOfSites]-1) {
        site++;
        [self loadData];
        ATActivityIndicator *at = [ATActivityIndicator activityIndicator];
        at.message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Site %i of %i", @"ATLocalizable", @""), site+1, [self numberOfSites]];
        [at showSpinner];
        [at show];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)showActionSheet {
    NSString *loginButtonTitle, *answerButton;
    if ([[User sharedUser] isLoggedIn]) {
        loginButtonTitle = NSLocalizedStringFromTable(@"Logout", @"ATLocalizable", @"");
        answerButton = NSLocalizedStringFromTable(@"Answer", @"ATLocalizable", @"");
    } else {
        loginButtonTitle = NSLocalizedStringFromTable(@"Login", @"ATLocalizable", @"");
        answerButton = nil;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"") destructiveButtonTitle:nil otherButtonTitles:loginButtonTitle, NSLocalizedStringFromTable(@"Last", @"ATLocalizable", @""), answerButton, nil];
    if (self.navigationController.tabBarController.tabBar) {
        [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    } else {
        [actionSheet showInView:self.view];
    }
    [actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    AnswerViewController *answerViewController;
    switch (buttonIndex) {
        case 0:
            if ([[User sharedUser] isLoggedIn]) {
                [self logout];
            } else {
                [self login];
            } 
            break;
        case 1:
            [self last];
            break;
        case 2:
            if ([[User sharedUser] isLoggedIn]) {
                answerViewController = [[AnswerViewController alloc] initWithNibName:@"AnswerViewController" bundle:nil topic:self.topic];
                [self.navigationController pushViewController:answerViewController animated:YES];
                [answerViewController release]; 
            }
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
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.tableView numberOfSections]-1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    activeView = cell.textView;
    if (self.navigationItem.hidesBackButton) {
        return;
    }
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditing:)];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
    [leftButton release];
}

#pragma mark -
#pragma mark UISwipeGestureRecognizer

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self next];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (site >0 ) {
            [self previous];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginWasSuccessful) name:@"ATLoginWasSuccessful" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.posts count] == 0) {
        return kDefaultRowHeight;
    }
    
    if (indexPath.section == [self.posts count] +1) return kDefaultRowHeight;
    if ([self.posts count] != 0 && indexPath.row == 0) {
        if (indexPath.section == [self.posts count]) return 100.0;
        return 30.0;
    } else if (indexPath.row == 1) {
        if (indexPath.section == [self.posts count]) return kDefaultRowHeight;
        
        ContentCell *contentCell = [[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CalculateCell" tableViewWidth:CGRectGetWidth(self.tableView.frame)];
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == [tableView numberOfSections]-1) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Site %i of %i", @"ATLocalizable", @""), site+1, [self numberOfSites]];
    }
    
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AuthorCellIdentifier = @"AuthorCell";
    static NSString *ContentCellIdentifier = @"ContentCell";
    static NSString *ActionsCellIdentifier = @"ActionsCell";
    static NSString *AnswerCellIdentifier = @"AnswerCell";
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
            answerCell = (ContentCell *)[tableView dequeueReusableCellWithIdentifier:AnswerCellIdentifier];
            if (answerCell == nil) {
                answerCell = [[[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AnswerCellIdentifier  tableViewWidth:CGRectGetHeight(self.tableView.frame)] autorelease]; 
            }
            answerCell.textView.scrollEnabled = YES;
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
        [outFormatter release];
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
            if (self.topic.userCanPost) {
                actionsCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }
            return actionsCell;
        }
        
		ContentCell *contentCell = (ContentCell *)[tableView dequeueReusableCellWithIdentifier:ContentCellIdentifier];
		if (contentCell == nil) {
			contentCell = [[[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContentCellIdentifier  tableViewWidth:CGRectGetHeight(self.tableView.frame)] autorelease];
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
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self endEditing:nil];
    AnswerViewController *answerViewController = [[AnswerViewController alloc] initWithNibName:@"AnswerViewController" bundle:nil topic:self.topic];
    answerViewController.textView.text = answerCell.textView.text;
    answerCell.textView.text = @"";
    [self.navigationController pushViewController:answerViewController animated:YES];
    [answerViewController release];
}

#pragma mark-
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict {
    self.currentString = [NSMutableString string];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data"]) {
        self.currentPost = [[[Post alloc] init] autorelease];
    } else if ([self.path isEqualToString:@"methodResponse/fault"]) {
        isError = YES;
    }
    
    self.path = [self.path stringByAppendingPathComponent:elementName];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    if (isError && [self.path isEqualToString:@"methodResponse/fault/value/struct/member/value/string"]) {
        isError = NO;
        NSLog(@"Error: %@", self.currentString);
    }
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/name"]) {
        if ([self.currentString isEqualToString:@"total_post_num"]) {
            isNumberOfPosts = YES;
        } else if ([self.currentString isEqualToString:@"can_reply"]) {
            isCanReply = YES;
        }
    }
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/int"] && isNumberOfPosts) {
        isNumberOfPosts = NO;
        self.numberOfPosts = [self.currentString integerValue];
    }
                    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/boolean"]) {
        if (isCanReply) {
            isCanReply = NO;
            NSLog(@"User can post: %@", self.currentString);
            self.topic.userCanPost = [self.currentString boolValue];
        }
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
            ContentTranslator *translator = [ContentTranslator new];
            self.currentPost.content = [translator translateStringForiOS:self.currentString];
            [translator release];
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
        [dateFormatter release];
        [locale release];
    }
    
    self.path = [self.path stringByDeletingLastPathComponent];
    
    if ([self.path isEqualToString:@"methodResponse/params/param/value/struct/member/value/array/data"]) {
        [self.dataArray addObject:self.currentPost];
    } 
    
    self.currentString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (isAnswering) {
        isAnswering = NO;
        self.dataArray = nil;
        self.path = nil;
        self.currentPost = nil;
        [self performSelectorOnMainThread:@selector(loadData) withObject:nil waitUntilDone:NO];
        return;
    }
    self.posts = self.dataArray;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    self.currentPost = nil;
    self.dataArray = nil;
    self.path = nil;
}

@end
