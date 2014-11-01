//
//  config.h
//  SquareCam 
//
//  Created by masaki on 2013/11/04.
//
//

#ifndef SquareCam__config_h
#define SquareCam__config_h

#if TARGET_IPHONE_SIMULATOR
#define kSimulator 1
#else
#define kSimulator 0
#endif

#define ColorInfoBlue [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0]
#define ColorSuccess [UIColor colorWithRed:25/255.0f green:188/255.0f blue:63/255.0f alpha:1.0]
#define ColorWarning [UIColor colorWithRed:221/255.0f green:170/255.0f blue:59/255.0f alpha:1.0]
#define ColorDanger [UIColor colorWithRed:229/255.0f green:0/255.0f blue:15/255.0f alpha:1.0]

#define ColorArray = [NSArray arrayWithObject:[UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0], [UIColor colorWithRed:25/255.0f green:188/255.0f blue:63/255.0f alpha:1.0], [UIColor colorWithRed:221/255.0f green:170/255.0f blue:59/255.0f alpha:1.0], [UIColor colorWithRed:229/255.0f green:0/255.0f blue:15/255.0f alpha:1.0], nil];


//UI defines
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//add more definitions here
#define kAdbarHeight 50.0
#define kAdbarHeightAtSix 70.0
#define kToolBarHeight 44
#define kStatusBarHeight 20
#define kKeyboardHeight 216

#define kNendID @"c23a2b39371ca8816694888579c63b589295ba24"
#define kSpotID @"140670"
//#define kNendID @""
//#define kSpotID @""


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
