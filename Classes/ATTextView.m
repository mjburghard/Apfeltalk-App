//
//  ATTextView.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 03.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATTextView.h"


@implementation ATTextView

- (void)quote:(id)sender {
    SEL selector = @selector(textView:shouldQuoteText:);
    if ([(NSObject *)self.delegate respondsToSelector:selector]) {
        NSString *quoteString = [self.text substringWithRange:self.selectedRange];
        [self.delegate performSelector:selector withObject:self withObject:quoteString];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL result = NO;
    result = [super canPerformAction:action withSender:sender];
    if (result && [NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Quote", @"ATLocalizable", @"") action:@selector(quote:)];
        UIMenuController *menuCont = [UIMenuController sharedMenuController];
        menuCont.menuItems = [NSArray arrayWithObject:menuItem];
    } else if (action == @selector(quote:)) {
        result = YES;
    } else if (result && ![NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        [[UIMenuController sharedMenuController] setMenuItems:nil];
    }
    return result;
}

@end
