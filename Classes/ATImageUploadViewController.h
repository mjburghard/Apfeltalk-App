//
//  ATImageUploadViewController.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 13.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATImageUploadViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSArray *galleryTitles;
@property (nonatomic, copy) NSString *gallery;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, assign) NSInteger indexOfDefaultGallery;
@property (nonatomic, retain) NSArray *cookies;
@property (nonatomic, retain) NSMutableData *receivedData;

@end
