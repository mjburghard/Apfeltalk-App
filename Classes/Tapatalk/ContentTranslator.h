//
//  ContentTranslator.h
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 12.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"


@interface ContentTranslator : NSObject {
    NSDictionary *iOSTranslations;
    NSDictionary *atTranslations;
}

@property (retain) NSDictionary *iOSTranslations;
@property (retain) NSDictionary *atTranslations;

- (NSString *)translateStringForiOS:(NSString *)aString;
- (NSString *)translateStringForAT:(NSString *)aString;

@end
