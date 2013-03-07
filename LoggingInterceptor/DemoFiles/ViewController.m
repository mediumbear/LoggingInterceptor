//  
//  ViewController
//
//  Created by Edward Povazan on 2013-03-07.
//  Copyright (c) 2013 Edward Povazan. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController {
    __weak IBOutlet UILabel *_label;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Title from the class name.
    NSString *title = NSStringFromClass([self class]);
    NSRange range = [title rangeOfString:@"ViewController"];
    title = [title substringToIndex:range.location];
    _label.text = title;
    self.navigationItem.title = _label.text;

    // Background grey color from the title.
    NSUInteger hash = [title hash];
    int grey = (hash + 128) % 256;
    grey = grey < 128 ? grey + 128 : grey;
    CGFloat fgrey = grey / 255.0;
    self.view.backgroundColor = [UIColor colorWithRed:fgrey green:fgrey blue:fgrey alpha:1];
}

- (void)viewDidUnload {
    _label = nil;
    [super viewDidUnload];
}


@end