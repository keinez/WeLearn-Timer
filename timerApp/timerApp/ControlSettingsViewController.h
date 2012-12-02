//
//  ControlSettingsViewController.h
//  timerApp
//
//  Created by David Yuschak on 12/2/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <OpenEars/PocketsphinxController.h>

@interface ControlSettingsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *controlTableView;
@property (strong, nonatomic) IBOutlet UISwitch *voiceControlSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *shakeControlSwitch;

- (IBAction)voiceControlSwitchChange:(id)sender;
- (IBAction)shakeControlSwitchChange:(id)sender;

@end
