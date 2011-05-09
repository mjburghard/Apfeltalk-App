//
//  ATWebViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 28.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATWebViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *reloadButton;
    NSURL *url;
}

@property (assign) IBOutlet UIWebView *webView;
@property (assign) IBOutlet UIToolbar *toolbar;
@property (retain) IBOutlet UIBarButtonItem *reloadButton;
@property (retain) NSURL *url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url;
- (IBAction)share:(UIBarButtonItem *)sender;

@end
