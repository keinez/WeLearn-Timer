//
//  TimerViewController.h
//  timerApp
//
//  Created by David Yuschak on 10/28/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *clockButton;
@property (nonatomic) BOOL timerRunning;
@property (strong, nonatomic) NSTimer *myClock;
@property (strong, nonatomic) NSDate *reference;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSMutableArray *savedTimers;
@property (strong, nonatomic) NSMutableArray *savedValues;
@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;


- (IBAction)editPressed:(id)sender;
- (IBAction)startButtonPressed:(id)sender;
- (IBAction)resetPressed:(id)sender;


- (void)createTimer;
- (void) showPicker;

@end
