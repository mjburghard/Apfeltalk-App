//
//  ATContactPickerList.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATContactPickerList : UITableViewController {
    NSMutableArray *sections;
    NSMutableArray *letters;
}

@property (retain) NSMutableArray *sections;
@property (retain) NSMutableArray *letters;

- (id)initWithStyle:(UITableViewStyle)style contacts:(NSArray *)contacts;

@end
