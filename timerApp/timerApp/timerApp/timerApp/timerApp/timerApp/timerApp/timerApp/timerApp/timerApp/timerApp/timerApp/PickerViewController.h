//
//  PickerViewController.h
//  timerApp
//
//  Created by David Yuschak on 10/29/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController <UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
- (IBAction)donePressed:(id)sender;

@end
