//
//  ATActivityIndicator.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 06.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATActivityIndicator : UIView {
    NSString *message;
    UIActivityIndicatorView *spinner;
    UILabel *messageLabel;
}

@property (retain) NSString *message;
@property (retain) UIActivityIndicatorView *spinner;
@property (retain) UILabel *messageLabel;

+ (ATActivityIndicator *)activityIndicator;
- (void)show;
- (void)showSpinner;

@end
