    //
//  GCImageViewer.m
//  ImageViewerTest
//
//  Created by Stefan Kofler on 13.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GCImageViewer.h"


@implementation GCImageViewer
@synthesize url;

- (id)initWithURL:(NSURL*)URL {
	self = [super initWithNibName:@"GCImageViewer" bundle:nil];
	if (self != nil) {
		url = URL;
	}
	return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
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
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fehler" 
													message:@"Vorgang nicht möglich, du bist nicht mit dem Internet verbunden." 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[bar removeFromSuperview];
	[bar release];
	
	imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:responseData]];
	[imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[imageView setContentMode:UIViewContentModeScaleAspectFit];
	[imageView setTag:2];
	
	myScrollView = [[UIScrollView alloc] initWithFrame:imageView.frame];
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
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	if ([[self navigationController] isNavigationBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
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
    [super dealloc];
	[myScrollView release];
	[imageView release];
}


@end
