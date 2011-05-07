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
@synthesize message, spinner, messageLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.message = [NSString string];
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 160.0 - 21.0 -10.0, 140.0, 21.0)];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textColor = [UIColor lightTextColor];
        self.messageLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.messageLabel];
    }
    return self;
}

+ (ATActivityIndicator *)activityIndicator {
    
    CGRect windowRect = [[[UIApplication sharedApplication] keyWindow] frame];
    
    ATActivityIndicator *activityIndicator = [[ATActivityIndicator alloc] initWithFrame:CGRectMake(windowRect.size.width/2 - 80.0, 
                                                                                                   windowRect.size.height/2 - 80.0, 
                                                                                                   160.0, 
                                                                                                   160.0)];
    activityIndicator.layer.masksToBounds = YES;
    activityIndicator.layer.cornerRadius = 10.0;
    activityIndicator.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    activityIndicator.opaque = NO;
    activityIndicator.alpha = 0.0;
    
    
    return activityIndicator;
}

- (void)show {
    self.messageLabel.text = self.message;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    
    self.alpha = 1.0;
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)showSpinner {
    if (spinner == nil) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        self.spinner.frame = CGRectMake(self.bounds.size.width/2 - 20.0, self.bounds.size.height/2 - 20.0, 40.0, 40.0);
    }
    [self addSubview:spinner];
    [spinner startAnimating];
}

- (void)dealloc
{
    self.message = nil;
    self.spinner = nil;
    [super dealloc];
}

@end
