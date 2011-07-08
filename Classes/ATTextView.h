//
//  ATTextView.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 03.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATTextView;

@protocol ATTextViewDelegate <UITextViewDelegate> 

- (void)textView:(ATTextView *)textView shouldQuoteText:(NSString *)string;

@end


@interface ATTextView : UITextView {
    
}

- (void)quote:(id)sender;

@end
