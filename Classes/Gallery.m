//
//  Gallery.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 12.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Gallery.h"

@implementation Gallery
@synthesize URLString, title;

- (id)initWithTitle:(NSString *)aTitle URL:(NSString *)anURLString {
    self = [super init];
    if (self) {
        self.URLString = anURLString;
        self.title = aTitle;
    }
    return self;
}

- (void)dealloc {
    self.URLString = nil;
    self.title = nil;
    [super dealloc];
}

@end
