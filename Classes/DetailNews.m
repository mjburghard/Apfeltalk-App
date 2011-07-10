//
//  DetailNews.m
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

#import "DetailNews.h"
#import "NewsController.h"
#import "Apfeltalk_MagazinAppDelegate.h"
#import "ATMXMLUtilities.h"

#import "SHK.h"
#import "SHKTwitter.h"
#import "SHKFacebook.h"
#import "SHKFBStreamDialog.h"
#import "SHKMail.h"


// Private interface
@interface DetailNews ()

- (NSString *)htmlString;
- (NSUInteger)imageWidth;
- (void)loadArticlePages:(NSArray *)pagesLinks;
- (void)internalUpdateInterface;
- (void)stopNetworkActivityIndicator;

@end


@interface DetailNews (private)
- (void)createMailComposer;
@end

@implementation DetailNews

@synthesize showSave;
@synthesize activityIndicator;
@synthesize pageControl;
@synthesize currentPage;

// This is the new designated initializer for the class
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory
{
	self = [super initWithNibName:nibName bundle:nibBundle story:newStory];
	if (self != nil) {
		showSave = YES;
        self.hidesBottomBarWhenPushed = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideTabBar"];
	}
	return self;
}

- (void)dealloc
{
    self.activityIndicator = nil;
    self.pageControl = nil;
    [super dealloc];
}

- (NSString *) Mailsendecode {
    UINavigationController *navController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        navController = [self navigationController];
    } else {
        navController = [self.splitViewController.viewControllers objectAtIndex:0];
    }
	NSArray *controllers = [navController viewControllers];
    NewsController *newsController = (NewsController *)[controllers objectAtIndex:0];
	
    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];
	
    if (![self showSave]) {
		return nil;
	} else {
		return NSLocalizedStringFromTable(@"Save", @"ATLocalizable", @"");
	}
}

- (void) status_updateCallback: (NSData *) content {
	[loadingActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	[loadingActionSheet release];
}

-(IBAction)speichern:(id)sender
{
    [super speichern:sender];
	Apfeltalk_MagazinAppDelegate *appDelegate = (Apfeltalk_MagazinAppDelegate *)[[UIApplication sharedApplication] delegate];
	// :below:20090920 This is only to placate the analyzer
        
    myMenu = [[UIActionSheet alloc] init];
    myMenu.title = nil;
    myMenu.delegate = self;
    [myMenu addButtonWithTitle:NSLocalizedStringFromTable(@"Send Mail", @"ATLocalizable", @"")];
    if ([self Mailsendecode]) // :below:20100101 This is something of a hack
        [myMenu addButtonWithTitle:[self Mailsendecode]];
    [myMenu addButtonWithTitle:@"Twitter"];
    [myMenu addButtonWithTitle:@"Facebook"];
    [myMenu addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"ATLocalizable", @"")];
    if ([self Mailsendecode])
        myMenu.cancelButtonIndex = 4;
    else
        myMenu.cancelButtonIndex = 3;
    	
    [myMenu showFromTabBar:[[appDelegate tabBarController] tabBar]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIdx
{	
	// int numberOfButtons = [actionSheet numberOfButtons]; not used
	int saveEnabled = [self Mailsendecode]?1:0;
    
	// assume that when we have 3 buttons, the one with idx 1 is the save button
    // :below:20091220 This assumption is not correct, We should find a smarter way
    UINavigationController *navController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        navController = [self navigationController];
    } else {
        navController = [self.splitViewController.viewControllers objectAtIndex:0];
    }
    
	if (saveEnabled && buttonIdx == 1) {
        // Save
		
		 NSArray *controllers = [navController viewControllers];
		 
		 NewsController *newsController = (NewsController*) [controllers objectAtIndex:0];
		 [newsController addSavedStory:[self story]];
	}
    
    NSArray *controllers = [navController viewControllers];
    NewsController *newsController = (NewsController*) [controllers objectAtIndex:0];
    
    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];

	if (buttonIdx == 0) {
		// Mail
        SHKItem *item = [SHKItem text:story.summary];
        item.title = story.title;
        
        [SHKMail shareItem:item];
	}
	
	if (buttonIdx == 1 + saveEnabled) {
		// Twitter
        NSURL *url = [NSURL URLWithString:story.link];
        SHKItem *item = [SHKItem URL:url title:story.title];
        
        [SHKTwitter shareItem:item];
	}
	
	if (buttonIdx == 2 + saveEnabled) {
        // FaceBook
        NSURL *url = [NSURL URLWithString:story.link];
        SHKItem *item = [SHKItem URL:url title:story.title];
        
        [SHKFacebook shareItem:item];
	}
	
	if (actionSheet == myMenu) {
		[myMenu release];		
		myMenu = nil;
	}
}

- (void)updateInterface
{
    NewsController *newsController;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        newsController = [[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
    }
    else
    {
        NSArray *controllers = [[self navigationController] viewControllers];
        newsController = (NewsController *)[controllers objectAtIndex:[controllers count] - 2];
    }

    [self setShowSave:![newsController isSavedStory:[self story]]];

    Story *theStory = self.story;

    if (theStory && !theStory.author)     // Check if the author and content is already loaded
    {
        if (!self.activityIndicator)
            self.activityIndicator = [[[ATActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 70.0, 70.0)] autorelease];

        self.activityIndicator.center = CGPointMake(webview.frame.size.width / 2.0, webview.frame.size.height / 2.0);

        [webview addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
    }

    self.currentPage = 0;
    [self performSelector:@selector(internalUpdateInterface) withObject:nil afterDelay:0.0];
}

- (void)viewDidLoad
{
    webview.delegate = self;
    UIBarButtonItem *rightItem = [[[UIBarButtonItem alloc] initWithTitle:[self rightBarButtonTitle]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:[[[self navigationController] viewControllers] lastObject]
                                                                  action:@selector(speichern:)] autorelease];

    NSArray            *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Up.png"], [UIImage imageNamed:@"Down.png"], nil];
	UISegmentedControl *segControl = [[[UISegmentedControl alloc] initWithItems:imgArray] autorelease];

	[segControl addTarget:[[[self navigationController] viewControllers] objectAtIndex:0] action:@selector(changeStory:)
         forControlEvents:UIControlEventValueChanged];
    [segControl setFrame:CGRectMake(0.0, 0.0, 110.0, 30.0)];
	[segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segControl setMomentary:YES];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.navigationItem.titleView = segControl;
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    else
    {
        NSMutableArray *items = [toolbar.items mutableCopy];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        [items addObject:flexibleSpace];
        [items addObject:rightItem];
        [toolbar setItems:items animated:NO];
        [flexibleSpace release];
        [items release];
    }

    [[[[self navigationController] viewControllers] objectAtIndex:0] changeStory:segControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NewsController *newsController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        newsController = [[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
    } else {
        NSArray *controllers = [[self navigationController] viewControllers];
        newsController = (NewsController *)[controllers objectAtIndex:[controllers count] - 2];
    }

    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];
}


- (void)viewDidAppear:(BOOL)animated
{
    [self updateInterface];
    [super viewDidAppear:animated];
}

- (void)changePage:(UIPageControl *)sender
{
    NSInteger page = sender.currentPage;

    if (page != self.currentPage)
    {
        if (page >= [self.story.content count])
        {
            sender.currentPage = self.currentPage;
        }
        else
        {
            self.currentPage = page;
            [webview loadHTMLString:[self htmlString] baseURL:nil];
        }
    }
}

#pragma mark - Internal used methods

- (NSString *)htmlString
{
    Story           *theStory = self.story;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];

    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm", [dateFormatter dateFormat]]];

    if ([theStory.content count] == 0)
        return @"";

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Magazine" ofType:@"html"];
    NSString *htmlString = [NSString stringWithFormat:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL],
                            [self imageWidth], theStory.title, theStory.author, [dateFormatter stringFromDate:theStory.date],
                            [theStory.content objectAtIndex:self.currentPage]];
    return htmlString;
}


- (NSUInteger)imageWidth
{
    NSUInteger width = 290;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        width = 675;

    return width;
}


- (void)loadArticlePages:(NSArray *)pagesLinks
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    for (NSUInteger index = 1; index < [pagesLinks count]; index++)
    {
        ATMXMLUtilities *xmlUtilities = [[ATMXMLUtilities alloc] initWithURLString:[pagesLinks objectAtIndex:index]];
        [self.story addStoryPage:[xmlUtilities articleContent]];
        [xmlUtilities release];
    }

    [self performSelectorOnMainThread:@selector(stopNetworkActivityIndicator) withObject:nil waitUntilDone:NO];

    [pool release];
}


- (void)internalUpdateInterface
{
    NSArray *pagesLinks = nil;
    Story   *theStory= self.story;

    if (theStory.link && !theStory.author)   // Fill the empty attributes of the current item
    {
        ATMXMLUtilities *xmlUtilities = [ATMXMLUtilities xmlUtilitiesWithURLString:theStory.link];

        theStory.author = [xmlUtilities authorName];
        [theStory addStoryPage:[xmlUtilities articleContent]];
        pagesLinks = [xmlUtilities articlePagesLinks];
        if (pagesLinks)
            [self performSelectorInBackground:@selector(loadArticlePages:) withObject:pagesLinks];
    }

    [webview loadHTMLString:[self htmlString] baseURL:nil];

    NSInteger pageCount = [theStory.content count];

    if (pageCount == 0)
        pageCount = 1;

    if (pagesLinks)
        pageCount = [pagesLinks count];
    else
        [self stopNetworkActivityIndicator];

    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = 0;
    self.currentPage = 0;
}


- (void)stopNetworkActivityIndicator
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // No longer needed for the news.
}

@end
