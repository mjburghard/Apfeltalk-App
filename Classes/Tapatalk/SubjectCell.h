//
//  SubjectCell.h
//  Tapatalk
//
//  Created by Manuel Burghard on 26.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubjectCell;

@protocol SubjectCellDelegate

- (void)subjectCellDidBeginEditing:(SubjectCell *)cell;

@end


@interface SubjectCell : UITableViewCell <UITextFieldDelegate> {
    UITextField *subjectField;
    id <SubjectCellDelegate> delegate;
}

@property (retain) UITextField *subjectField;
@property (retain) id <SubjectCellDelegate> delegate;

@end
