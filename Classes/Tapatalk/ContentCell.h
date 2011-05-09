//
//  ContentCell.h
//  Tapatalk
//
//  Created by Manuel Burghard on 22.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ContentCell;

@protocol ContentCellDelegate
- (void)contentCellDidBeginEditing:(ContentCell *)cell;
- (BOOL)contentCell:(ContentCell *)cell shouldLoadRequest:(NSURLRequest *)aRequest;
@end

@interface ContentCell : UITableViewCell <UITextViewDelegate>{
    UITextView *textView;
    id <ContentCellDelegate> delegate;
}

@property (retain) UITextView *textView;
@property (retain) id <ContentCellDelegate> delegate;

@end
