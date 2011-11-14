//
//  GalleryTopController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 12.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface GalleryTopController : UITableViewController <NSURLConnectionDelegate, MFMailComposeViewControllerDelegate, UISplitViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *galleries;
@property (nonatomic, assign) NSInteger indexOfCurrentGallery;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIBarButtonItem *rootPopoverButtonItem;

- (IBAction)openSafari:(id)sender;
- (IBAction)about:(id)sender;

@end