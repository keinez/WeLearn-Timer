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
    unsigned int currentTimer;
    unsigned int currentIndex;
    NSString *currentTimerName;
    BOOL timerEdited;
    BOOL savedTimer;
}

@synthesize clockButton = _clockButton;
@synthesize timerRunning = _timerRunning;
@synthesize myClock = _myClock;
@synthesize reference = _reference;
@synthesize dateFormatter = _dateFormatter;
@synthesize table = _table;
@synthesize savedTimers = _savedTimers;
@synthesize savedNames = _savedNames;
@synthesize savedAlarms = _savedAlarms;
@synthesize picker = _picker;
@synthesize resetButton = _resetButton;
@synthesize navBar = _navBar;

-(void)viewDidLoad{
    self.table.dataSource = self;
    self.table.delegate = self;
    self.navBar.delegate = self;
    pickerUp = NO;
    currentIndex = 1;
    currentTimer = 0;
    
    self.savedTimers = [[NSMutableArray alloc] initWithCapacity:0];
    self.savedNames = [[NSMutableArray alloc] initWithCapacity:0];
    self.savedValues = [[NSMutableArray alloc] initWithCapacity:0];
    self.savedAlarms = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.savedReferences = [[NSMutableDictionary alloc] initWithCapacity:0];
    [self.table reloadData];
}


- (IBAction)savePressed:(id)sender {
    if (timerEdited == NO){
        return;
    }
    
    NSString *currentTime = [NSString stringWithFormat:@"%02li:%02li:%02li",
                             lround(floor(totalTime / 3600.)) % 100,
                             lround(floor(totalTime / 60.)) % 60,
                             lround(floor(totalTime)) % 60];
    [self.savedTimers addObject:currentTime];
    if (currentTimerName != nil){
        [self.savedNames addObject:currentTimerName];
    }
    else{
        [self.savedNames addObject:[NSString stringWithFormat:@"Timer %d", currentIndex++]];
    }
    NSNumber *wrap = [NSNumber numberWithDouble:totalTime];
    [self.savedValues addObject:wrap];
    if (savedTimer){
        currentTimer++;
    }
    else {
        savedTimer = YES;
    }
    [self.table reloadData];
    timerEdited = NO;
}

- (IBAction)editPressed:(id)sender {
    timerEdited = YES;
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
    if ([self.savedAlarms objectForKey:currentTimerName] == nil){
        if (totalTime == 0){
            return;
        }
        self.timerRunning = YES;
        self.reference = [[NSDate alloc] init];
        [self createTimer];
        self.resetButton.hidden = YES;
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        NSDate *item = [NSDate dateWithTimeIntervalSinceNow:clockTime];
        localNotif.fireDate = item;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.alertBody = [NSString stringWithFormat:@"%@'s Time is Up!", currentTimerName];
        localNotif.alertAction = @"View in App";
        //localNotif.userInfo = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:currentTimerName, self.savedAlarms, nil ]forKeys:[[NSArray alloc] initWithObjects:@"name", @"saveArray", nil ]];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [self.savedAlarms setObject:localNotif forKey:currentTimerName];
        [self.savedReferences setObject:self.reference forKey:currentTimerName];
    }
    else{
        self.timerRunning = NO;
        clockTime = plusTime;
        self.reference = nil;
        [self displayTime:clockTime];
        self.resetButton.hidden = NO;
        [[UIApplication sharedApplication] cancelLocalNotification:[self.savedAlarms objectForKey:currentTimerName]];
        [self.savedAlarms removeObjectForKey:currentTimerName];
        
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
    if ([self.savedAlarms objectForKey:currentTimerName] != nil){
        NSTimeInterval time = [self.reference timeIntervalSinceNow];
        plusTime = time + clockTime;
        if(lround(floor(plusTime)) <= 0){
            self.reference = nil;
            [self displayTime:0];
            //self.timerRunning = NO;
            self.resetButton.hidden = NO;
            [self.savedAlarms removeObjectForKey:currentTimerName];
        }
        [self displayTime:(time+clockTime)];
    }
    else{
        [self displayTime:clockTime];
    }
}

- (void) displayTime: (NSTimeInterval)time{
    NSString *currentTime = [NSString stringWithFormat:@"%02li:%02li:%02li",
                             lround(floor(time / 3600.)) % 100,
                             lround(floor(time / 60.)) % 60,
                             lround(floor(time)) % 60];
    [self.clockButton setTitle:currentTime forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [self setClockButton:nil];
    [self setTable:nil];
    [self setResetButton:nil];
    [self setNavBar:nil];
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
    if (component == 0)
        return [NSString stringWithFormat:@"%d hours", row];
    if (component == 1)
        return [NSString stringWithFormat:@"%d min", row];
    return [NSString stringWithFormat:@"%d sec", row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    
}

- (void) showPicker {
    self.editController = (EditViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"editViewController"];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.editController];
    
    self.editController.timePicker.dataSource = self;
    self.editController.timePicker.delegate = self;
    self.editController.timerName.delegate = self;
    self.picker = self.editController.timePicker;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(pickerDone)];
    
    self.editController.title = @"Edit Timer";
    self.editController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.editController.navigationItem.rightBarButtonItem = doneButton;
    
    [self presentModalViewController:nvc animated:YES];
}

- (void) pickerDone{
    int hours = [self.editController.timePicker selectedRowInComponent:0];
    int mins = [self.editController.timePicker selectedRowInComponent:1];
    int secs = [self.editController.timePicker selectedRowInComponent:2];
    
    clockTime = (hours*3600)+(mins*60)+secs;
    totalTime = clockTime;
    
    if (self.editController.name != nil){
        currentTimerName = self.editController.name;
    }
    else{
        currentTimerName = [NSString stringWithFormat:@"Timer %d", currentIndex++];
    }
    
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
    return [self.savedTimers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"timerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.savedNames objectAtIndex:(indexPath.row)];
    cell.detailTextLabel.text = [self.savedTimers objectAtIndex:(indexPath.row)];
    if (indexPath.row == currentTimer)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentTimer = indexPath.row;
    currentTimerName = [self.savedNames objectAtIndex:indexPath.row];
    totalTime = [[self.savedValues objectAtIndex:(indexPath.row)] doubleValue];
    clockTime = totalTime;
    plusTime = 0;
    if ([self.savedAlarms objectForKey:currentTimerName] != nil){
        self.reference = [self.savedReferences objectForKey:currentTimerName];
        self.resetButton.hidden = YES;
        self.timerRunning = YES;
    }
    else {
        self.reference = nil;
    }
    [self displayTime:clockTime];
    [self.table reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSLog(@"User pressed OK");
	}
}

//**************************Tab Bar Delegate Methods************

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if ([item.title isEqualToString:@"Stopwatch"]){
        [self performSegueWithIdentifier:@"StopwatchSegue" sender:self];
    }
}

@end
