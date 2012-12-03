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
    NSMutableArray *timerName;
    NSMutableArray *timers;
    NSMutableArray *timerEditors;
    int activeTag;
}

@synthesize timer1 = _timer1;
@synthesize timer2 = _timer2;
@synthesize timer3 = _timer3;
@synthesize timerEditor1 = _timerEditor1;
@synthesize timerEditor2 = _timerEditor2;
@synthesize timerEditor3 = _timerEditor3;
@synthesize timerRunning = _timerRunning;
@synthesize myClock = _myClock;
@synthesize reference = _reference;
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
    
    if([hypothesis isEqualToString:@"START"] || [hypothesis isEqualToString:@"GO"]) {
        // start clock
        [self startButtonPressed:nil];
        return;
    }
    else if([hypothesis isEqualToString:@"STOP"]) {
        // stop clock
        [self startButtonPressed:nil];
        return;
    }
}




#pragma mark -
#pragma mark View

-(void)viewDidLoad{
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
/*
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
*/

- (IBAction)editPressed:(UIButton *)button {
    activeTag = button.tag;
    NSLog(@"Tag is %d", activeTag);
    
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

- (IBAction)startButtonPressed:(UIButton *)button {
    activeTag=button.tag;
    NSLog(@"Tag is %d", activeTag);
    
    if ([self.savedAlarms objectForKey:timerName[activeTag]] == nil){
        if (totalTime == 0){
            return;
        }
        self.timerRunning = YES;
        self.reference = [[NSDate alloc] init];
        [self createTimer];
        
        [timerEditors[activeTag] setValue:[NSNumber numberWithBool:YES] forKey:@"hidden"];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        NSDate *item = [[NSDate dateWithTimeIntervalSinceNow:clockTime[activeTag]] dateByAddingTimeInterval:-1];
        localNotif.fireDate = item;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.alertBody = [NSString stringWithFormat:@"%@'s Time is Up!", timerName[activeTag]];
        localNotif.alertAction = @"View in App";
        //localNotif.userInfo = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:currentTimerName, self.savedAlarms, nil ]forKeys:[[NSArray alloc] initWithObjects:@"name", @"saveArray", nil ]];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [self.savedAlarms setObject:localNotif forKey:timerName[activeTag]];
        [self.savedReferences setObject:self.reference forKey:timerName[activeTag]];
    }
    else{
        self.timerRunning = NO;
        clockTime[activeTag] = plusTime[activeTag];
        self.reference = nil;
        [self displayTime:clockTime[activeTag] at:activeTag];
        [timerEditors[activeTag] setValue:[NSNumber numberWithBool:NO] forKey:@"hidden"];
        [[UIApplication sharedApplication] cancelLocalNotification:[self.savedAlarms objectForKey:timerName[activeTag]]];
        [self.savedAlarms removeObjectForKey:timerName[activeTag]];
    }
}

- (IBAction)resetPressed:(UIButton *)button {
    activeTag = button.tag;
    NSLog(@"Tag is %d", activeTag);
    
    if (!self.timerRunning){
        clockTime[activeTag] = totalTime[activeTag];
        [self displayTime:clockTime[activeTag] at:activeTag];
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
    for (int i=0; i<3; ++i) {
        if ([self.savedAlarms objectForKey:timerName[i]] != nil){
            NSTimeInterval time = [self.reference timeIntervalSinceNow];
            plusTime[i] = time + clockTime[i];
            if(lround(floor(plusTime[i])) <= 0){
                UIButton *completeTimer;
                completeTimer.tag = i;
                [self startButtonPressed:completeTimer];
                [self resetPressed:completeTimer];
            }
            [self displayTime:(time+clockTime[i]) at:i];
        }
        else{
            [self displayTime:clockTime[i] at:i];
        }
    }
}

- (void) displayTime:(NSTimeInterval)time at:(int)tag {
    NSString *currentTime = [NSString stringWithFormat:@"%02li:%02li:%02li",
                             lround(floor(time / 3600.)) % 100,
                             lround(floor(time / 60.)) % 60,
                             lround(floor(time)) % 60];
    [timers[tag] setTitle:currentTime forState:UIControlStateNormal];
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

- (void) showPicker{
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
