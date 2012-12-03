//
//  EditViewController.m
//  timerApp
//
//  Created by David Yuschak on 11/30/12.
//  Copyright (c) 2012 David Yuschak. All rights reserved.
//

#import "EditViewController.h"

@implementation EditViewController{
   
}

@synthesize timePicker = _timePicker;
@synthesize timerName = _timerName;
@synthesize name = _name;

- (void)viewDidLoad {
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    self.timerName.delegate = self;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.timerName.text != nil) {
        self.name = self.timerName.text;
    }
    [textField resignFirstResponder];
    return YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    if (self.timerName.text != nil) {
        self.name = self.timerName.text;
    }
}
- (void)viewDidUnload {
    [self setTimePicker:nil];
    [self setTimerName:nil];
    [super viewDidUnload];
}
@end
