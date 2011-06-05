//
//  ExampleAppDelegate.h
//  Example
//
//  Created by Sandro Meier on 05.06.11.
//  Copyright 2011 Fidelis Factory. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExampleViewController;

@interface ExampleAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet ExampleViewController *viewController;

@end
