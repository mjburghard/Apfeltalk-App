//
//  DetailLiveticker.m
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

#import "DetailLiveticker.h"
#import "LivetickerController.h"
#import "LivetickerNavigationController.h"

#define RELOAD_TIME 30

@implementation DetailLiveticker

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray            *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Up.png"], [UIImage imageNamed:@"Down.png"], nil];
	UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:imgArray];
    LivetickerController *livetickerController = [[[self navigationController] viewControllers] objectAtIndex:0];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        livetickerController = [[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
    }
	[segControl addTarget:livetickerController action:@selector(changeStory:)
         forControlEvents:UIControlEventValueChanged];
	[segControl setFrame:CGRectMake(0, 0, 90, 30)];
	[segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segControl setMomentary:YES];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:segControl];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        segControl.tintColor = toolbar.tintColor;
        [segControl setEnabled:NO forSegmentAtIndex:0];
        [segControl setEnabled:NO forSegmentAtIndex:1];
        NSMutableArray *items = (NSMutableArray *)[self.toolbar.items mutableCopy];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        [items removeLastObject];
        [items addObject:flexibleSpace];
        [items addObject:rightItem];
        [self.toolbar setItems:items];
        [flexibleSpace release];
        [items release];
    } else {
        [[self navigationItem] setRightBarButtonItem:rightItem];
        [livetickerController changeStory:segControl];
    }

    [segControl release];
    [rightItem release];

    [webview setDelegate:self];
    [self updateInterface];
// :below:20091111 Apple wants this removed
//	[(UIScrollView *)[webview.subviews objectAtIndex:0] setAllowsRubberBanding:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        LivetickerController *livetickerController = [[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
        [(LivetickerNavigationController *)[self.splitViewController.viewControllers objectAtIndex:0] setReloadTimer:[NSTimer scheduledTimerWithTimeInterval:RELOAD_TIME target:livetickerController selector:@selector(reloadTickerEntries:) userInfo:nil repeats:YES]];
        [livetickerController reloadTickerEntries:nil];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [(LivetickerNavigationController *)[self.splitViewController.viewControllers objectAtIndex:0] setReloadTimer:nil];
    }
}

- (NSString *)htmlString
{
    NSRange          aRange;
    NSMutableString *contentString = [NSMutableString stringWithString:[[self story] summary]];

    // Remove the last paragraph tags
    aRange = [contentString rangeOfString:@"</p>" options:NSBackwardsSearch];
    if (([contentString length] - NSMaxRange(aRange)) <= 1)
    {
        [contentString deleteCharactersInRange:aRange];
        aRange = [contentString rangeOfString:@"<p>" options:NSBackwardsSearch];
        if (aRange.location != NSNotFound)
            [contentString deleteCharactersInRange:aRange];
    }
    
    Story           *theStory = self.story;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm", [dateFormatter dateFormat]]];
    float fontSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"fontSize"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DetailView" ofType:@"html"];
    NSString *htmlString = [NSString stringWithFormat:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL], 
                            fontSize, [self imageWidth], (fontSize + 3.0), theStory.title, (fontSize - 1.0), theStory.author, [dateFormatter stringFromDate:theStory.date], fontSize,
                            contentString];
    return htmlString;
}

- (UISegmentedControl *)storyControl
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return (UISegmentedControl *)[[self.toolbar.items lastObject] customView];
    }
    return (UISegmentedControl *)[[[self navigationItem] rightBarButtonItem] customView];
}

@end
