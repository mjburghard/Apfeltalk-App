//
//  Apfeltalk_MagazinAppDelegate.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Michael Fenske, Laurids Düllmann, Jesper Frommherz (Graphics),
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

#import "Apfeltalk_MagazinAppDelegate.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "DetailNews.h"
#import "DetailGallery.h"
#import "DetailLiveticker.h"
#import "User.h"
#import "NewsController.h"


@implementation Apfeltalk_MagazinAppDelegate

@synthesize window;
@synthesize tabBarController;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)setApplicationDefaults {
	// !!!:below:20091018 This is not the Apple recommended way of doing this!
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"showIconBadge"] == nil)
	{
		// no default values have been set, create them here based on what's in our Settings bundle info
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showIconBadge"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shakeToReload"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vibrateOnReload"];
        [[NSUserDefaults standardUserDefaults] setFloat:12 forKey:@"fontSize"];
	} 
}

- (void)login {
    [[User sharedUser] login];
}

- (void)deleteCookies {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://.apfeltalk.de"]];
    for (NSHTTPCookie *c in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:c];
    }
}

/*- (void)applicationDidFinishLaunching:(UIApplication *)application {
 [self setApplicationDefaults];
 // Add the tab bar controller's current view as a subview of the window
 [window addSubview:tabBarController.view];
 [self login];
 }*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setApplicationDefaults];
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
    
    // Add the tab bar controller's current view as a subview of the window
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSMutableArray *viewControllers = (NSMutableArray *)tabBarController.viewControllers;
        
        UISplitViewController *splitviewController = [[UISplitViewController alloc] init];
        splitviewController.delegate = [newsController.viewControllers objectAtIndex:0];
        splitviewController.tabBarItem = newsController.tabBarItem;
        DetailNews *detailNews = [[DetailNews alloc] initWithNibName:[(NewsController *)splitviewController.delegate detailNibName] bundle:nil story:nil];
        
        splitviewController.viewControllers = [NSArray arrayWithObjects:newsController, detailNews,nil];
        [viewControllers replaceObjectAtIndex:0 withObject:splitviewController];
        [splitviewController release];
        [detailNews release];
        
        splitviewController = [[UISplitViewController alloc] init];
        splitviewController.delegate = [galleryController.viewControllers objectAtIndex:0];
        splitviewController.tabBarItem = galleryController.tabBarItem;
        DetailGallery *detailGallery = [[DetailGallery alloc] initWithNibName:@"DetailView" bundle:nil story:nil];
        
        splitviewController.viewControllers = [NSArray arrayWithObjects:galleryController, detailGallery,nil];
        [viewControllers replaceObjectAtIndex:1 withObject:splitviewController];
        [splitviewController release];
        [detailGallery release];
        
        splitviewController = [[UISplitViewController alloc] init];
        if (!livetickerController) {
            livetickerController = [viewControllers objectAtIndex:3];
        }
        splitviewController.delegate = [livetickerController.viewControllers objectAtIndex:0];
        splitviewController.tabBarItem = livetickerController.tabBarItem;
        DetailLiveticker *detailLiveticker = [[DetailLiveticker alloc] initWithNibName:@"DetailView" bundle:nil story:nil];
        
        splitviewController.viewControllers = [NSArray arrayWithObjects:livetickerController, detailLiveticker,nil];
        [viewControllers replaceObjectAtIndex:3 withObject:splitviewController];
        [splitviewController release];
        [detailLiveticker release];
        
        tabBarController.viewControllers = viewControllers;
    }
    
    [window addSubview:tabBarController.view];
    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self deleteCookies];
    [self login];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self deleteCookies];
    [[User sharedUser] setLoggedIn:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self deleteCookies];
    [[User sharedUser] setLoggedIn:NO];
}
/*
 // Optional UITabBarControllerDelegate method
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
 }
 */

/*
 // Optional UITabBarControllerDelegate method
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end