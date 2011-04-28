//
//  User.h
//  Tapatalk
//
//  Created by Manuel Burghard on 25.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"


@interface User : NSObject {
    BOOL loggedIn;
    
}

@property (assign, getter=isLoggedIn) BOOL loggedIn;

+ (User*)sharedUser;

@end
