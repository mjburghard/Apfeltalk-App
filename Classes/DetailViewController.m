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

@synthesize story, toolbar;

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

- (NSString *) cssStyleString {
    NSURL *middleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DetailMiddle" ofType:@"png"]];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        middleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DetailMiddle-Landscape" ofType:@"png"]];
    }
	return [NSString stringWithFormat:@"background:url(%@) repeat-y; font:10pt Helvetica; padding-top:95px; padding-left:20px; padding-right:20px", [middleURL absoluteString]];
}

- (NSString *)baseHtmlString {
    NSURL *bottomURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DetailBottom" ofType:@"png"]];
    NSInteger width = 320;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
        width = 768;

    UIInterfaceOrientation orientation = self.interfaceOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        bottomURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DetailBottom-Landscape" ofType:@"png"]];
        width = 480;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            width = 703;
    }

    NSString *testString = [NSString stringWithFormat:@"<div style=\"position:absolute; top:0px; left:0px; width:%ipx\"><div style=\"%@\">"
                            @"%@</div><img src=\"%@\" alt=\"DetailBottom\"></div>", width,  [self cssStyleString], @"%@", [bottomURL absoluteString]];
    
    return testString;
}

- (NSString *)scaledHtmlStringFromHtmlString:(NSString *)htmlString
{
    int              newHeight;
    float            scaleFactor;
    NSRange          aRange, searchRange, valueRange;
    NSMutableString *mutableString = [NSMutableString stringWithString:htmlString];
    
    // Scale the images to fit into the webview
	// !!!:below:20090919 This needs more cleanup, possibly with XQuery. But not today...
    searchRange = NSMakeRange(0, [mutableString length]);
    while (searchRange.location < [mutableString length])
    {
        aRange = [mutableString rangeOfString:@"width=\"" options:NSLiteralSearch range:searchRange];
        if (aRange.location != NSNotFound)
        {
            searchRange = NSMakeRange(NSMaxRange(aRange), [mutableString length] - NSMaxRange(aRange));
            aRange = [mutableString rangeOfString:@"\"" options:NSLiteralSearch range:searchRange];
            valueRange = NSMakeRange(searchRange.location, aRange.location - searchRange.location);
            
            scaleFactor = (float)MAX_IMAGE_WIDTH / [[mutableString substringWithRange:valueRange] intValue];
            if (scaleFactor < 1.0)
            {
                [mutableString replaceCharactersInRange:valueRange withString:[NSString stringWithFormat:@"%d", MAX_IMAGE_WIDTH]];
                searchRange = NSMakeRange(valueRange.location, [mutableString length] - valueRange.location);
                aRange = [mutableString rangeOfString:@"height=\"" options:NSLiteralSearch range:searchRange];
                if (aRange.location != NSNotFound)
                {
                    searchRange = NSMakeRange(NSMaxRange(aRange), [mutableString length] - NSMaxRange(aRange));
                    aRange = [mutableString rangeOfString:@"\"" options:NSLiteralSearch range:searchRange];
                    valueRange = NSMakeRange(searchRange.location, aRange.location - searchRange.location);
                    newHeight = [[mutableString substringWithRange:valueRange] intValue] * scaleFactor;
                    [mutableString replaceCharactersInRange:valueRange withString:[NSString stringWithFormat:@"%d", newHeight]];
                    searchRange.length = [mutableString length] - searchRange.location;
                }
            }
        }
        else
        {
            searchRange.location = [mutableString length];
        }
    }
    
    // !!!:MacApple:20090919 This scales all image to MAX_IMAGE_WIDTH even if they are smaller, but I have no better idea.
    [mutableString replaceOccurrencesOfString:@"class=\"resize\"" withString:[NSString stringWithFormat:@"width=%i", MAX_IMAGE_WIDTH] options:NSLiteralSearch
                                        range:NSMakeRange(0, [mutableString length])];
    return mutableString;
}

- (NSString *) htmlString {
    // :below:20091220 All of this should be done with proper HTML Parsing
    NSString *bodyString = [[self story] summary];
	NSRange divRange = [bodyString rangeOfString:@"<fieldset"];
	if (divRange.location == NSNotFound)
        divRange.location = [bodyString length];
    
    divRange = [bodyString rangeOfString:@"</div>" options:NSBackwardsSearch range:NSMakeRange(0, divRange.location)];
    if (divRange.location == NSNotFound)
		return NSLocalizedString (@"Nachricht konnte nicht angezeigt werden", @"");
    
    NSString *extractedString = [NSString stringWithFormat:@"%@%@", [bodyString substringToIndex:divRange.location], @"<br/>"];
    
    // NSString *queryString = extractTextFromHTMLForQuery(bodyString, @"//div[1]"); not used
    // This does not work, as the query specifically extracts text
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"css"];
	NSString *cssCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // <div style=\"text-align:center; font-weight:bold;\">%@</div>
	bodyString = [NSString stringWithFormat:@"<style type=\"text/css\"> %@ </style>%@</div>", cssCode, extractedString];
    bodyString = [[self baseHtmlString] stringByReplacingOccurrencesOfString:@"%@" withString:bodyString];
    
	return [self scaledHtmlStringFromHtmlString:bodyString];
}


- (NSString *) rightBarButtonTitle {
	return NSLocalizedStringFromTable(@"Options", @"ATLocalizable", @"");
}

- (UIImage *) thumbimage {
	NSString *thumbnailLink = [[self story] thumbnailLink];
	UIImage * thumbnailImage = nil;
	if (thumbnailLink) {
		NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailLink]];
		thumbnailImage = [UIImage imageWithData:imageData];
	}
	return thumbnailImage;
}

- (void)updateInterface
{
	// Very common
	titleLabel.text = [[self story] title];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
	if ([[self story] author] == nil) {
		datum.text = [dateFormatter stringFromDate:[[self story] date]];
	} else {
		datum.text = [NSString stringWithFormat:@"von %@ - %@", [[self story] author], [dateFormatter stringFromDate:[[self story] date]]];
	}
	[dateFormatter release];
    
    [thumbnailButton loadImageFromURL:[NSURL URLWithString:[[self story] thumbnailLink]]];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	webview.delegate = self;
    [webview setBackgroundColor:[UIColor clearColor]];
    [super viewDidLoad];
    [self updateInterface];
    
	//Set the title of the navigation bar
	//-150x150
    
    UIImage *detailTop = [UIImage imageNamed:@"DetailTop.png"];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        detailTop = [UIImage imageNamed:@"DetailTop-Landscape.png"];
    }
    detailimage.image = detailTop;
    
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
    
    // :below:20091111 Apple wants this removed
    //	[(UIScrollView*)[webview.subviews objectAtIndex:0]	 setAllowsRubberBanding:NO];
    // :MacApple:20100105 I'm wondering why this doesn't caused a crash
    //	[webview release];
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

#pragma mark -
#pragma mark Interfacerotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [webview loadHTMLString:[self htmlString] baseURL:nil];
    UIImage *detailTop = [UIImage imageNamed:@"DetailTop.png"];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        detailTop = [UIImage imageNamed:@"DetailTop-Landscape.png"];
    }
    detailimage.image = detailTop;
}

- (void)dealloc {
    self.toolbar = nil;
    [story release];
	[lblText release];
	[myMenu release];
	[super dealloc];
}

@end
