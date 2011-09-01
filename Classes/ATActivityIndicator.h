//
//  ATActivityIndicator.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 06.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATActivityIndicator : UIView {
    UIActivityIndicatorView *spinner;
    UILabel *messageLabel;
}

@property (retain) UIActivityIndicatorView *spinner;
@property (retain) UILabel *messageLabel;

+ (ATActivityIndicator *)activityIndicator;
- (void)dismiss;

- (void)startAnimating;
- (void)stopAnimating;

@end
