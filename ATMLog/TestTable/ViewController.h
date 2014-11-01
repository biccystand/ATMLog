//
//  ViewController.h
//  TestTable
//
//  Created by masaki on 2014/02/10.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"
#import "NADView.h"

@interface ViewController : UIViewController <NADViewDelegate, CMPopTipViewDelegate>
@property (nonatomic, assign)NSInteger updatedRow;
@property (nonatomic, strong)UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingLael;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@end
