//
//  SettingsViewController.h
//  timerApp
//
//  Created by David Yuschak on 12/2/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *voiceControlSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *shakeControlSwitch;

- (IBAction)voiceControlSwitchChange:(id)sender;
- (IBAction)shakeControlSwitchChange:(id)sender;

@end
