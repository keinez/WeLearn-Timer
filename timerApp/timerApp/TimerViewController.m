//
//  TimerViewController.m
//  timerApp
//
//  Created by David Yuschak on 10/28/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "TimerViewController.h"
#import "StopwatchViewController.h"

@implementation TimerViewController{
    NSTimeInterval clockTime[3];
    NSTimeInterval totalTime[3];
    NSTimeInterval plusTime[3];
    NSDate *reference[3];
    BOOL timerRunning[3];
    NSMutableArray *timerName;
    NSMutableArray *timers;
    NSMutableArray *timerEditors;
    int activeTag;
    BOOL clockRunning;
}

@synthesize timer1 = _timer1;
@synthesize timer2 = _timer2;
@synthesize timer3 = _timer3;
@synthesize timerEditor1 = _timerEditor1;
@synthesize timerEditor2 = _timerEditor2;
@synthesize timerEditor3 = _timerEditor3;
@synthesize myClock = _myClock;
@synthesize dateFormatter = _dateFormatter;
@synthesize savedTimers = _savedTimers;
@synthesize savedNames = _savedNames;
@synthesize savedAlarms = _savedAlarms;
@synthesize picker = _picker;
@synthesize openEarsEventsObserver;

#pragma mark -
#pragma mark OpenEars

// Lazily allocated OpenEarsEventsObserver.
- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"Received for timer");
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    
    if (timerRunning) {
        if([hypothesis isEqualToString:@"STOP"] || [hypothesis isEqualToString:@"END"]) {
            // stop clock
            [self startButtonPressed:nil];
            return;
        }
    }
    else {
        if([hypothesis isEqualToString:@"START"] || [hypothesis isEqualToString:@"GO"]) {
            // start clock
            [self startButtonPressed:nil];
            return;
        }
        if([hypothesis isEqualToString:@"RESET"]) {
            // save clock
            [self resetPressed:nil];
            return;
        }
    }
}




#pragma mark -
#pragma mark View

-(void)viewDidLoad{
    for (int i=0; i<3; ++i) {
        totalTime[i] = 60;
        clockTime[i] = 60;
        timerRunning[i] = NO;
        [self displayTime:clockTime[i] at:i];
    }
    clockRunning = NO;
    
    self.savedTimers = [[NSMutableArray alloc] initWithCapacity:0];
    self.savedNames = [[NSMutableArray alloc] initWithCapacity:0];
    self.savedValues = [[NSMutableArray alloc] initWithCapacity:0];
    self.savedAlarms = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.savedReferences = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    timerName = [[NSMutableArray alloc] initWithObjects:@"Timer 1", @"Timer 2", @"Timer 3", nil];
    timers = [[NSMutableArray alloc] initWithObjects:self.timer1, self.timer2, self.timer3, nil];
    timerEditors = [[NSMutableArray alloc] initWithObjects:self.timerEditor1, self.timerEditor2, self.timerEditor3, nil];
}

- (void)viewDidAppear:(BOOL)animated {
    NSInteger vc = [[NSUserDefaults standardUserDefaults] integerForKey:@"voiceControl"];
    if (vc) {
        [self.openEarsEventsObserver setDelegate:self];
        [[Pocketsphinx sharedInstance] changeModelTo:@"Timer"];
    }
    [self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.openEarsEventsObserver setDelegate:nil];
    [self becomeFirstResponder];
}

- (void)viewDidUnload {
    [self setTimer1:nil];
    [self setTimer2:nil];
    [self setTimer3:nil];
    [self setTimerEditor1:nil];
    [self setTimerEditor2:nil];
    [self setTimerEditor3:nil];
    [super viewDidUnload];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSInteger shake = [[NSUserDefaults standardUserDefaults] integerForKey:@"shakeControl"];
    
    if (shake) {
        [self startButtonPressed:nil];
    }
}


#pragma mark -
#pragma mark View actions

- (IBAction)editPressed:(UIButton *)button {
    activeTag = button.tag;
    NSLog(@"Edit - Tag is %d", activeTag);
    [self showPicker];
}

- (IBAction)startButtonPressed:(UIButton *)button {
    activeTag=button.tag;
    NSLog(@"Start - Tag is %d", activeTag);
    
    if (!timerRunning[activeTag]) {     //[self.savedAlarms objectForKey:timerName[activeTag]] == nil){
        NSLog(@"go");
        if (totalTime == 0){
            return;
        }
        
        [self createTimer];
        
        timerRunning[activeTag] = YES;
        
        reference[activeTag] = [[NSDate alloc] init];
        [timerEditors[activeTag] setValue:[NSNumber numberWithBool:YES] forKey:@"hidden"];
        
        // Create notification
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        NSDate *item = [[NSDate dateWithTimeIntervalSinceNow:clockTime[activeTag]] dateByAddingTimeInterval:-1]; //CHANGED clocktime.. not fully tested
        localNotif.fireDate = item;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.alertBody = [NSString stringWithFormat:@"%@'s Time is Up!", timerName[activeTag]];
        localNotif.alertAction = @"View in App";
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.repeatInterval = 0;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [self.savedAlarms setObject:localNotif forKey:timerName[activeTag]];
        [self.savedReferences setObject:reference[activeTag] forKey:timerName[activeTag]];
    }
    else{
        NSLog(@"stop");
        timerRunning[activeTag] = NO;
        [self destroyTimer];
        clockTime[activeTag] = plusTime[activeTag];
        reference[activeTag] = nil;
        [self displayTime:clockTime[activeTag] at:activeTag];
        [timerEditors[activeTag] setValue:[NSNumber numberWithBool:NO] forKey:@"hidden"];
        [[UIApplication sharedApplication] cancelLocalNotification:[self.savedAlarms objectForKey:timerName[activeTag]]];
        [self.savedAlarms removeObjectForKey:timerName[activeTag]];
    }
}

- (IBAction)resetPressed:(UIButton *)button {
    activeTag = button.tag;
    NSLog(@"Reset - Tag is %d", activeTag);
    
    if (!timerRunning[activeTag]){
        clockTime[activeTag] = totalTime[activeTag];
        [self displayTime:clockTime[activeTag] at:activeTag];
    }
}


#pragma mark -
#pragma mark Clock runner

- (void)createTimer {
    if (!clockRunning) {
        NSLog(@"starting clock");
        clockRunning = YES;
        self.myClock = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(pollTime)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

- (void)destroyTimer {
    int i;
    // Check for if none of the timer is running
    for (i=0; i<3; ++i) {
        if (timerRunning[i]) {
            break;
        }
    }
    if (i==3) {
        NSLog(@"terminating clock");
        clockRunning = NO;
        [self.myClock invalidate];
        self.myClock = nil;
    }
}



- (void) pollTime
{
    for (int i=0; i<3; ++i) {
        if (timerRunning[i]){
            NSTimeInterval time = [reference[i] timeIntervalSinceNow];
            plusTime[i] = time + clockTime[i];
            [self displayTime:(time+clockTime[i]) at:i];
            
            if(lround(floor(plusTime[i])) <= 0){
                [self startButtonPressed:timers[i]];
                [self resetPressed:timers[i]];
            }
        }
        else{
            [self displayTime:clockTime[i] at:i];
        }
    }
}

- (void) displayTime:(NSTimeInterval)time at:(int)tag {
    if (time<=0) {
        time = 0; // so timer doesn't display negative
    }
    NSString *currentTime = [NSString stringWithFormat:@"%02li:%02li:%02li",
                             lround(floor(time / 3600.)) % 100,
                             lround(floor(time / 60.)) % 60,
                             lround(floor(time)) % 60];
    [timers[tag] setTitle:currentTime forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark Picker View Delegate Methods

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
    
    clockTime[activeTag] = (hours*3600)+(mins*60)+secs;
    totalTime[activeTag] = clockTime[activeTag];
    
    if (self.editController.name != nil){
        timerName[activeTag] = self.editController.name;
    }
    else{
        [timerName replaceObjectAtIndex:activeTag withObject:[NSString stringWithFormat:@"Timer %d", activeTag]];
    }
    
    [self displayTime:clockTime[activeTag] at:activeTag];
    
    [self dismissModalViewControllerAnimated:YES];
}




@end

