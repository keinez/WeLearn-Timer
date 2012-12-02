//
//  Constants.m
//  timerApp
//
//

#import "Constants.h"
#import <OpenEars/LanguageModelGenerator.h>


@implementation Pocketsphinx

static Pocketsphinx *pocketsphinx = nil;

// Get the shared instance and create it if necessary.
+ (Pocketsphinx *)sharedInstance {
    if (pocketsphinx == nil) {
        NSLog(@"new pocketsphinx instance");
        pocketsphinx = [[super allocWithZone:NULL] init];
        pocketsphinx.secondsOfSilenceToDetect = 0.1;
    }
    
    return pocketsphinx;
}


+ (void)startListeningFor:(NSString*)type{
    if ([type isEqualToString:@"Stopwatch"]) {
        [pocketsphinx startListeningWithLanguageModelAtPath:lmStopwatchPath dictionaryAtPath:dicStopwatchPath languageModelIsJSGF:FALSE];
    }
    else if([type isEqualToString:@"Timer"]){
        [pocketsphinx startListeningWithLanguageModelAtPath:lmTimerPath dictionaryAtPath:dicTimerPath languageModelIsJSGF:FALSE];
    }
}

+ (void)changeModelTo:(NSString*)type{
    if ([type isEqualToString:@"Stopwatch"]) {
        [pocketsphinx changeLanguageModelToFile:lmStopwatchPath withDictionary:dicStopwatchPath];
    }
    else if([type isEqualToString:@"Timer"]){
        [pocketsphinx changeLanguageModelToFile:lmTimerPath withDictionary:dicTimerPath];
    }
}


@end






void createLanguageModel(){
    NSLog(@"initiate");
    
    // Voice command list for stopwatch
    NSArray *stopwatchArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects: // All capital letters.
                                                             @"GO",
                                                             @"START",
                                                             @"STOP",
                                                             @"SAVE",
                                                             @"RESET",
                                                             nil]];
    
    // Voice command list for timer
    NSArray *timerArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects: // All capital letters.
                                                              @"GO",
                                                              @"START",
                                                              @"STOP",
                                                              @"SAVE",
                                                              @"RESET",
                                                              nil]];
    
    
    LanguageModelGenerator *stopwatchModelGenerator = [[LanguageModelGenerator alloc] init];
    LanguageModelGenerator *timerModelGenerator = [[LanguageModelGenerator alloc] init];
    
    // generateLanguageModelFromArray:withFilesNamed returns an NSError which will either have a value of noErr if everything went fine or a specific error if it didn't.
    NSError *stopwatchError = [stopwatchModelGenerator generateLanguageModelFromArray:stopwatchArray withFilesNamed:@"stopwatchModel"];
    NSError *timerError = [timerModelGenerator generateLanguageModelFromArray:timerArray withFilesNamed:@"stopwatchModel"];
    
    NSDictionary *stopwatchGeneratorResults = nil;
    NSDictionary *timerGeneratorResults = nil;
    
    if([stopwatchError code] == noErr && ([timerError code] == noErr)) {
        
        stopwatchGeneratorResults = [stopwatchError userInfo];
        timerGeneratorResults = [timerError userInfo];
        
        
        lmStopwatchPath = [stopwatchGeneratorResults objectForKey:@"LMPath"];
        dicStopwatchPath = [stopwatchGeneratorResults objectForKey:@"DictionaryPath"];
        NSLog(@"Grammar path - %@", lmStopwatchPath);
        NSLog(@"Dictionary path - %@", dicStopwatchPath);
        
        
        lmTimerPath = [timerGeneratorResults objectForKey:@"LMPath"];
        dicTimerPath = [timerGeneratorResults objectForKey:@"DictionaryPath"];
        NSLog(@"Grammar path - %@", lmTimerPath);
        NSLog(@"Dictionary path - %@", dicTimerPath);
        
    } else {
        NSLog(@"++++++++++");
        NSLog(@"Error: %@",[stopwatchError localizedDescription]);
        NSLog(@"----------");
        NSLog(@"Error: %@",[timerError localizedDescription]);
        NSLog(@"++++++++++");
    }
}

