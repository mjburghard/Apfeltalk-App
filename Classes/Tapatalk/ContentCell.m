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
        CGFloat margin = [self groupedCellMarginWithTableWidth:tableViewWidth];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) { 
            self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0,7.0, 320.0-2*margin, self.frame.size.height-7.0)];
        } else {
            self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0,7.0, 768-2*margin, self.frame.size.height-7.0)];
        }
        self.textView.scrollEnabled = NO;
        self.textView.layer.masksToBounds = YES;
        self.textView.layer.cornerRadius = 10.0;
        self.textView.editable = NO;
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.textView.bounces = NO;
        self.textView.dataDetectorTypes = UIDataDetectorTypeLink;
        self.textView.delegate = self;
        self.textView.backgroundColor = self.contentView.backgroundColor;
        self.textView.textColor = [UIColor blackColor];
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

- (void)layoutSubviews { // Only for debugging 
    [super layoutSubviews];
}

- (void)dealloc {
    self.delegate = nil;
    self.textView = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
    if (self.delegate) {
        [self.delegate contentCellDidBeginEditing:self];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    [aTextView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldLoadRequest:(NSURLRequest *)request {
    return [self.delegate contentCell:self shouldLoadRequest:request];
}

@end
