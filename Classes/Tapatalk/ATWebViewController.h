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
    IBOutlet UIToolbar *topBar;
    IBOutlet UIToolbar *toolbar;
    NSURL *url;
}

@property (assign) IBOutlet UIToolbar *topBar;
@property (assign) IBOutlet UIWebView *webView;
@property (assign) IBOutlet UIToolbar *toolbar;
@property (retain) NSURL *url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url;
- (IBAction)share:(UIBarButtonItem *)sender;

@end
