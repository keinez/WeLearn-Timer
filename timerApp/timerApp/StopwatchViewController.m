//
//  StopwatchViewController.m
//  timerApp
//
//  Created by David Yuschak on 10/28/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "StopwatchViewController.h"
#import <OpenEars/LanguageModelGenerator.h>

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


@synthesize openEarsEventsObserver;
@synthesize pocketsphinxController;
@synthesize lmPath = _lmPath;
@synthesize dicPath = _dicPath;


#pragma mark -
#pragma mark OpenEars

// Lazily allocated PocketsphinxController.
- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}


// Lazily allocated OpenEarsEventsObserver.
- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (void) startListening {
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.lmPath dictionaryAtPath:self.dicPath languageModelIsJSGF:FALSE];
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    
    if([hypothesis isEqualToString:@"START"] || [hypothesis isEqualToString:@"GO"]) {
        // start clock
        //[self startButtonPressed:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"starting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    else if([hypothesis isEqualToString:@"STOP"]) {
        // stop clock
        //[self startButtonPressed:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"stopping!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
}



#pragma mark -
#pragma mark view

-(void)viewDidLoad{
    self.table.dataSource = self;
    self.navBar.delegate = self;
    self.laps = [[NSMutableArray alloc] initWithCapacity:0];
    
	[self.openEarsEventsObserver setDelegate:self]; // Make this class the delegate of OpenEarsObserver so we can get all of the messages about what OpenEars is doing.
    
    
	NSArray *languageArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects: // All capital letters.
                                                             @"GO",
                                                             @"START",
                                                             @"STOP",
                                                             @"ONE",
                                                             @"TWO",
                                                             nil]];
    
    
	LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init];
    
    // generateLanguageModelFromArray:withFilesNamed returns an NSError which will either have a value of noErr if everything went fine or a specific error if it didn't.
	NSError *error = [languageModelGenerator generateLanguageModelFromArray:languageArray withFilesNamed:@"voiceAction"];
    
    NSDictionary *languageGeneratorResults = nil;
    
    if([error code] == noErr) {
        
        languageGeneratorResults = [error userInfo];
		
        self.lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        self.dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		NSLog(@"Grammar path - %@", self.lmPath);
        NSLog(@"Dictionary path - %@", self.dicPath);
        
    } else {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    
    [self startListening];
}


- (IBAction)startButtonPressed:(id)sender {
    NSLog(@"start / stop ?");
    
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
