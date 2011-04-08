//
//  GCImageViewer.h
//  ImageViewerTest
//
//  Created by Stefan Kofler on 13.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDHUDProgressBar.h"


@interface GCImageViewer : UIViewController <UIScrollViewDelegate> {
	NSMutableData* responseData;
	CGFloat expectedLength;
	
	NSURL* url;
	IBOutlet TDHUDProgressBar *bar;
	
	UIImageView* imageView;
	UIScrollView* myScrollView;
    UIColor *navBarColor;
    NSTimer *timer;
}

- (id)initWithURL:(NSURL*)URL;
- (void)hideBars;

@property (nonatomic, retain) NSURL* url;
@property (retain) UIColor *navBarColor;
@property (retain, setter=setTimer:) NSTimer *timer;
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIScrollView* myScrollView;


@end
