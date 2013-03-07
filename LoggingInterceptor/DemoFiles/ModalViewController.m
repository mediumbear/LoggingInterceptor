//  
//  ModalViewController
//
//  Created by Edward Povazan on 2013-03-07.
//  Copyright (c) 2013 Edward Povazan. All rights reserved.
//

#import "ModalViewController.h"


@implementation ModalViewController

#pragma mark - Actions

- (IBAction)backAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end