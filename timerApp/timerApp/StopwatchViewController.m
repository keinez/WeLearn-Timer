//
//  StopwatchViewController.m
//  timerApp
//
//  Created by David Yuschak on 10/28/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "StopwatchViewController.h"

@implementation StopwatchViewController{
    NSTimeInterval clockTime;
    NSTimeInterval plusTime;
    BOOL addClock;
}

@synthesize clockButton = _clockButton;
@synthesize timerRunning = _timerRunning;
@synthesize myClock = _myClock;
@synthesize reference = _reference;
@synthesize dateFormatter = _dateFormatter;
@synthesize table = _table;
@synthesize laps = _laps;
@synthesize lapButton = _lapButton;
@synthesize navBar = _navBar;

-(void)viewDidLoad{
    self.table.dataSource = self;
    self.navBar.delegate = self;
    self.laps = [[NSMutableArray alloc] initWithCapacity:0];
}


- (IBAction)startButtonPressed:(id)sender {
    
    if (!self.timerRunning){
        self.timerRunning = YES;
        [self.lapButton setTitle:@"Lap" forState:UIControlStateNormal];
        self.lapButton.hidden = NO;
        addClock = YES;
        self.reference = [[NSDate alloc] init];
        [self createTimer];
    }
    else{
        self.timerRunning = NO;
        [self.lapButton setTitle:@"Reset" forState:UIControlStateNormal];
        self.lapButton.hidden = NO;
        clockTime = plusTime;
        self.reference = nil;
        [self displayTime:clockTime];
    }
}

- (IBAction)resetPressed:(id)sender {
    if (!self.timerRunning){
        clockTime = 0;
        self.lapButton.hidden = YES;
        [self.laps removeAllObjects];
        [self.table reloadData];
        [self displayTime:clockTime];
    }
    else{
        NSString *lap = [NSString stringWithString:self.clockButton.titleLabel.text];
        [self.laps addObject:lap];
        [self.table reloadData];
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.laps count]-1 inSection:0];
        [self.table scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

- (void)createTimer {
    self.myClock = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                    target:self
                                                  selector:@selector(pollTime)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void) pollTime
{
    if (self.reference){
        NSTimeInterval time = [self.reference timeIntervalSinceNow];
        time = time * -1;
        plusTime = time + clockTime;
        [self displayTime:(time+clockTime)];
    }
    else{
        [self displayTime:clockTime];
    }
    
}

- (void) displayTime: (NSTimeInterval)time {
    int hundredths = (int)(time*10) % (int)10;
    
    NSString *currentTime = [NSString stringWithFormat:@"%02li:%02li:%02li.%d",
                             lround(floor(time / 3600.)) % 100,
                             lround(floor(time / 60.)) % 60,
                             lround(floor(time)) % 60,
                             hundredths];
    
    [self.clockButton setTitle:currentTime forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [self setClockButton:nil];
    [self setTable:nil];
    [self setLapButton:nil];
    [self setNavBar:nil];
    [super viewDidUnload];
}

//**************************Table View Delegate Methods************
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.laps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stopwatchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Lap %d", indexPath.row+1];
    cell.detailTextLabel.text = [self.laps objectAtIndex:indexPath.row];
    
    return cell;
}

//**************************Tab Bar Delegate Methods************

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if ([item.title isEqualToString: @"Timer"]){
        [self performSegueWithIdentifier:@"TimerSegue" sender:self];
    }
}

@end
