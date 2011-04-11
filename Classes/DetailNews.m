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
	NSArray *controllers = [[self navigationController] viewControllers];
    NewsController *newsController = (NewsController *)[controllers objectAtIndex:[controllers count] - 2];
	
    if ([self showSave] && [newsController isSavedStory:[self story]])
        [self setShowSave:NO];
	
    if (![self showSave]) {
		return nil;
	} else {
		return @"Speichern";
	}
}

/*- (void) postTweet {
	TwitterRequest * t = [[TwitterRequest alloc] init];
	t.username = usernameTextField.text;
	t.password = passwordTextField.text;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *twitter = [documentsDirectory stringByAppendingPathComponent:@"Twitter.plist"];
	NSArray * savedata = [NSArray arrayWithObjects:usernameTextField.text, passwordTextField.text,nil];
	[savedata writeToFile:twitter atomically:YES];
	
	NSString *link = [[self story] link];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest new];
	
	[postRequest setHTTPMethod:@"GET"];
	
	[postRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=apfeltalk&apiKey=R_c9aabb37645e874c9e99aebe9ba12cb8", link]]];
	
	NSData *responseData;
	NSHTTPURLResponse *response;
	
	//==== Synchronous call to upload
	responseData = [ NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:nil];
	[postRequest release];
    postRequest = nil;
    
	NSString *shortLink = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding]
                           autorelease]; // :below:20091218 Do we know if this is ASCII?
	
	NSRange pos1 = [shortLink rangeOfString: @"shortUrl"];
	NSRange pos2 = [shortLink rangeOfString: @"userHash"];
	NSRange range = NSMakeRange(pos1.location + 12,pos2.location - 17 - (pos1.location + 12));
	shortLink = [shortLink substringWithRange:range];
		
	loadingActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString (@"Sende Tweet…", @"") delegate:nil 
											cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	[loadingActionSheet showInView:self.view];
	[t statuses_update:[NSString stringWithFormat:NSLocalizedString (@"Newstipp: %@ %@", @""), [[self story] title], shortLink] delegate:self requestSelector:@selector(status_updateCallback:)];
}*/
- (void) status_updateCallback: (NSData *) content {
	[loadingActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	[loadingActionSheet release];
}

-(IBAction)speichern:(id)sender
{
	Apfeltalk_MagazinAppDelegate *appDelegate = (Apfeltalk_MagazinAppDelegate *)[[UIApplication sharedApplication] delegate];
	// :below:20090920 This is only to placate the analyzer
        
    myMenu = [[UIActionSheet alloc] init];
    myMenu.title = nil;
    myMenu.delegate = self;
    [myMenu addButtonWithTitle:NSLocalizedString (@"Per Mail versenden", @"")];
    if ([self Mailsendecode]) // :below:20100101 This is something of a hack
        [myMenu addButtonWithTitle:[self Mailsendecode]];
    [myMenu addButtonWithTitle:NSLocalizedString (@"Twitter", @"")];
    [myMenu addButtonWithTitle:NSLocalizedString (@"Facebook", @"")];
    [myMenu addButtonWithTitle:NSLocalizedString (@"Abbrechen", @"")];
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
	if (saveEnabled && buttonIdx == 1) {
        // Save
		UINavigationController *navController = [self navigationController];
		 NSArray *controllers = [navController viewControllers];
		 
		 NewsController *newsController = (NewsController*) [controllers objectAtIndex:[controllers count] -2];
		 [newsController addSavedStory:[self story]];
	}
    
	UINavigationController *navController = [self navigationController];
    NSArray *controllers = [navController viewControllers];
    NewsController *newsController = (NewsController*) [controllers objectAtIndex:[controllers count] -2];
    
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

    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString (@"Optionen", @"") style:UIBarButtonItemStyleBordered target:[[[self navigationController] viewControllers] lastObject] action:@selector(speichern:)];

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
