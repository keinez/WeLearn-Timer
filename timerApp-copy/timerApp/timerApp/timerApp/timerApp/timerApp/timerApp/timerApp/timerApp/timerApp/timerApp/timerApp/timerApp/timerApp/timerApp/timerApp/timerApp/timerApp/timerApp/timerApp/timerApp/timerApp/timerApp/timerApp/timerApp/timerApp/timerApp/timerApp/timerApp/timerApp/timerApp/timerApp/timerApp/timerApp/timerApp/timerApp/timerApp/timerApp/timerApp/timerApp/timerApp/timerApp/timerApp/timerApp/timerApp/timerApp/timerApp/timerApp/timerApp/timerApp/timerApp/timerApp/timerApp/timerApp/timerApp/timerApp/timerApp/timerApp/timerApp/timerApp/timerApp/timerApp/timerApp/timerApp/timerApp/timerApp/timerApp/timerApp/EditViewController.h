//
//  EditViewController.h
//  timerApp
//
//  Created by David Yuschak on 11/30/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *timePicker;
@property (strong, nonatomic) IBOutlet UITextField *timerName;
@property (strong, nonatomic)  NSString *name;

@end
