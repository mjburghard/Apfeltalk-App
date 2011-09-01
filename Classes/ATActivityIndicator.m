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
@synthesize spinner, messageLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.messageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 160.0 - 21.0 -10.0, 140.0, 21.0)] autorelease];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textColor = [UIColor whiteColor];
        self.messageLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.messageLabel];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
        self.opaque = NO;
        self.alpha = 1.0;
        
        self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        
        self.spinner.frame = CGRectMake(self.bounds.size.width/2 - 30.0, self.bounds.size.height/2 - 30.0, 60.0, 60.0);
        [self addSubview:spinner];
    }
    return self;
}

+ (ATActivityIndicator *)activityIndicator {
    ATActivityIndicator *activityIndicator = [[ATActivityIndicator alloc] initWithFrame:CGRectMake(0.0, 
                                                                                                   0.0, 
                                                                                                   160.0, 
                                                                                                   160.0)];
    return [activityIndicator autorelease];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)startAnimating {
    [self.spinner startAnimating];
}

- (void)stopAnimating {
    [self.spinner stopAnimating];
}

- (void)dealloc {
    self.messageLabel = nil;
    self.spinner = nil;
    [super dealloc];
}

@end
