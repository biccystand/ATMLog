//
//  ViewController.m
//  TestTable
//
//  Created by masaki on 2014/02/10.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import "ViewController.h"
//#import "DetailViewController.h"
#import "DetailItemsViewController.h"
#import "Counter.h"
//#import "CounterManager.h"
#import "PersistencyManager.h"
#import "DateManager.h"
#import "Colours.h"
#import "ColorManager.h"
#import "config.h"
#define kNumberOfBanks 4
#define kEditButtonLabel @"削除・並び替え"
#define kUnEditButtonLabel @"編集解除　　　"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    PersistencyManager *_counterManager;
//    UIToolbar *_toolBar;
    BOOL isEditing;
    BOOL unReloadTable;
    DetailItemsViewController *_detailItemsViewController;
    NADView *_nadView;
    NSInteger editDone;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) DetailViewController *detailViewController;
//@property (weak, nonatomic) DetailItemsViewController *detailItemsViewController;
@property (weak, nonatomic) DateManager *dateManager;
@property (nonatomic, assign) NSInteger yearAndMonth;
@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*contents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong)	NSDictionary	*titles;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@end

@implementation ViewController
{
    NSUserDefaults *userDefaults;
}

- (void)broughtToBackground:(id)sender
{
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _dateManager = [DateManager sharedInstance];
//    [_dateManager badgeReset];
    self.visiblePopTipViews = [NSMutableArray array];
	self.contents = [NSDictionary dictionaryWithObjectsAndKeys:
					 // Rounded rect buttons
					 @"パネルをタップするとカウントを1増やします。\n長押しすると詳細設定できます。", [NSNumber numberWithInt:0],
					 @"左端の⊝から削除できます\n右端の≣で上下に移動できます", [NSNumber numberWithInt:1],
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
				   @"使い方", [NSNumber numberWithInt:0],
				   @"削除・並び替え", [NSNumber numberWithInt:1],
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
    
    self.navigationController.navigationBarHidden = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //            _detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
    _detailItemsViewController = [storyboard instantiateViewControllerWithIdentifier:@"detailItemsViewController"];

    _updatedRow = -1;
    userDefaults = [NSUserDefaults standardUserDefaults];
    editDone = [userDefaults integerForKey:@"editDone"];
    UIApplication *application = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomActive) name:UIApplicationDidBecomeActiveNotification object:application];
    
    isEditing = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor icebergColor];
    _counterManager = [PersistencyManager sharedInstance];
//    _dateManager = [DateManager sharedInstance];
//    _yearAndMonth = [_dateManager yearAndMonth];
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSInteger _previousYearAndMonth = [userDefaults integerForKey:@"date"];
//    if (_yearAndMonth != _previousYearAndMonth) {
    [self updateCount];
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(broughtToBackground:)
//                                                 name:UIApplicationWillTerminateNotification
//                                               object:nil];
//
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateCount) userInfo:nil repeats:YES];
//    [_tableView setEditing:YES];
    
//    [self.navigationController setToolbarHidden:NO];
    [self setToolBar];
    [self.view addSubview:_nadView];
    [self setFrameViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    for (UIView *view in self.view.subviews) {
        if (view.tag == 101) {
            [view removeFromSuperview];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
//    _counterManager = [PersistencyManager sharedInstance];
//    for (Counter *counter in _counterManager.counters) {
//        if (counter.badge) {
//            [UIApplication sharedApplication].applicationIconBadgeNumber = counter.count;
//        }
//    }
    [super viewWillAppear:animated];
    [self updateCount];
    [self.view addSubview:_toolBar];
    NSLog(@"updatedRow: %d", _updatedRow);
    if (_updatedRow == -1) {
        return;
    }
    else
    {
        [_tableView reloadData];
    }
}

- (void)becomActive
{
    [self updateCount];
}

- (void)setFrameViews
{
    CGRect tableViewFrame = _tableView.frame;
    float tableBottomGap = _toolBar.frame.origin.y - tableViewFrame.size.height - tableViewFrame.origin.y;
//    _tableView.frame = CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y, tableViewFrame.size.width, tableViewFrame.size.height + tableBottomGap + 400);
    _tableView.frame = CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y, tableViewFrame.size.width, tableViewFrame.size.height + tableBottomGap);
    if (!SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGRect dateViewFrame = _dateView.frame;
        _dateView.frame = CGRectMake(dateViewFrame.origin.x, dateViewFrame.origin.y+kStatusBarHeight, dateViewFrame.size.width, dateViewFrame.size.height);
    }
}

- (void)setToolBar
{
    CGFloat toolBarY;
    CGFloat nadViewY;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        //        navBarHeight = kToolBarHeight;
        toolBarY = kScreenHeight - kToolBarHeight - kAdbarHeight - 20;
        nadViewY = kScreenHeight - kAdbarHeight - 20;
    }
    else
    {
        //        navBarHeight = kToolBarHeight + kStatusBarHeight;
        toolBarY = kScreenHeight - kToolBarHeight - kAdbarHeight;
        nadViewY = kScreenHeight - kAdbarHeight;
    }
    
    _nadView = [[NADView alloc] initWithFrame:CGRectMake(0, nadViewY, kScreenWidth, kAdbarHeight)];
    [_nadView setIsOutputLog:NO];
    [_nadView setNendID:kNendID spotID:kSpotID];
    [_nadView setDelegate:self];
    [_nadView load];

    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, toolBarY, kScreenWidth, kToolBarHeight)];
    _toolBar.tag = 101;
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"削除・並び替え" style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonPushed:)];
    UIBarButtonItem *howtoButton = [[UIBarButtonItem alloc] initWithTitle:@"使い方" style:UIBarButtonItemStyleBordered target:self action:@selector(howtoButtonPushed:)];
    UIBarButtonItem *insertButton = [[UIBarButtonItem alloc] initWithTitle:@"新規" style:UIBarButtonItemStyleBordered target:self action:@selector(insertButtonPushed:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    NSArray *items = [NSArray arrayWithObjects:button, flexibleSpace, insertButton, flexibleSpace, howtoButton, nil];
    [_toolBar setItems:items];
//    _nadView = [[NADView alloc] initWithFrame:CGRectMake(0, nadViewY, kScreenWidth, kAdbarHeight)];

}

- (void)changeEditButtonTitle
{
    NSMutableArray *toolBarMutableItems = [_toolBar.items mutableCopy];
    UIBarButtonItem* deleteButton = [toolBarMutableItems objectAtIndex:0];
    if (isEditing) {
        deleteButton.title = kUnEditButtonLabel;
    } else
    {
        deleteButton.title = kEditButtonLabel;
    }
}

- (void)insertButtonPushed:(id)sender
{
    for (Counter *oldCounter in _counterManager.counters) {
        oldCounter.row++;
    }
    Counter *counter = [[Counter alloc] initWithTitle:@"新規" count:0 limit:0 monthReset:YES color:0 badge:0];
    [_counterManager.counters insertObject:counter atIndex:0];
    NSIndexPath *indexPathOfNewItem = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPathOfNewItem] withRowAnimation:UITableViewRowAnimationLeft];
    [_counterManager addCounterToDatabase:counter];

    //    [self flashTheNewestCell];
//    [self.mainViewController reloadButtonStatus];

}

- (void)barButtonPushed:(id)sender
{
    isEditing =! isEditing;
    [_tableView setEditing:isEditing animated:YES];
    [self changeEditButtonTitle];
    
    [self dismissAllPopTipViews];
	
    if (editDone > 1) {
        return;
    }
    if (!isEditing) {
        return;
    }
    editDone++;
    [userDefaults setInteger:editDone forKey:@"editDone"];
	if (sender == self.currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}
	else {
		NSString *contentMessage = nil;
		UIView *contentView = nil;
		NSNumber *key = [NSNumber numberWithInt:1];
		id content = [self.contents objectForKey:key];
		if ([content isKindOfClass:[UIView class]]) {
			contentView = content;
		}
		else if ([content isKindOfClass:[NSString class]]) {
			contentMessage = content;
		}
		else {
			contentMessage = @"なんかエラーです (>_<)";
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
		popTipView.has3DStyle = NO;
		
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

    
//    [self setEditing:YES];
//    if (!isEditing) {
//        [_tableView setEditing:NO];
//        [_tableView reloadData];
//        [_tableView setEditing:YES];
//    }
//    isEditing = !isEditing;
}

- (void)howtoButtonPushed:(id)sender
{
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
			contentMessage = @"なんかエラーです (>_<)";
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
		popTipView.has3DStyle = NO;
		
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

- (void)dismissAllPopTipViews
{
	while ([self.visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[self.visiblePopTipViews removeObjectAtIndex:0];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Timer
- (void)updateCount {
    NSInteger _previousYearAndMonth = [userDefaults integerForKey:@"yearAndMonth"];
    NSInteger yearAndMonth = [_dateManager yearAndMonth];
    NSLog(@"updated: %d", yearAndMonth);
    NSLog(@"updated: %d", _previousYearAndMonth);
    
    NSArray *dateArray = [_dateManager dayAndMonth];
    NSInteger dayInt = [[dateArray objectAtIndex:0] integerValue];
    NSInteger monthInt = [[dateArray objectAtIndex:1] integerValue];
    _dayLabel.text = [NSString stringWithFormat:@"%d", dayInt];
    _monthLabel.text = [NSString stringWithFormat:@"%d", monthInt];
    
    NSInteger maxDay = [_dateManager daysOfThisMonth];
    _remainingLael.text = [NSString stringWithFormat:@"%d", maxDay - dayInt];
//    if (_dayLabel.text != dayInt) {
//        _dayLabel.text = dayInt;
//    }
    
    
    if (yearAndMonth != _previousYearAndMonth) {
//        _yearAndMonth = yearAndMonth;
        [userDefaults setInteger:yearAndMonth forKey:@"yearAndMonth"];
        [_counterManager resetCount];
        [_tableView reloadData];
//        NSLog(@"updatedreloaded");
    }
    
    _counterManager = [PersistencyManager sharedInstance];
    for (Counter *counter in _counterManager.counters) {
        if (counter.badge) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = counter.displayCount;
        }
    }

}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _counterManager.counters.count;
}

-(void)tableView:(UITableView *)tableView
willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Counter *counter = [_counterManager.counters objectAtIndex:indexPath.row];
    ColorManager *colorManager = [[ColorManager alloc] init];
//    UIColor *cellColor;
//    NSLog(@"color: %d", counter.color);
//    switch (counter.color) {
//        case 0:
//            cellColor = [UIColor grayColor];
//            break;
//        case 1:
//            cellColor = ColorInfoBlue;
//            break;
//        case 2:
//            cellColor = ColorSuccess;
//            break;
//        case 3:
//            cellColor = ColorWarning;
//            break;
//        case 4:
//            cellColor = ColorDanger;
//            break;
//            
//        default:
//            break;
//    }
    cell.backgroundColor = [colorManager.colorArray objectAtIndex:counter.color];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (unReloadTable) {
        
    }
    Counter *counter = [_counterManager.counters objectAtIndex:indexPath.row];
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"cell: %@", cell);
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *limitLabel = (UILabel *)[cell viewWithTag:4];
    UILabel *badgeLabel = (UILabel *)[cell viewWithTag:6];
    
    label.adjustsFontSizeToFitWidth      = YES;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    limitLabel.adjustsFontSizeToFitWidth = YES;
    badgeLabel.adjustsFontSizeToFitWidth = YES;

    NSLog(@"label: %@", label.text);
    UIButton *button = (UIButton *)[cell viewWithTag:2];
    button.tag = indexPath.row + 100;
    [button addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedHandler:)];
    [button addGestureRecognizer:gestureRecognizer];

    label.text = [NSString stringWithFormat:@"%d", counter.count];
    titleLabel.text = counter.title;
    limitLabel.text = [NSString stringWithFormat:@"%d", counter.limit];
    if (counter.badge) {
        if ([userDefaults integerForKey:@"remainingCountForBadge"]) {
            badgeLabel.text = @"アイコンに残り回数を表示";
        }
        else {
            badgeLabel.text = @"アイコンにカウント数を表示";
        }
    }
    else
    {
        badgeLabel.text = @"";
    }
//    UIColor *cellColor;
//    NSLog(@"color: %d", counter.color);
//    switch (counter.color) {
//        case 0:
//            cellColor = [UIColor grayColor];
//            break;
//        case 1:
//            cellColor = ColorInfoBlue;
//            break;
//        case 2:
//            cellColor = ColorSuccess;
//            break;
//        case 3:
//            cellColor = ColorWarning;
//            break;
//        case 4:
//            cellColor = ColorDanger;
//            break;
//            
//        default:
//            break;
//    }
//    cell.backgroundColor = cellColor;
    label.textColor = [UIColor whiteColor];
    titleLabel.textColor = [UIColor whiteColor];
    limitLabel.textColor = [UIColor whiteColor];
    badgeLabel.textColor = [UIColor whiteColor];

    unReloadTable = NO;
    return cell;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return nil;
//}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
//    NSLog(@"move: %d, %d", sourceIndexPath.row, destinationIndexPath.row);
//    NSLog(@"count: %d", [self tableView:_tableView numberOfRowsInSection:0]);
    Counter *counter = [_counterManager.counters objectAtIndex:sourceIndexPath.row];
    [_counterManager.counters removeObjectAtIndex:sourceIndexPath.row];
    [_counterManager.counters insertObject:counter atIndex:destinationIndexPath.row];
    
    [_counterManager updateCounterIds];

    for (int i=0; i<[self tableView:_tableView numberOfRowsInSection:0]; i++) {
        unReloadTable = YES;
        UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:3];

        NSLog(@"title: %@", titleLabel.text);
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
//    if (!isEditing) {
//        return UITableViewCellEditingStyleNone;
//    }
//    else
//    {
//        return UITableViewCellEditingStyleDelete;
//    }
}
- (BOOL)tableView:(UITableView *)tableView
shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
//    if (!isEditing) {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index: %d", indexPath.row);
    unReloadTable = YES;
    UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:3];

    NSLog(@"title: %@", titleLabel.text);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Counter *counterToDel = [_counterManager.counters objectAtIndex:indexPath.row];
        if (counterToDel.badge) {
//            int counterId = counterToDel.counterId;
            [_counterManager badgeReset];
            for (Counter *counter in _counterManager.counters) {
                if (counter.badge) {
                    NSLog(@"bad: %@", counter.title);
                }
            }
        }
        [_counterManager.counters removeObjectAtIndex:indexPath.row]; // 削除ボタンが押された行のデータを配列から削除します。
        for (Counter *remainingCounter in _counterManager.counters) {
            if (remainingCounter.row > indexPath.row) {
                remainingCounter.row--;
            }
        }
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_counterManager removeCounterOfDatabaseAtRow:indexPath.row];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // ここは空のままでOKです。
    }
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *sectionView = [[UIView alloc] init];
//    sectionView.backgroundColor = [UIColor clearColor];
//    sectionView.frame = CGRectMake(0.0f, 0.0f, kScreenWidth, 0.0f);
//    // UIView にラベルを追加する。
//    return sectionView;
//}
#pragma mark -
- (IBAction)longPressedHandler:(UILongPressGestureRecognizer*)gestureRecognizer
{
    NSLog(@"navcs: %@", self.navigationController.viewControllers);
    NSLog(@"view: %@", _detailItemsViewController);
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan://長押しを検知開始
        {
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
////            _detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
//            _detailItemsViewController = [storyboard instantiateViewControllerWithIdentifier:@"detailItemsViewController"];
            UIButton *button = (UIButton*)gestureRecognizer.view;
            UITableViewCell *cell;
            if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
                NSLog(@"parent: %@", [button superview].superview);
                cell = (UITableViewCell*)(button.superview.superview);
            }
            else
            {
                NSLog(@"parent: %@", [button superview].superview.superview);
                cell = (UITableViewCell*)(button.superview.superview.superview);
            }
            
            NSLog(@"parent: %@", [button superview].superview.superview);
            int row = [_tableView indexPathForCell:cell].row;
            NSLog(@"row: %d", row);
//            _counterManager.row = row;
            _detailItemsViewController.counterRow = row;
            [self.navigationController pushViewController:_detailItemsViewController animated:YES];
            _updatedRow = -1;
        }
            break;
        case UIGestureRecognizerStateEnded://長押し終了時
        {
            NSLog(@"UIGestureRecognizerStateEnded");
        }
            break;
        default:
            break;
    }
}

- (IBAction)buttonPushed:(id)sender
{
//    NSLog(@"aaa");
//    NSLog(@"sender: %@", sender);
    if (_tableView.editing) {
        return;
    }
    UIButton *button = (UIButton*)sender;
    UITableViewCell *cell;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        NSLog(@"parent: %@", [button superview].superview);
        cell = (UITableViewCell*)(button.superview.superview);
    }
    else
    {
        NSLog(@"parent: %@", [button superview].superview.superview);
        cell = (UITableViewCell*)(button.superview.superview.superview);
    }

    NSLog(@"parent: %@", [button superview].superview.superview);
    int row = [_tableView indexPathForCell:cell].row;
    Counter *counter = [_counterManager.counters objectAtIndex:row];
    counter.count++;
    [_counterManager updateCounterCount:row];
    NSLog(@"%d", row);
    for (UIView *view in [button superview].subviews) {
        if (view.tag == 1) {
            UILabel *label = (UILabel*)view;
            NSScanner *scanner = [NSScanner scannerWithString:label.text];
            [scanner setCharactersToBeSkipped:[NSCharacterSet letterCharacterSet]];
            NSInteger integer = 0;
            [scanner scanInteger:&integer];
            integer++;
            label.text = [NSString stringWithFormat:@"%d", integer];
        }
    }
}

#pragma mark - Nend
- (void)dealloc
{
    [_nadView setDelegate:nil];
    _nadView = nil;
}

- (void)nadViewDidFinishLoad:(NADView *)adView
{
    
}

#pragma mark - CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
	[self.visiblePopTipViews removeObject:popTipView];
	self.currentPopTipViewTarget = nil;
}

@end
