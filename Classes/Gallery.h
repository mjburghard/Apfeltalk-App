//
//  Gallery.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 12.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gallery : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *URLString;

- (id)initWithTitle:(NSString *)title URL:(NSString *)URLString;

@end
