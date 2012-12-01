//
//  StopwatchViewController.h
//  timerApp
//
//  Created by David Yuschak on 10/28/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopwatchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>
@property (strong, nonatomic) IBOutlet UIButton *clockButton;
@property (nonatomic) BOOL timerRunning;
@property (strong, nonatomic) NSTimer *myClock;
@property (strong, nonatomic) NSDate *reference;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSMutableArray *laps;
@property (strong, nonatomic) IBOutlet UIButton *lapButton;
@property (strong, nonatomic) IBOutlet UITabBar *navBar;





- (IBAction)startButtonPressed:(id)sender;
- (IBAction)resetPressed:(id)sender;


- (void)createTimer;


@end
