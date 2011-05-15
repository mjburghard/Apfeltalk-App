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
#import "SFHFKeychainUtils.h"
#import "ForumViewController.h"
#import "User.h"


@implementation Apfeltalk_MagazinAppDelegate

@synthesize window;
@synthesize tabBarController, userXMLParser;


- (void)setApplicationDefaults {
	// !!!:below:20091018 This is not the Apple recommended way of doing this!
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"showIconBadge"] == nil)
	{
		// no default values have been set, create them here based on what's in our Settings bundle info
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showIconBadge"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shakeToReload"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vibrateOnReload"];
	} 
}

- (void)login {
    if ([userXMLParser isWorking]) {
        return;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ATUsername"] && ![(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ATUsername"] isEqualToString:@""]) {
        NSError *error = nil;
        NSString *username = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ATUsername"];
        NSString *password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:@"Apfeltalk" error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        NSURL *url = [NSURL URLWithString:@"http://apfeltalk.de/forum/mobiquo/mobiquo.php/"];
        NSString *xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><methodCall><methodName>login</methodName><params><param><value><base64>%@</base64></value></param><param><value><base64>%@</base64></value></param></params></methodCall>", encodeString(username), encodeString(password)];
        NSData *data = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-length"];
        self.userXMLParser = [[UserXMLParser alloc] initWithRequest:request delegate:self];
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
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self login];
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

- (void)userIsLoggedIn:(BOOL)isLoggedIn {
    
}

- (void)userXMLParserDidFinish {
    self.userXMLParser = nil;
}


- (void)dealloc {
    self.userXMLParser = nil;
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

