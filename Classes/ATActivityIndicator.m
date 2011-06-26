//
//  ATActivityIndicator.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 06.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>


@implementation ATActivityIndicator
@synthesize message, spinner, messageLabel, customSuperview;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.message = [NSString string];
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 160.0 - 21.0 -10.0, 140.0, 21.0)];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textColor = [UIColor lightTextColor];
        self.messageLabel.textAlignment = UITextAlignmentCenter;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        self.opaque = NO;
        self.alpha = 0.0;
    }
    return self;
}

+ (ATActivityIndicator *)activityIndicatorForView:(UIView *)view {
    CGRect viewRect = view.bounds;
    ATActivityIndicator *activityIndicator = [[ATActivityIndicator alloc] initWithFrame:CGRectMake(viewRect.size.width/2 - 80.0, 
                                                                                                   viewRect.size.height/2 - 80.0, 
                                                                                                   160.0, 
                                                                                                   160.0)];
    activityIndicator.customSuperview = view;
    return [activityIndicator autorelease];
}

- (void)dismiss {
    [self removeFromSuperview];
    [(UITableView *)[self customSuperview] setScrollEnabled:YES];
}

- (void)show {
    self.messageLabel.text = self.message;
    [self addSubview:messageLabel];
    [self.customSuperview addSubview:self];
    [(UITableView *)[self customSuperview] setScrollEnabled:NO];
    self.alpha = 1.0;
    
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
}

- (void)showSpinner {
    if (spinner == nil) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        self.spinner.frame = CGRectMake(self.bounds.size.width/2 - 20.0, self.bounds.size.height/2 - 20.0, 40.0, 40.0);
    }
    [self addSubview:spinner];
    [spinner startAnimating];
    [spinner release];
}

- (void)dealloc
{
    self.customSuperview = nil;
    self.message = nil;
    self.spinner = nil;
    [super dealloc];
}

@end
