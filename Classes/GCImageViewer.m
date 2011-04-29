//
//  GCImageviewer.m
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


#import "GCImageViewer.h"


@implementation GCImageViewer
@synthesize url, navBarColor, timer, myScrollView, imageView;

- (id)initWithURL:(NSURL*)URL {
	self = [super initWithNibName:@"GCImageViewer" bundle:nil];
	if (self != nil) {
		url = URL;
        self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

- (void)setTimer:(NSTimer *)newTimer {
    if (timer != newTimer) {
        [timer invalidate];
        [timer release];
        timer = [newTimer retain];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    self.navBarColor = navigationBar.tintColor;
    navigationBar.tintColor = nil;
    navigationBar.barStyle = UIBarStyleBlack;
    navigationBar.translucent = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleBlackOpaque animated:YES];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                  target:self
                                                selector:@selector(hideBars)
                                                userInfo:nil
                                                 repeats:NO];
    [self setWantsFullScreenLayout:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self setTimer:nil];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.tintColor = self.navBarColor;
    navigationBar.translucent = NO;
	[[self navigationController] setNavigationBarHidden:NO animated:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleDefault animated:YES];
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	//url = [NSURL URLWithString:@"http://www.alliphonewallpapers.com/images/wallpapers/gk6aim4p7.jpg"];
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[conn start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	long long length = [response expectedContentLength];
	NSLog(@"lenghth: %lld", length);
	expectedLength = length;
	if (length == NSURLResponseUnknownLength)
		length = 1024;
	[responseData release];
	responseData = [[NSMutableData alloc] initWithCapacity:length];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
	bar.progress = [responseData length]/expectedLength;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
													message:@"Vorgang nicht möglich, du bist nicht mit dem Internet verbunden." 
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"OK", @"")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[bar removeFromSuperview];
	[bar release];
	
	self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:responseData]];
	[imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[imageView setContentMode:UIViewContentModeScaleAspectFit];
	[imageView setTag:2];
	
	self.myScrollView = [[UIScrollView alloc] initWithFrame:imageView.frame];
	myScrollView.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
	myScrollView.maximumZoomScale = 4.0;
	myScrollView.minimumZoomScale = 1.0;
	myScrollView.clipsToBounds = YES;
	myScrollView.tag = 999;
	myScrollView.delegate = self;
	[myScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[myScrollView addSubview:imageView];
	
	[myScrollView addSubview:imageView];
	[self.view addSubview:myScrollView];
	
	UITapGestureRecognizer* tapRegonizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBars)];
	[myScrollView addGestureRecognizer:tapRegonizer];
	[tapRegonizer release];	
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollview {
	return imageView;
}

- (void)hideBars {
    [self setTimer:nil];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	if ([[self navigationController] isNavigationBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                      target:self
                                                    selector:@selector(hideBars)
                                                    userInfo:nil
                                                     repeats:NO];
	} else {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	}
    
    
	[UIView commitAnimations];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        myScrollView.contentSize = CGSizeMake(320, 480);
    } else {
        
        myScrollView.contentSize = CGSizeMake(480, 320);
    }
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [self setTimer:nil];
    [navBarColor release];
	[myScrollView release];
	[imageView release];
    [super dealloc];
}


@end
