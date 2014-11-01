//
//  DetailItemsViewController.h
//  TestTable
//
//  Created by masaki on 2014/02/18.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import "ViewController.h"
#import "CMPopTipView.h"
@class Counter;
@interface DetailItemsViewController : ViewController <CMPopTipViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *limitLabel;
@property (weak, nonatomic) IBOutlet UIStepper *limitStepper;
@property (weak, nonatomic) IBOutlet UIStepper *countStepper;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UISwitch *resetSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *badgeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *currentColor;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *colorButtons;
@property (nonatomic, assign) NSInteger counterRow;
@property (weak, nonatomic) IBOutlet UIButton *textFieldButtonForTip;
@property (weak, nonatomic) IBOutlet UISegmentedControl *badgeSegment;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar2;
- (IBAction)test:(id)sender;
- (IBAction)resetSwitchChanged:(id)sender;
- (IBAction)titleFieldTouched:(id)sender;
- (IBAction)badgeSwitchChanged:(id)sender;
- (IBAction)badgeSegmentChanged:(id)sender;

- (IBAction)colorButton0:(id)sender;
- (IBAction)colorButton1:(id)sender;
- (IBAction)colorButton2:(id)sender;
- (IBAction)colorButton3:(id)sender;
- (IBAction)colorButton4:(id)sender;
- (IBAction)colorButton5:(id)sender;
- (IBAction)changeCountStepper:(id)sender;
- (IBAction)changeLimitStepper:(id)sender;
- (void)setItems:(Counter*)counter;
- (IBAction)saveAndQuit:(id)sender;
- (IBAction)reset:(id)sender;
@end
