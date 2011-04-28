//
//  SubForum.h
//  Tapatalk
//
//  Created by Manuel Burghard on 16.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Section.h"


@interface SubForum : Section {
    NSString *description;
}
@property (copy) NSString *description;

@end
