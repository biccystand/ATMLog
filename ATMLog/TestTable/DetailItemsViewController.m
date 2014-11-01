//
//  DetailItemsViewController.m
//  TestTable
//
//  Created by masaki on 2014/02/18.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import "DetailItemsViewController.h"
#import "ViewController.h"
#import "PersistencyManager.h"
#import "Counter.h"
#import "ColorManager.h"
#import "config.h"
#import "Colours.h"
@interface DetailItemsViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*contents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong)	NSDictionary	*titles;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@end

@implementation DetailItemsViewController
{
    ViewController* _viewController;
    PersistencyManager *_counterManager;
    ColorManager *colorManager;
    Counter *_counter;
//    Counter *badgeCounter;
    BOOL badgeReset;
    NSInteger currentColorIndex;
    UIToolbar *_toolBar;
//    UIToolbar *_toolBar2;
    BOOL is35inch;
    BOOL isTipped;
    NSInteger isRemainingCountForBadge;
    CGRect toolBarFrame;
    NSUserDefaults *userDefaults;
//    int row;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    userDefaults = [NSUserDefaults standardUserDefaults];
    isTipped = [userDefaults integerForKey:@"tipped"];
    isRemainingCountForBadge = [userDefaults integerForKey:@"remainingCountForBadge"];
    NSLog(@"istipped: %d", isTipped);
    self.visiblePopTipViews = [NSMutableArray array];
	self.contents = [NSDictionary dictionaryWithObjectsAndKeys:
					 // Rounded rect buttons
					 @"改行・returnキーを押すか、\n他の場所をタップすると\nキーボードが消えます。", [NSNumber numberWithInt:0],
					 @"A CMPopTipView will automatically orient itself above or below the target view based on the available space.", [NSNumber numberWithInt:12],
					 @"A CMPopTipView always tries to point at the center of the target view.", [NSNumber numberWithInt:13],
					 @"A CMPopTipView can point to any UIView subclass.", [NSNumber numberWithInt:14],
					 @"A CMPopTipView will automatically size itself to fit the text message.", [NSNumber numberWithInt:15],
					 [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appicon57.png"]], [NSNumber numberWithInt:16],	// content can be a UIView
					 // Nav bar buttons
					 @"This CMPopTipView is pointing at a leftBarButtonItem of a navigationItem.", [NSNumber numberWithInt:21],
					 @"Two popup animations are provided: slide and pop. Tap other buttons to see them both.", [NSNumber numberWithInt:22],
					 // Toolbar buttons
					 @"CMPopTipView will automatically point at buttons either above or below the containing view.", [NSNumber numberWithInt:31],
					 @"The arrow is automatically positioned to point to the center of the target button.", [NSNumber numberWithInt:32],
					 @"CMPopTipView knows how to point automatically to UIBarButtonItems in both nav bars and tool bars.", [NSNumber numberWithInt:33],
					 nil];
	self.titles = [NSDictionary dictionaryWithObjectsAndKeys:
				   @"Title", [NSNumber numberWithInt:14],
				   @"Auto Orientation", [NSNumber numberWithInt:12],
				   nil];
	
	// Array of (backgroundColor, textColor) pairs.
	// NSNull for either means leave as default.
	// A color scheme will be picked randomly per CMPopTipView.
	self.colorSchemes = [NSArray arrayWithObjects:
						 [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
						 [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
						 [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
						 [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
						 [NSArray arrayWithObjects:[UIColor orangeColor], [UIColor blueColor], nil],
						 [NSArray arrayWithObjects:[UIColor colorWithRed:220.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], [NSNull null], nil],
						 nil];
    
//    _toolBar2 = [[UIToolbar alloc] init];
    toolBarFrame = _toolBar2.frame;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _toolBar2.hidden = YES;
    if(screenSize.width == 320.0 && screenSize.height == 568.0){
        is35inch = NO;
    }
    else
    {
        is35inch = YES;
    }
    is35inch = YES;
    _titleLabel.delegate = self;
    _viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    colorManager = [[ColorManager alloc] init];
    for (int i=0; i<_colorButtons.count; i++) {
        UIButton *button = (UIButton*)[_colorButtons objectAtIndex:i];
        [button setTitleColor:[colorManager.colorArray objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    
    [_currentColor setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
//    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
    [self.view addGestureRecognizer:recognizer];
    recognizer.cancelsTouchesInView = NO;
    
    CGRect stepperFrame =  _countStepper.frame;
    _countStepper.frame = CGRectMake(stepperFrame.origin.x, 110, stepperFrame.size.width, stepperFrame.size.height);
    _limitStepper.frame = CGRectMake(stepperFrame.origin.x, 153, stepperFrame.size.width, stepperFrame.size.height);
    
    if (!SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        for (UIView *view in self.view.subviews) {
            if (view.tag >200 && view.tag <230) {
                stepperFrame = view.frame;
                view.frame = CGRectMake(stepperFrame.origin.x, stepperFrame.origin.y + kStatusBarHeight, stepperFrame.size.width, stepperFrame.size.height);
            }
        }
    }

//    [self setToolBar];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(handleKeyboardWillShow:)
                   name:UIKeyboardWillShowNotification object:nil];
    
    [center addObserver:self selector:@selector(handleKeyboardWillHide:)
                   name:UIKeyboardWillHideNotification object:nil];

    _counterManager = [PersistencyManager sharedInstance];
    _counter = [_counterManager.counters objectAtIndex:self.counterRow];
    
    NSLog(@"row: %d", _counter.row);
    NSLog(@"counterRow: %d", self.counterRow);
    
    currentColorIndex = _counter.color;
    _resetSwitch.on = _counter.monthReset;
    _badgeSwitch.on = _counter.badge;
    _badgeSegment.hidden = !_badgeSwitch.on;
    _badgeSegment.selectedSegmentIndex = isRemainingCountForBadge;
    [self setItems:_counter];
    [_currentColor setTitleColor:[colorManager.colorArray objectAtIndex:_counter.color] forState:UIControlStateNormal];

    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"キャンセル" style:UIBarButtonItemStyleBordered target:self action:@selector(backToRootViewController:)];
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"元に戻す" style:UIBarButtonItemStyleBordered target:self action:@selector(resetButtonPushed:)];
    UIBarButtonItem *saveAndBackButton = [[UIBarButtonItem alloc] initWithTitle:@"保存して終了" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonPushed:)];
    [saveAndBackButton setTintColor:[UIColor redColor]];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    NSArray *items = [NSArray arrayWithObjects:backButton, flexibleSpace, resetButton, flexibleSpace, saveAndBackButton, nil];
//    NSArray *items2 = [NSArray arrayWithObjects:backButton, flexibleSpace, resetButton, flexibleSpace, saveAndBackButton, nil];
    [self.toolBar setItems:items];
    if (!is35inch) {
        [_toolBar2 setItems:items];
    }

    [super viewWillAppear:animated];
    
    if (!is35inch) {
        [_titleLabel becomeFirstResponder];
    }
//    [self.navigationController.toolbar setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)paramAnimated{
    [super viewWillDisappear:paramAnimated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    badgeReset = NO;
}

- (void)dismissAllPopTipViews
{
	while ([self.visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[self.visiblePopTipViews removeObjectAtIndex:0];
	}
}


- (IBAction)buttonAction:(id)sender
{
    if (isTipped) {
        return;
    }
//    if (!is35inch) {
//        return;
//    }
	[self dismissAllPopTipViews];
	
	if (sender == self.currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}
	else {
		NSString *contentMessage = nil;
		UIView *contentView = nil;
		NSNumber *key = [NSNumber numberWithInt:0];
		id content = [self.contents objectForKey:key];
		if ([content isKindOfClass:[UIView class]]) {
			contentView = content;
		}
		else if ([content isKindOfClass:[NSString class]]) {
			contentMessage = content;
		}
		else {
			contentMessage = @"A CMPopTipView can automatically point to any view or bar button item.";
		}
		NSArray *colorScheme = [self.colorSchemes objectAtIndex:3];
		UIColor *backgroundColor = [colorScheme objectAtIndex:0];
		UIColor *textColor = [colorScheme objectAtIndex:1];
		
		NSString *title = [self.titles objectForKey:key];
		
		CMPopTipView *popTipView;
		if (contentView) {
			popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
		}
		else if (title) {
			popTipView = [[CMPopTipView alloc] initWithTitle:title message:contentMessage];
		}
		else {
			popTipView = [[CMPopTipView alloc] initWithMessage:contentMessage];
		}
		popTipView.delegate = self;
		
		/* Some options to try.
		 */
		//popTipView.disableTapToDismiss = YES;
		//popTipView.preferredPointDirection = PointDirectionUp;
		//popTipView.hasGradientBackground = NO;
        //popTipView.cornerRadius = 2.0;
        //popTipView.sidePadding = 30.0f;
        //popTipView.topMargin = 20.0f;
        //popTipView.pointerSize = 50.0f;
		
		if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
			popTipView.backgroundColor = backgroundColor;
		}
		if (textColor && ![textColor isEqual:[NSNull null]]) {
			popTipView.textColor = textColor;
		}
        
        popTipView.animation = YES;
		popTipView.has3DStyle = YES;
		
		popTipView.dismissTapAnywhere = YES;
        [popTipView autoDismissAnimated:YES atTimeInterval:8.0];
        
		if ([sender isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)sender;
			[popTipView presentPointingAtView:button inView:self.view animated:YES];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
		}
		
		[self.visiblePopTipViews addObject:popTipView];
		self.currentPopTipViewTarget = sender;
	}
}


- (IBAction)onTapped:(id)sender
{
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)backToRootViewController:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
    isTipped = YES;
    [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"tipped"];
    NSLog(@"tipped: %d", [userDefaults boolForKey:@"tipped"]);
}

- (IBAction)resetButtonPushed:(id)sender
{
    [self reset:sender];
    isTipped = YES;
    [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"tipped"];
    NSLog(@"tipped: %d", [userDefaults boolForKey:@"tipped"]);
}

- (IBAction)saveButtonPushed:(id)sender
{
    [self saveAndQuit:sender];
    [self.navigationController popToRootViewControllerAnimated:YES];
    isTipped = YES;
    [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"tipped"];
    NSLog(@"tipped: %d", [userDefaults boolForKey:@"tipped"]);
}

//- (void)setToolBar
//{
//    CGFloat toolBarY;
//    CGFloat nadViewY;
//    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
//        //        navBarHeight = kToolBarHeight;
//        toolBarY = kScreenHeight - kToolBarHeight - kAdbarHeight - 20;
//        nadViewY = kScreenHeight - kAdbarHeight - 20;
//    }
//    else
//    {
//        //        navBarHeight = kToolBarHeight + kStatusBarHeight;
//        toolBarY = kScreenHeight - kToolBarHeight - kAdbarHeight;
//        nadViewY = kScreenHeight - kAdbarHeight;
//    }
//    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, toolBarY, kScreenWidth, kToolBarHeight)];
////    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"title" style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonPushed:)];
////    UIBarButtonItem *insertButton = [[UIBarButtonItem alloc] initWithTitle:@"Insert" style:UIBarButtonItemStyleBordered target:self action:@selector(insertButtonPushed:)];
////    NSArray *items = [NSArray arrayWithObjects:button, insertButton, nil];
////    [_toolBar setItems:items];
//    [self.view addSubview:_toolBar];
//    //    _nadView = [[NADView alloc] initWithFrame:CGRectMake(0, nadViewY, kScreenWidth, kAdbarHeight)];
//    
//}


- (IBAction)test:(id)sender {
    NSLog(@"stets");
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)resetSwitchChanged:(id)sender {
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)titleFieldTouched:(id)sender {
    [self buttonAction:_textFieldButtonForTip];
}

- (IBAction)badgeSwitchChanged:(id)sender {
    Counter *badgeCounter;
    if (_badgeSwitch.on) {
        for (Counter *counter in _counterManager.counters) {
            if (counter.badge) {
                badgeCounter = counter;
                break;
            }
        }
        if (badgeCounter && badgeCounter != _counter) {
            NSString *message = [NSString stringWithFormat:@"%@を解除して%@をバッジにしますか？\n（変更は「保存して終了」ボタンを押したときに反映されます。）", badgeCounter.title, _counter.title];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"アイコンバッジ（数値）の設定" message:message delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    _badgeSegment.hidden = !_badgeSwitch.on;
}

- (IBAction)badgeSegmentChanged:(id)sender {
    isRemainingCountForBadge = _badgeSegment.selectedSegmentIndex;
}

- (IBAction)colorButton0:(id)sender {
    [_currentColor setTitleColor:[colorManager.colorArray objectAtIndex:0] forState:UIControlStateNormal];
    currentColorIndex = 0;
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)colorButton1:(id)sender {
    [_currentColor setTitleColor:[colorManager.colorArray objectAtIndex:1] forState:UIControlStateNormal];
    currentColorIndex = 1;
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)colorButton2:(id)sender {
    [_currentColor setTitleColor:[colorManager.colorArray objectAtIndex:2] forState:UIControlStateNormal];
    currentColorIndex = 2;
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)colorButton3:(id)sender {
    [_currentColor setTitleColor:[colorManager.colorArray objectAtIndex:3] forState:UIControlStateNormal];
    currentColorIndex = 3;
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)colorButton4:(id)sender {
    [_currentColor setTitleColor:[colorManager.colorArray objectAtIndex:4] forState:UIControlStateNormal];
    currentColorIndex = 4;
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)colorButton5:(id)sender {
    [_currentColor setTitleColor:[colorManager.colorArray objectAtIndex:5] forState:UIControlStateNormal];
    currentColorIndex = 5;
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)changeCountStepper:(id)sender {
    _countLabel.text = [NSString stringWithFormat:@"%d", (int)_countStepper.value];
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (IBAction)changeLimitStepper:(id)sender {
    _limitLabel.text = [NSString stringWithFormat:@"%d", (int)_limitStepper.value];
//    [_titleLabel resignFirstResponder];
    if (is35inch) {
        [_titleLabel resignFirstResponder];
    }
}

- (void)setItems:(Counter*)counter
{
    NSLog(@"counter: %@", counter.title);
    _countStepper.minimumValue = 0;
    _limitStepper.minimumValue = 0;
    _countStepper.maximumValue = NSIntegerMax;
    _limitStepper.maximumValue = NSIntegerMax;
    _countStepper.value = counter.count;
    _limitStepper.value = counter.limit;

    _titleLabel.text = counter.title;
    _countLabel.text = [NSString stringWithFormat:@"%d", counter.count];
    _limitLabel.text = [NSString stringWithFormat:@"%d", counter.limit];
}

- (IBAction)saveAndQuit:(id)sender {
    Counter *counter = [_counterManager.counters objectAtIndex:_counter.row];
    counter.count = _countStepper.value;
    counter.limit = _limitStepper.value;
    counter.title = _titleLabel.text;
    counter.color = currentColorIndex;
    counter.monthReset = _resetSwitch.on;
    if (_badgeSwitch.on) {
        [_counterManager badge:counter usingRemaining:_badgeSegment.selectedSegmentIndex];
        if (!counter.badge) {
            [_counterManager updateCountersToBadgeZero];
        }
    }
    else {
//        [_counterManager updateCountersToBadgeZero];
        [_counterManager badgeReset];
    }
    counter.badge = _badgeSwitch.on;
    [_counterManager updateCounter:counter];
    _viewController.updatedRow = counter.row;
    
    [userDefaults setInteger:_badgeSegment.selectedSegmentIndex forKey:@"remainingCountForBadge"];
}

- (IBAction)reset:(id)sender {
    _viewController.updatedRow = -1;
    currentColorIndex = _counter.color;
    _resetSwitch.on = _counter.monthReset;
    _badgeSwitch.on = _counter.badge;
    _badgeSegment.hidden = !_badgeSwitch.on;
    _badgeSegment.selectedSegmentIndex = [userDefaults integerForKey:@"remainingCountForBadge"];
    [self setItems:_counter];
    [_currentColor setTitleColor:[colorManager.colorArray objectAtIndex:_counter.color] forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            _badgeSwitch.on = NO;
            break;
        case 1:
            break;
        default:
            break;
    }
}

#pragma mark - UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField resignFirstResponder];
    if (is35inch) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - keyboard showorHide
- (void) handleKeyboardWillShow:(NSNotification *)paramNotification{
    if (is35inch) {
        return;
    }

    NSDictionary *userInfo = paramNotification.userInfo;
    
    /* Get the duration of the animation of the keyboard for when it
     gets displayed on the screen. We will animate our contents using
     the same animation duration */
    NSValue *animationDurationObject =
    userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    NSValue *keyboardEndRectObject = userInfo[UIKeyboardFrameEndUserInfoKey];
    
    double animationDuration = 0.0;
    CGRect keyboardEndRect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    /* Convert the frame from window's coordinate system to
     our view's coordinate system */
    keyboardEndRect = [self.view convertRect:keyboardEndRect
                                    fromView:window];
    
    /* Find out how much of our view is being covered by the keyboard */
    CGRect intersectionOfKeyboardRectAndWindowRect =
    CGRectIntersection(self.view.frame, keyboardEndRect);
    
    /* Scroll the scroll view up to show the full contents of our view */
    _toolBar2.hidden = NO;
    [UIView animateWithDuration:animationDuration animations:^{
        
//        _toolBar2.frame = CGRectMake(toolBarFrame.origin.x, 20, toolBarFrame.size.width, toolBarFrame.size.height);
        _toolBar2.frame = CGRectMake(toolBarFrame.origin.x, toolBarFrame.origin.y - intersectionOfKeyboardRectAndWindowRect.size.height, toolBarFrame.size.width, toolBarFrame.size.height);
//        self.scrollView.contentInset =
//        UIEdgeInsetsMake(0.0f,
//                         0.0f,
//                         intersectionOfKeyboardRectAndWindowRect.size.height,
//                         0.0f);
//        
//        [self.scrollView scrollRectToVisible:self.textField.frame animated:NO];
        
    }];
    
}

- (void) handleKeyboardWillHide:(NSNotification *)paramSender{
    
    if (is35inch) {
        return;
    }
    NSDictionary *userInfo = [paramSender userInfo];
    
    NSValue *animationDurationObject =
    [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    double animationDuration = 0.0;
    
    [animationDurationObject getValue:&animationDuration];
    _toolBar2.hidden = YES;
    [UIView animateWithDuration:animationDuration animations:^{
//        self.scrollView.contentInset = UIEdgeInsetsZero;
        _toolBar2.frame = toolBarFrame;
    }];
    
}
#pragma mark - CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
	[self.visiblePopTipViews removeObject:popTipView];
	self.currentPopTipViewTarget = nil;
}

@end
