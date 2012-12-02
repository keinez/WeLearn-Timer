//
//  Constants.h
//  timerApp
//
//

#import <Foundation/Foundation.h>
#import <OpenEars/PocketsphinxController.h>


@interface Pocketsphinx : PocketsphinxController

+ (id)sharedInstance;
+ (void)startListeningFor:(NSString*)type;
+ (void)changeModelTo:(NSString*)type;


@end


NSString *lmStopwatchPath;
NSString *dicStopwatchPath;
NSString *lmTimerPath;
NSString *dicTimerPath;

void createLanguageModel();
