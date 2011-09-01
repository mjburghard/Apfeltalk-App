//
//  ATContactPickerList.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATContactPickerList.h"
#import "ATContactPicker.h"


@implementation ATContactPickerList
@synthesize sections, letters;

- (id)initWithStyle:(UITableViewStyle)style contacts:(NSArray *)_contacts {
    self = [super initWithStyle:style];
    if (self) {
        NSArray *orderedArray = [_contacts sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSMutableDictionary *sectionsDictionary = [NSMutableDictionary dictionary];
        NSMutableArray *numberAndCoArray = [NSMutableArray array];
        [sectionsDictionary setValue:numberAndCoArray forKey:@"#"];
        for (NSString *name in orderedArray) {
            NSString *firstLetter = [[name substringToIndex:1] uppercaseString];
            if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:[firstLetter characterAtIndex:0]]) {
                firstLetter = @"#";
            } else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[firstLetter characterAtIndex:0]]) {
               firstLetter = @"#"; 
            }
            NSMutableArray *tempArray = [sectionsDictionary valueForKey:firstLetter];
            if (tempArray) {
                [tempArray addObject:name];
            } else {
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:name];
                [sectionsDictionary setValue:array forKey:firstLetter];
            }
        }
        
        self.letters = [NSMutableArray arrayWithArray:[[sectionsDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
        if ([[self.letters objectAtIndex:0] isEqualToString:@"#"]) {
            [self.letters removeObjectAtIndex:0];
            [self.letters addObject:@"#"];
        }
        self.sections = [NSMutableArray array];
        
        for (NSString *letter in self.letters) {
            [self.sections addObject:[sectionsDictionary valueForKey:letter]];
        }
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
    self.letters = nil;
    self.sections = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.letters objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.letters;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [(NSArray *)[self.sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [(NSArray *)[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ATContactPicker *contactPicker = (ATContactPicker *)[self.navigationController.viewControllers objectAtIndex:0];
    NSLog(@"%@", self.parentViewController);
    
    if (contactPicker.delegate && [(NSObject *)contactPicker.delegate respondsToSelector:@selector(contactPicker:didSelectContact:)]) {
        [contactPicker.delegate contactPicker:contactPicker didSelectContact:[(NSArray *)[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    }
}

@end
