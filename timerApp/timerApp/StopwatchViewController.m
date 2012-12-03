//
//  StopwatchViewController.m
//  timerApp
//
//  Created by David Yuschak on 10/28/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "StopwatchViewController.h"
#import "SettingsViewController.h"
#import "TimerViewController.h"

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
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    if (self.timerRunning){
        if([hypothesis isEqualToString:@"STOP"] || [hypothesis isEqualToString:@"END"]) {
            // stop clock
            [self startButtonPressed:nil];
            return;
        }
        if([hypothesis isEqualToString:@"SAVE"] || [hypothesis isEqualToString:@"SPLIT"]) {
            // save lap time
            [self resetPressed:nil];
            return;
        }
    }
    else {
        if([hypothesis isEqualToString:@"START"] || [hypothesis isEqualToString:@"GO"]) {
            // start clock
            [self startButtonPressed:nil];
            return;
        }
        if([hypothesis isEqualToString:@"RESET"] && !self.lapButton.isHidden && [self.lapButton.titleLabel.text isEqualToString:@"Reset"]) {
            // reset clock
            [self resetPressed:nil];
            return;
        }
    }
    
}



#pragma mark -
#pragma mark view

-(void)viewDidLoad{
    self.table.dataSource = self;
    self.laps = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)viewDidAppear:(BOOL)animated {
    NSInteger vc = [[NSUserDefaults standardUserDefaults] integerForKey:@"voiceControl"];
    if (vc) {
        [self.openEarsEventsObserver setDelegate:self];
        [[Pocketsphinx sharedInstance] changeModelTo:@"Stopwatch"];
    }
    
    [self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.openEarsEventsObserver setDelegate:nil];
    [self becomeFirstResponder];
}


- (void)viewDidUnload {
    [self setClockButton:nil];
    [self setTable:nil];
    [self setLapButton:nil];
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

- (IBAction)startButtonPressed:(id)sender {
    NSLog(@"start / stop ?");
    
    if (!self.timerRunning){
        self.timerRunning = YES;
        [self.lapButton setTitle:@"Split" forState:UIControlStateNormal];
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

- (IBAction)helpPressed:(id)sender {
    NSString *imgFilepath = [[NSBundle mainBundle] pathForResource:@"StopwatchHelpNRD" ofType:@"png"];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:imgFilepath];
    UIImageView *helpView = [[UIImageView alloc] initWithImage:img];
    helpView.userInteractionEnabled = YES;
    [helpView setTag:99];
    
    [self.view addSubview:helpView];
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [helpView addGestureRecognizer:tap];
}

-(void)imageTapped:(id)sender {
    for (UIView *subView in self.view.subviews)
    {
        if (subView.tag == 99)
        {
            [subView removeFromSuperview];
        }
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


#pragma mark -
#pragma mark Table View Delegate Methods

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
@end
