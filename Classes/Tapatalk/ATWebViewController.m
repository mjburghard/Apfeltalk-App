//
//  ATWebViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 28.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATWebViewController.h"
#import "SHK.h"

#define ReloadButtonIndex 4


@implementation ATWebViewController
@synthesize webView, url, toolbar, topBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)aUrl {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.url = aUrl;
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)dealloc {
    self.topBar = nil;
    self.url = nil;
    self.toolbar = nil;
    self.webView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark IBActions

- (IBAction)share:(UIBarButtonItem *)sender {
    
	SHKItem *item = [SHKItem URL:self.url title:@"Hat einen interessanten Link für Dich!"];
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	[actionSheet showFromToolbar:self.toolbar];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
/*- (void)loadView {
}*/

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.webView stopLoading];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
        [self.topBar setItems:[NSArray arrayWithObject:doneButton] animated:YES];
        [doneButton release];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)aWebView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self.toolbar items]];
    [items removeObjectAtIndex:ReloadButtonIndex];
    UIBarButtonItem *reloadButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
                                                                                 target:self.webView 
                                                                                 action:@selector(stopLoading)];
    [items insertObject:reloadButton atIndex:ReloadButtonIndex];

    [self.toolbar setItems:items];
    [reloadButton release];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self.toolbar items]];
    [items removeObjectAtIndex:ReloadButtonIndex];
    UIBarButtonItem *reloadButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                 target:self.webView 
                                                                                 action:@selector(reload)];
    [items insertObject:reloadButton atIndex:ReloadButtonIndex];
    [self.toolbar setItems:items];
    self.url = self.webView.request.URL;
    [reloadButton release];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error: %@", [error localizedDescription]);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self.toolbar items]];
    [items removeObjectAtIndex:ReloadButtonIndex];
    UIBarButtonItem *reloadButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                 target:self.webView 
                                                                                 action:@selector(reload)];
    [items insertObject:reloadButton atIndex:ReloadButtonIndex];
    [self.toolbar setItems:items];
    [reloadButton release];
}

@end
