//
//  SettingsViewController.m
//  timerApp
//
//  Created by David Yuschak on 12/2/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "SettingsViewController.h"
#import "TimerViewController.h"
#import "StopwatchViewController.h"

@implementation SettingsViewController

- (void)viewDidUnload {
    [self setNavBar:nil];
    [super viewDidUnload];
}


//**************************Tab Bar Delegate Methods************

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if ([item.title isEqualToString: @"Timer"]){
        [self.navigationController popToRootViewControllerAnimated:NO]
        ;
    }
    else if ([item.title isEqualToString: @"Stopwatch"]){
        //[self performSegueWithIdentifier:@"TimerSegue" sender:self];
        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:[[StopwatchViewController alloc] init] animated:NO]
        ;
    }
}

@end
