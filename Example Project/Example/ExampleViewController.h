//
//  ExampleViewController.h
//  Example
//
//  Created by Sandro Meier on 05.06.11.
//  Copyright 2011 Fidelis Factory. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SMLoginView.h"

@interface ExampleViewController : UIViewController <SMLoginViewDelegate>{
	SMLoginView *loginView;
	
	NSString *username;
	NSString *password;
	
}

-(void)checkPassword;

@end
