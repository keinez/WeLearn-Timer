//
//  PickerViewController.m
//  timerApp
//
//  Created by David Yuschak on 10/29/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "PickerViewController.h"

@implementation PickerViewController
@synthesize picker;

- (void)viewDidUnload {
    [self setPicker:nil];
    [super viewDidUnload];
}
- (IBAction)donePressed:(id)sender {
    
}
@end
