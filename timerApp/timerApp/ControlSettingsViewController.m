//
//  ControlSettingsViewController.m
//  timerApp
//
//  Created by David Yuschak on 12/2/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "ControlSettingsViewController.h"
#import "TimerViewController.h"
#import "StopwatchViewController.h"

@implementation ControlSettingsViewController {
    
}

@synthesize voiceControlSwitch = _voiceControlSwitch;
@synthesize shakeControlSwitch = _shakeControlSwitch;

- (void)viewDidLoad {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"shakeControl"] == nil) {
        // Shake Control is off by default
        [defaults setInteger:0 forKey:@"shakeControl"];
    }
    if ([defaults objectForKey:@"voiceControl"] == nil) {
        // Voice Control is on by default
        [defaults setInteger:1 forKey:@"voiceControl"];
    }
    
    NSInteger vc = [defaults integerForKey:@"voiceControl"];
    NSInteger sc = [defaults integerForKey:@"shakeControl"];
    
    if (vc == 0) {
        [self.voiceControlSwitch setOn:NO animated:NO];
    }
    else if (vc == 1) {
        [self.voiceControlSwitch setOn:YES animated:NO];
    }
    
    if (sc == 0) {
        [self.shakeControlSwitch setOn:NO animated:NO];
    }
    else if (sc == 1) {
        [self.shakeControlSwitch setOn:YES animated:NO];
    }
}

- (void)viewDidUnload {
    [self setVoiceControlSwitch:nil];
    [self setShakeControlSwitch:nil];
    [super viewDidUnload];
}

- (IBAction)voiceControlSwitchChange:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.voiceControlSwitch.isOn){
        [defaults setInteger:1 forKey:@"voiceControl"];
    }
    else {
        [defaults setInteger:0 forKey:@"voiceControl"];
    }
}

- (IBAction)shakeControlSwitchChange:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.shakeControlSwitch.isOn){
        [defaults setInteger:1 forKey:@"shakeControl"];
    }
    else {
        [defaults setInteger:0 forKey:@"shakeControl"];
    }
}
@end

