//
//  TimerViewController.h
//  timerApp
//
//  Created by David Yuschak on 10/28/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import "EditViewController.h"
#import "Pocketsphinx.h"

@interface TimerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, OpenEarsEventsObserverDelegate>


@property (strong, nonatomic) IBOutlet UIButton *timer1;
@property (strong, nonatomic) IBOutlet UIButton *timer2;
@property (strong, nonatomic) IBOutlet UIButton *timer3;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *timerEditor1;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *timerEditor2;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *timerEditor3;


@property (nonatomic) BOOL timerRunning;
@property (strong, nonatomic) NSTimer *myClock;
@property (strong, nonatomic) NSDate *reference;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableArray *savedTimers;
@property (strong, nonatomic) NSMutableArray *savedNames;
@property (strong, nonatomic) NSMutableArray *savedValues;
@property (strong, nonatomic) NSMutableDictionary *savedAlarms;
@property (strong, nonatomic) NSMutableDictionary *savedReferences;
@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) EditViewController *editController;

@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;

//- (IBAction)savePressed:(id)sender;
- (IBAction)startButtonPressed:(UIButton *)button;
- (IBAction)resetPressed:(UIButton *)button;
- (IBAction)editPressed:(UIButton *)button;


- (void)createTimer;
- (void) showPicker;

@end
