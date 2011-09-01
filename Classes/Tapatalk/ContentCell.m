//
//  ContentCell.m
//  Tapatalk
//
//  Created by Manuel Burghard on 22.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface UITextView (Additions)
@end

@class WebView, WebFrame, ContentCell;
@protocol WebPolicyDecisionListener

- (BOOL)textView:(UITextView *)textView shouldLoadRequest:(NSURLRequest *)request;

@end

@implementation UITextView (Additions)

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    [(ContentCell *)self.delegate textView:self shouldLoadRequest:request];
}
@end

#import "ContentCell.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation ContentCell
@synthesize textView, delegate;

- (CGFloat)groupedCellMarginWithTableWidth:(CGFloat)tableViewWidth
{
    CGFloat marginWidth;
    if(tableViewWidth > 20)
    {
        if(tableViewWidth < 400)
        {
            marginWidth = 10;
        }
        else
        {
            marginWidth = MAX(31, MIN(45, tableViewWidth*0.06));
        }
    }
    else
    {
        marginWidth = tableViewWidth - 10;
    }
    return marginWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableViewWidth:(CGFloat)tableViewWidth {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        /*CGFloat margin = [self groupedCellMarginWithTableWidth:tableViewWidth];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) { 
            self.textView = [[[ATTextView alloc] initWithFrame:CGRectMake(0.0,0.0, tableViewWidth-2*10.0, self.frame.size.height-7.0)] autorelease];
        } else {
            self.textView = [[[ATTextView alloc] initWithFrame:CGRectMake(0.0,0.0, tableViewWidth-2*margin, self.frame.size.height-7.0)] autorelease];
        }*/
        self.textView = [[[ATTextView alloc] init] autorelease];
        self.textView.scrollEnabled = NO;
        self.textView.layer.masksToBounds = YES;
        self.textView.layer.cornerRadius = 10.0;
        self.textView.editable = NO;
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.textView.bounces = NO;
        self.textView.dataDetectorTypes = UIDataDetectorTypeLink;
        self.textView.delegate = self;
        self.textView.textColor = UIColorFromRGB(0x000000);
        self.textView.backgroundColor = self.contentView.backgroundColor;
        
        UIFont *font = self.textView.font;
        self.textView.font = [font fontWithSize:[[NSUserDefaults standardUserDefaults] floatForKey:@"fontSize"]];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
        [self.contentView addSubview:self.textView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.textView.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.frame);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) { 
        self.textView.frame = CGRectMake(0.0,0.0, width - 2.0 * 10.0, self.frame.size.height - 7.0);
    } else {
        CGFloat margin = [self groupedCellMarginWithTableWidth:width];
        self.textView.frame = CGRectMake(0.0,0.0, width - 2.0 * margin, self.frame.size.height - 7.0);
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.textView = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark ATTextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
    if (self.delegate) {
        [self.delegate contentCellDidBeginEditing:self];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    [aTextView resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([(NSObject *)self.delegate respondsToSelector:@selector(contentCellDidEndEditing:)]) {
        [self.delegate contentCellDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldLoadRequest:(NSURLRequest *)request {
    return [self.delegate contentCell:self shouldLoadRequest:request];
}

- (void)textView:(ATTextView *)textView shouldQuoteText:(NSString *)quoteText {
    if ([(NSObject *)self.delegate respondsToSelector:@selector(contentCell:shouldQuoteText:ofObjectAtIndexPath:)]) {
        [self.delegate contentCell:self shouldQuoteText:quoteText ofObjectAtIndexPath:[(UITableView *)self.superview indexPathForCell:self]];
    }
}

@end
