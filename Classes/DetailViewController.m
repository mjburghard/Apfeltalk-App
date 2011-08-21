//
//  DetailViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Laurids Düllmann, Jesper Frommherz (Graphics),
//						Patrick Rollbis (Graphics),
//						
//	This program is free software; you can redistribute it and/or
//	modify it under the terms of the GNU General Public License
//	as published by the Free Software Foundation; either version 2
//	of the License, or (at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software
//	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.//
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "ATMXMLUtilities.h"
#import "GCImageViewer.h"
#import "ATWebViewController.h"

#define MAX_IMAGE_WIDTH ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 728 :280)

@implementation DetailViewController

@synthesize story, toolbar, activityIndicator;

// This is the new designated initializer for the class
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self != nil) {
        if (newStory) {
            [self setStory:newStory];
        } else {
            Story *aStory = [[Story alloc] init];
            aStory.summary = [NSString stringWithFormat:@"<div style=\"text-align: center;\">%@</div>", NSLocalizedStringFromTable(@"Loading data", @"ATLocalizable", @"")];
            [self setStory:aStory];
            [aStory release];
        }
        self.hidesBottomBarWhenPushed = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideTabBar"];
	}
	return self;
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{	
    NSURL *loadURL = [[request URL] retain]; // retain the loadURL for use
    NSString *loadURLString = [loadURL absoluteString];
    if (([[loadURL scheme] isEqualToString:@"http"] || [[loadURL scheme] isEqualToString:@"https"]) && (navigationType == UIWebViewNavigationTypeLinkClicked )) { // Check if the scheme is http/https. You can also use these for custom links to open parts of your application.
        NSString *extension = [loadURLString pathExtension];
    
        BOOL isImage = NO;
        NSArray *extensions = [NSArray arrayWithObjects:@"tiff", @"tif", @"jpg", @"jpeg", @"gif", @"png",@"bmp", @"BMPf", @"ico", @"cur", @"xbm", nil];
    
        for (NSString *e in extensions) {
            if ([extension isEqualToString:e]) {
                isImage = YES;
            }
        }
    
        if (isImage) {
            NSString *imageLink = [loadURLString stringByReplacingOccurrencesOfString:@"/thumbs" withString:@""];
            
            GCImageViewer *galleryImageViewController = [[GCImageViewer alloc] initWithURL:[NSURL URLWithString:imageLink]];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self presentModalViewController:(UIViewController *)galleryImageViewController animated:YES];
            } else {
                [self.navigationController pushViewController:galleryImageViewController animated:YES];
            }
            [galleryImageViewController release];
            [loadURL release];
            return NO;
        } else {
            ATWebViewController *webViewController = [[ATWebViewController alloc] initWithNibName:@"ATWebViewController" bundle:nil URL:loadURL];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self presentModalViewController:webViewController animated:YES];
            } else {
                [self.navigationController pushViewController:webViewController animated:YES];
            }
            [webViewController release];
            [loadURL release];
            return NO;
        }
    }
    [ loadURL release ];
    return YES; // URL is not http/https and should open in UIWebView
}

- (NSUInteger)imageWidth
{
    NSUInteger width = 290;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        width = 675;
    
    return width;
}


- (NSString *) htmlString {
    return nil;
}


- (NSString *) rightBarButtonTitle {
	return NSLocalizedStringFromTable(@"Options", @"ATLocalizable", @"");
}

- (void)updateInterface
{
    [webview loadHTMLString:[self htmlString] baseURL:nil];
}

- (void)viewWillAppear:(BOOL)animated {    
    [super viewWillAppear:animated];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        UIBarButtonItem *i = [toolbar.items objectAtIndex:0];
        if (i.tag == 99) {
            [self invalidateRootPopoverButtonItem:i];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [webview stopLoading];
}


- (void)viewDidAppear:(BOOL)animated {
    [self updateInterface];
    [super viewDidAppear:animated];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [webview setBackgroundColor:[UIColor clearColor]];
    self.view.autoresizesSubviews = YES;
	webview.delegate = self;
    
	NSString * buttonTitle = [self rightBarButtonTitle];
    
    UIBarButtonItem *speichernButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(speichern:)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.rightBarButtonItem = speichernButton;
    } else {
        NSMutableArray *items = [toolbar.items mutableCopy];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        [items addObject:flexibleSpace];
        [items addObject:speichernButton];
        [toolbar setItems:items animated:NO];
        [flexibleSpace release];
        [items release];
    }
    [speichernButton release];
}

- (IBAction)speichern:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *popoverController = [[[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0] popoverController]; 
        if ([popoverController isPopoverVisible]) {
            [popoverController dismissPopoverAnimated:YES];
        }
    }
}

#pragma mark -

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Add the popover button to the toolbar.
    barButtonItem.tag = 99;
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    [itemsArray insertObject:barButtonItem atIndex:0];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Remove the popover button from the toolbar.
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    [itemsArray removeObject:barButtonItem];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}

#pragma mark - Interfacerotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [webview loadHTMLString:[self htmlString] baseURL:nil];
}

- (void)dealloc {
    self.activityIndicator = nil;
    self.toolbar = nil;
    [story release];
	[myMenu release];
	[super dealloc];
}

@end
