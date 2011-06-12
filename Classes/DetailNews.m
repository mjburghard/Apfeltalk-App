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

#import "SHK.h"
#import "SHKTwitter.h"
#import "SHKFacebook.h"
#import "SHKFBStreamDialog.h"
#import "SHKMail.h"

@interface DetailNews (private)
- (void)createMailComposer;
@end

@implementation DetailNews
@synthesize showSave;

// This is the new designated initializer for the class
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle story:(Story *)newStory
{
	self = [super initWithNibName:nibName bundle:nibBundle story:newStory];
	if (self != nil) {
		showSave = YES;
	}
	return self;
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


- (void)viewDidLoad
{
    NSArray            *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Up.png"], [UIImage imageNamed:@"Down.png"], nil];
	UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:imgArray];

    [super viewDidLoad];

	[segControl addTarget:[[[self navigationController] viewControllers] objectAtIndex:0] action:@selector(changeStory:)
         forControlEvents:UIControlEventValueChanged];
    [segControl setFrame:CGRectMake(0.0, 0.0, 110.0, 30.0)];
	[segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segControl setMomentary:YES];

    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Options", @"ATLocalizable", @"") style:UIBarButtonItemStyleBordered target:[[[self navigationController] viewControllers] lastObject] action:@selector(speichern:)];

    [[self navigationItem] setTitleView:segControl];
    [[self navigationItem] setRightBarButtonItem:rightItem];
    [[[[self navigationController] viewControllers] objectAtIndex:0] changeStory:segControl];

    [segControl release];
    [rightItem release];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *controllers = [[self navigationController] viewControllers];
    NewsController *newsController = (NewsController *)[controllers objectAtIndex:[controllers count] - 2];

    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];
}

@end
