//
//  ATImageUploadViewController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 13.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ATImageUploadViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GalleryTopController.h"
#include <CommonCrypto/CommonDigest.h>
#import "User.h"

@implementation ATImageUploadViewController
@synthesize image, galleryTitles, gallery, pickerView, textView, textField, indexOfDefaultGallery, cookies, receivedData;

static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    self.receivedData = nil;
    self.cookies = nil;
    self.indexOfDefaultGallery = 0;
    self.textView = nil;
    self.textField = nil;
    self.pickerView = nil;
    self.gallery = nil;
    self.galleryTitles = nil;
    self.image = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (NSString*)md5Hash:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char result[16];
    CC_LONG length = (CC_LONG)strlen(cStr);
    CC_MD5( cStr, length, result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (void)dismissDoneButton {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)dismissInput {
    if (!self.pickerView.hidden) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        CGRect frame = self.tableView.frame;
        frame.size.height += 216.0;
        self.tableView.frame = frame;
        self.pickerView.frame = CGRectMake(0.0, self.view.frame.size.height, 320.0, 216.0);
        [UIView commitAnimations];
    } else if (self.textView.isFirstResponder) 
        [self.textView resignFirstResponder];
    else 
        [self.textField resignFirstResponder];
    
    [self dismissDoneButton];
}

- (void)showDoneButton {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:ATLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(dismissInput)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
}

- (void)appendImageData:(NSData*)data
               withName:(NSString*)name
                 toBody:(NSMutableData*)body {
    NSString *beginLine = [NSString stringWithFormat:@"--%@\r\n", kStringBoundary];
	NSString *endLine = @"\r\n";
    
    [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:
                       @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n",
                       name]
                      dataUsingEncoding:NSISOLatin1StringEncoding]];
    [body appendData:[[NSString
                       stringWithFormat:@"Content-Length: %d\r\n", data.length]
                      dataUsingEncoding:NSISOLatin1StringEncoding]];
    [body appendData:[[NSString
                       stringWithString:@"Content-Type: image/jpeg\r\n\r\n"]
                      dataUsingEncoding:NSISOLatin1StringEncoding]];
    [body appendData:data];
    //[body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", kStringBoundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)uploadImage {
    NSLog(@"Upload: \nTitle: %@\nDescription: %@\nGallery: %@\n", self.textField.text, self.textView.text, [self.galleryTitles objectAtIndex:[self.pickerView selectedRowInComponent:0]]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.apfeltalk.de/forum/login.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSString *md5Hash = [self md5Hash:[User sharedUser].password];
    NSString *parameters = [NSString stringWithFormat:@"do=login&\
    vb_login_username=%@&\
    vb_logn_password=&\
    vb_login_password_hint=Kennwort&\
    cookieuser=1&\
    s&\
    securitytoken=guest&\
    do=login&\
    vb_login_md5password=%@&\
    vb_login_md5password_utf=%@", [User sharedUser].username, md5Hash, md5Hash];
    NSData *paramtersData = [parameters dataUsingEncoding:NSASCIIStringEncoding];
    [request setValue:[NSString stringWithFormat:@"%lu", [paramtersData length]]forHTTPHeaderField:@"content-length"];
    [request setHTTPBody:paramtersData];
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSMutableData *data = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"Received data: %@", s);
        [s release];
    } else if (response) {
        self.cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    }
    
    [request release];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.apfeltalk.de/gallery/uploadphoto.php?category=518&deftitle=%@&defdesc=%@&defkeywords=", self.textField.text, self.textView.text]]];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    [request setValue:@"multipart/form-data; boundary=3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f" forHTTPHeaderField:@"content-type"];
    
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.0);
    data = [NSMutableData data];
    [self appendImageData:imageData withName:self.textField.text toBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", [data length]]forHTTPHeaderField:@"content-length"];
    [request setHTTPBody:data];
    NSLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease]);
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}
- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Upload";
    self.navigationController.navigationBar.tintColor = ATNavigationBarTintColor;
    
    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithTitle:ATLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = uploadButton;
    [uploadButton release];
    
    self.pickerView = [[[UIPickerView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, 320.0, 216.0)] autorelease];
    self.pickerView.hidden = YES;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 44.0;
            break;
        case 1:
            return 100.0;
            break;
        case 2:
            return 44.0;
            break;
        default:
            return 44.0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TitleCellIdentifier = @"TitleCell";
    static NSString *DescriptionCellIdentifier = @"DescriptionCell";
    static NSString *GalleryCellIdentifier = @"GalleryCell";
    static NSString *UploadCellIdentifier = @"UploadCell";
    
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0:
            cell = [self.tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
            if (cell == nil) {
                cell =[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TitleCellIdentifier] autorelease];
            }
            cell.textLabel.text = TitleCellIdentifier;
            cell.imageView.image = self.image;
            cell.imageView.layer.masksToBounds = YES;
            
            [cell.imageView.layer setCornerRadius:10.0];
            if (!textField)
                self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(75.0, 11.0, 215.0, 21.0)] autorelease];
            self.textField.delegate = self;
            textField.placeholder = @"Title";
            [cell.contentView addSubview:textField];
            cell.textLabel.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 1:
            cell = [self.tableView dequeueReusableCellWithIdentifier:DescriptionCellIdentifier];
            if (cell == nil) {
                cell =[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DescriptionCellIdentifier] autorelease];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (!textView)
                self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 99.0)];
            self.textView.delegate = self;
            self.textView.layer.masksToBounds = YES;
            self.textView.layer.cornerRadius = 10.0;
            [cell.contentView addSubview:self.textView];
            break;
        case 2:
            cell = [self.tableView dequeueReusableCellWithIdentifier:GalleryCellIdentifier];
            if (cell == nil) {
                cell =[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GalleryCellIdentifier] autorelease];
            }
            
            if (!gallery) {
                self.gallery = [self.galleryTitles objectAtIndex:self.indexOfDefaultGallery];
            }
            
            cell.textLabel.text = self.gallery;
            break;
        case 3:
            cell = [self.tableView dequeueReusableCellWithIdentifier:UploadCellIdentifier];
            if (cell == nil) {
                cell =[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UploadCellIdentifier] autorelease];
            }
            
            cell.textLabel.text = ATLocalizedString(@"Upload", nil);
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            break;
        default:
            return nil;
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            [textField becomeFirstResponder];
            break;
        } case 1: {
            [textView becomeFirstResponder];
            break;
        } case 2: {
            if (self.pickerView.hidden) {
                self.pickerView.hidden = NO;
                [self.tableView.superview addSubview:self.pickerView];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                self.pickerView.frame = CGRectMake(0.0, self.view.frame.size.height - 216.0, 320.0, 216.0);
                CGRect frame = self.tableView.frame;
                frame.size.height -= 216.0;
                self.tableView.frame = frame;
                [UIView commitAnimations];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [self showDoneButton];
            }
            break;
        } case 3: {
            [self uploadImage];
            break;
        } default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.galleryTitles objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.galleryTitles.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.gallery = [self.galleryTitles objectAtIndex:row];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITextViewDelegate & UITextFieldDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self showDoneButton];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showDoneButton];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    NSLog(@"%@", [response allHeaderFields]);
    
    self.receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *string = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
    NSLog(@"Result: %@", string);
    [string release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

- (void)connection:(NSURLConnection *)connection 
   didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten 
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
}

@end
