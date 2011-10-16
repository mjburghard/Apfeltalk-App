//
//  ContentCell.h
//  Tapatalk
//
//  Created by Manuel Burghard on 22.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ATTextView.h"

@class ContentCell;
@class ATTextView;

@protocol ContentCellDelegate
- (void)contentCellDidBeginEditing:(ContentCell *)cell;
- (void)contentCellDidEndEditing:(ContentCell *)cell;
- (BOOL)contentCell:(ContentCell *)cell shouldLoadRequest:(NSURLRequest *)aRequest;
- (void)contentCell:(ContentCell *)cell shouldQuoteText:(NSString *)quoteText ofObjectAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface ContentCell : UITableViewCell <UITextViewDelegate>{
    ATTextView *textView;
    id <ContentCellDelegate> delegate;
}

@property (retain) ATTextView *textView;
@property (assign) id <ContentCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableViewWidth:(CGFloat)tableViewWidth;

@end
