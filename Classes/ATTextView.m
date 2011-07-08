//
//  ATTextView.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 03.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATTextView.h"


@implementation ATTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Quote", @"ATLocalizable", @"") action:@selector(quote:)];
        UIMenuController *menuCont = [UIMenuController sharedMenuController];
        menuCont.menuItems = [NSArray arrayWithObject:menuItem];  
    }
    return self;
}

- (void)quote:(id)sender {
    SEL selector = @selector(textView:shouldQuoteText:);
    if ([(NSObject *)self.delegate respondsToSelector:selector]) {
        NSString *quoteString;
        if (self.selectedRange.length == 0) {
            quoteString = self.text;
            while ([quoteString rangeOfString:@"Zitat:\n---------\n"].location != NSNotFound) {
                NSRange range = [quoteString rangeOfString:@"Zitat:\n---------\n"];
                NSScanner *scanner = [NSScanner scannerWithString:self.text];
                NSUInteger pos = range.location+range.length;
                NSLog(@"Position: %lu", (unsigned long)[scanner scanLocation]);
                [scanner setScanLocation:pos];
                NSLog(@"Position: %lu", (unsigned long)[scanner scanLocation]);
                [scanner scanUpToString:@"\n---------\n" intoString:NULL];
                NSLog(@"Position: %lu", (unsigned long)[scanner scanLocation]);
                NSLog(@"Text length: %lu", (unsigned long)self.text.length);
                NSRange quoteRange = NSMakeRange(pos,([scanner scanLocation] - pos));
                NSString *s = [NSString stringWithFormat:@"Zitat:\n---------\n%@\n---------\n", [quoteString substringWithRange:quoteRange]];
                quoteString = [quoteString stringByReplacingOccurrencesOfString:s withString:@""];
                quoteString = [quoteString stringByReplacingCharactersInRange:quoteRange withString:@""];
            }
        } else {
            quoteString = [self.text substringWithRange:self.selectedRange];
        } 
        [self.delegate performSelector:selector withObject:self withObject:quoteString];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL result = NO;
    result = [super canPerformAction:action withSender:sender];
    if (action == @selector(quote:)) {
        result = YES;
    }
    /*if (result && [NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Quote", @"ATLocalizable", @"") action:@selector(quote:)];
        UIMenuController *menuCont = [UIMenuController sharedMenuController];
        menuCont.menuItems = [NSArray arrayWithObject:menuItem];
    } else if (action == @selector(quote:)) {
        result = YES;
    } else if (result && ![NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        [[UIMenuController sharedMenuController] setMenuItems:nil];
    }*/
    return result;
}

@end
