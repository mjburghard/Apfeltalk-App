//
//  ATContactPicker.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ATContactPicker;

@protocol ATContactPickerDelegate

- (void)contactPicker:(ATContactPicker *)contactPicker didSelectContact:(NSString *)contactName;

@end

@interface ATContactPicker : UITableViewController {
    NSArray *groups;
    NSArray *groupTitles;
    id <ATContactPickerDelegate> delegate;
}

@property (retain) NSArray *groups;
@property (retain) NSArray *groupTitles;
@property (assign) id <ATContactPickerDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style groups:(NSArray *)_groups titles:(NSArray *)titles;

@end
