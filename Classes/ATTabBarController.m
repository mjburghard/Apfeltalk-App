//
//  ATTabBarController.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 07.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATTabBarController.h"
#import "GalleryImageViewController.h"


@implementation ATTabBarController



- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
