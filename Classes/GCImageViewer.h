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
}

- (id)initWithURL:(NSURL*)URL;

@property (nonatomic, retain) NSURL* url;

@end
