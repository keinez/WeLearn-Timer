//
//  TimerViewController.m
//  timerApp
//
//  Created by David Yuschak on 10/28/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "TimerViewController.h"

@implementation TimerViewController{
    NSTimeInterval clockTime;
    NSTimeInterval totalTime;
    NSTimeInterval plusTime;
    BOOL pickerUp;
    UIViewController *menuController;
}

@synthesize clockButton = _clockButton;
@synthesize timerRunning = _timerRunning;
@synthesize myClock = _myClock;
@synthesize reference = _reference;
@synthesize dateFormatter = _dateFormatter;
@synthesize table = _table;
@synthesize savedTimers = _savedTimers;
@synthesize picker = _picker;
@synthesize resetButton = _resetButton;

-(void)viewDidLoad{
    self.timerRunning = NO;
    self.table.dataSource = self;
    self.table.delegate = self;
    pickerUp = NO;
    self.savedTimers = [[NSMutableArray alloc] initWithCapacity:0];
    self.savedValues = [[NSMutableArray alloc] initWithCapacity:0];
    [self.table reloadData];
}


- (IBAction)editPressed:(id)sender {
    if(self.timerRunning){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"WeMP Timer"
                              message: @"Pause the timer before you edit it!"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self showPicker];
}

- (IBAction)startButtonPressed:(id)sender {
    if (!self.timerRunning){
        if (totalTime == 0){
            return;
        }
        self.timerRunning = YES;
        self.reference = [[NSDate alloc] init];
        [self createTimer];
        self.resetButton.hidden = YES;
    }
    else{
        self.timerRunning = NO;
        clockTime = plusTime;
        self.reference = nil;
        [self displayTime:clockTime];
        self.resetButton.hidden = NO;
    }
}

- (IBAction)resetPressed:(id)sender {
    if (!self.timerRunning){
        clockTime = totalTime;
        [self displayTime:clockTime];
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
        plusTime = time + clockTime;
        if(lround(floor(plusTime)) == 0){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"WeMP Timer"
                                  message: @"Time is up!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            self.reference = nil;
            [self displayTime:0];
            [alert show];
            self.timerRunning = NO;
            self.resetButton.hidden = NO;
            
        }
        [self displayTime:(time+clockTime)];
    }
    else{
        [self displayTime:clockTime];
    }
    
}

- (void) displayTime: (NSTimeInterval)time{
    /*/ Divide the interval by 3600 and keep the quotient and remainder
    div_t h = div(time, 3600);
    int hours = h.quot;
    // Divide the remainder by 60; the quotient is minutes, the remainder
    // is seconds.
    div_t m = div(h.rem, 60);
    int minutes = m.quot;
    int seconds = m.rem;   */
    
    NSString *currentTime = [NSString stringWithFormat:@"%02li:%02li:%02li",
                             lround(floor(time / 3600.)) % 100,
                             lround(floor(time / 60.)) % 60,
                             lround(floor(time)) % 60];
    
    //NSLog(@"%d:%d:%d", hours, minutes, seconds);
    
    self.clockButton.titleLabel.text = currentTime;
}

- (void)viewDidUnload {
    [self setClockButton:nil];
    [self setTable:nil];
    [self setResetButton:nil];
    [super viewDidUnload];
}

//*************************Picker View Delegate Methods************

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
        return 25;
    return 60;
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d", row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    
}

- (void) showPicker {
    menuController = [[UIViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:menuController];
    self.picker = [[UIPickerView alloc] init];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    self.picker.showsSelectionIndicator = YES;  
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDone)];
    
    [menuController.view addSubview:self.picker];
    menuController.title = @"Pick Timer Duration";
    menuController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    menuController.navigationItem.rightBarButtonItem = doneButton;
    
    [self presentModalViewController:nvc animated:YES];
}

- (void) pickerDone{
    int hours = [self.picker selectedRowInComponent:0];
    int mins = [self.picker selectedRowInComponent:1];
    int secs = [self.picker selectedRowInComponent:2];
    
    clockTime = (hours*3600)+(mins*60)+secs;
    totalTime = clockTime;
    
    [self displayTime:clockTime];
    
    [self dismissModalViewControllerAnimated:YES];
}

//**************************Table View Delegate Methods************
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.savedTimers count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        static NSString *CellIdentifier = @"saveCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        return cell;
    }
        
    static NSString *CellIdentifier = @"timerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Timer #%d", indexPath.row];
    cell.detailTextLabel.text = [self.savedTimers objectAtIndex:(indexPath.row - 1)];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        NSString *currentTime = [NSString stringWithFormat:@"%02li:%02li:%02li",
                                 lround(floor(totalTime / 3600.)) % 100,
                                 lround(floor(totalTime / 60.)) % 60,
                                 lround(floor(totalTime)) % 60];
        [self.savedTimers addObject:currentTime];
        NSNumber *wrap = [NSNumber numberWithDouble:totalTime];
        [self.savedValues addObject:wrap];
        [self.table reloadData];
    }
    else{
        self.timerRunning = NO;
        totalTime = [[self.savedValues objectAtIndex:(indexPath.row - 1)] doubleValue];
        clockTime = totalTime;
        plusTime = 0;
        self.reference = nil;
        [self displayTime:clockTime];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSLog(@"user pressed OK");
	}
}

@end
