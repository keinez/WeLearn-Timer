//
//  Pocketsphinx.h
//  timerApp
//
//

#import <Foundation/Foundation.h>
#import <OpenEars/PocketsphinxController.h>


@interface Pocketsphinx : PocketsphinxController{
    NSString *lmStopwatchPath;
    NSString *dicStopwatchPath;
    NSString *lmTimerPath;
    NSString *dicTimerPath;
}

+ (id)sharedInstance;
- (void)startListeningFor:(NSString*)type;
- (void)changeModelTo:(NSString*)type;

@end
