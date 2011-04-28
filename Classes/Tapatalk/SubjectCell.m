//
//  SubjectCell.m
//  Tapatalk
//
//  Created by Manuel Burghard on 26.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubjectCell.h"


@implementation SubjectCell
@synthesize subjectField, delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.subjectField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 10.0, 280.0, 43.0)];
        self.subjectField.delegate = self;
        self.subjectField.placeholder = NSLocalizedString(@"Subject", @"");
        [self.contentView addSubview:self.subjectField];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    //[self.subjectField becomeFirstResponder];
}

- (void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.delegate) {
        [self.delegate subjectCellDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
