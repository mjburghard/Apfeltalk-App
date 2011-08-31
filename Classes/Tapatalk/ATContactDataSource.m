//
//  ATContactDataSource.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ATContactDataSource.h"
#import "ATContactModel.h"
#import "ATTableViewController.h"

@implementation ATContactDataSource

@synthesize contactModel, messageController;

- (id)init {
    if (self = [super init]) {
        contactModel = [[ATContactModel alloc] init];
        self.model = contactModel;
    }
    return self;
}

- (void)dealloc {
    self.messageController = nil;
    self.contactModel = nil;
    self.items = nil;
    [super dealloc];
}



- (void)tableViewDidLoadModel:(UITableView*)tableView {
    
    self.items = nil;
    
    self.items = [NSMutableArray new];
    int countPeople = [((ATContactModel *)self.model).searchResults count];
    
    for (int i = 0; i < countPeople; i++) {
        TTTableItem* item = [TTTableTextItem itemWithText:[((ATContactModel *)self.model).searchResults objectAtIndex:i]];
        [_items addObject:item];
           
    }
} 

- (void)search:(NSString*)text {
    
    if (([text rangeOfString:@";" options:NSBackwardsSearch].location != NSNotFound) && [text length] > 1) {
        NSString *username = [text stringByReplacingOccurrencesOfString:@";" withString:@""];
        username = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
        [messageController addRecipient:username forFieldAtIndex:0];
        [messageController setText:nil forFieldAtIndex:0];
        return;
    } else if ([contactModel isLoaded] && [contactModel.onlineUsers containsObject:text]) {
        [messageController addRecipient:text forFieldAtIndex:0];
        [messageController setText:nil forFieldAtIndex:0];
        return;
    }
    [contactModel search:text];
}

@end