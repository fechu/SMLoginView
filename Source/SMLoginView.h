//
//  SMLoginView.h
//  CorePlotTests
//
//  Created by Sandro Meier on 30.05.11.
//  Copyright 2011 Fidelis Factory. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SMLoginViewDelegate;

@interface SMLoginView : UIView <UITextFieldDelegate>{
	
	id <SMLoginViewDelegate, NSObject> delegate;
	
	UITextField *_usernameField;
	UITextField *_passwordField;
	UIButton *_loginButton;
	
	UILabel *_loadingLabel;
	UIActivityIndicatorView *_loadingIndicator;
	
	UIColor *_color;
	
}

@property(nonatomic, assign) id <SMLoginViewDelegate, NSObject> delegate;

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UIButton *loginButton;

@property(nonatomic, retain) UILabel *loadingLabel;
@property(nonatomic, retain) UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, retain) UIColor *color;

-(id)init;

//Manually "push" the login button
-(void)login;


//Shakes 
-(void)shake;
-(void)shakeWithDuration:(float)duration;	

//Hides the Login button and shows a UIProgressView instead. (Pass a [NSNumber numberWithBool:...];)
-(void)showLoadingViewAnimated:(NSNumber *)animated;
-(void)hideLoadingViewAnimated:(NSNumber *)animated;

//Will asign the username textfield as the First Responder
-(void)becomeFirstResponder;
-(void)resignFirstResponder;

@end



#pragma mark - SMLoginView Delegate

@protocol SMLoginViewDelegate <NSObject>

@required
-(void)loginView:(SMLoginView *)aLoginView didFinishWithUsername:(NSString *)user andPassword:(NSString *)password;

@end