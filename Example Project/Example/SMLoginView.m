//
//  SMLoginView.m
//  CorePlotTests
//
//  Created by Sandro Meier on 30.05.11.
//  Copyright 2011 Fidelis Factory. All rights reserved.
//

#import "SMLoginView.h"

#import <QuartzCore/QuartzCore.h>

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

#pragma mark - SMLoginTextField

@interface SMLoginTextField : UITextField {

}

@end

@implementation SMLoginTextField

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.layer.borderColor = [UIColor lightGrayColor].CGColor;
		self.layer.borderWidth = 2.0;
		self.layer.cornerRadius = self.bounds.size.height / 3;
		self.layer.backgroundColor = [UIColor whiteColor].CGColor;
		self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	}
	return self;
}

-(id)init {
	return [self initWithFrame:CGRectMake(0, 0, 100, 100)];
}




@end

#define kCornerRadius 20

#pragma mark - SMLoginView Implementation

@implementation SMLoginView

@synthesize  delegate;

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize loginButton = _loginButton;

@synthesize loadingLabel = _loadingLabel;
@synthesize loadingIndicator = _loadingIndicator;

@synthesize color = _color;


#pragma mark - Creation and Presentation

-(id)init {
	self = [super initWithFrame:CGRectMake(0, 0, 300, 300)];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.color = [UIColor colorWithRed:0.4 green:0.73 blue:0.93 alpha:1.0];
		self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		//The shadow
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOffset = CGSizeMake(0, 3);
		self.layer.shadowRadius = 5.0;
		self.layer.shadowOpacity = 0.8;
		
		//Username Textfield
		SMLoginTextField *usernameTextfield = [[SMLoginTextField alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
		usernameTextfield.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/4);
		usernameTextfield.textAlignment = UITextAlignmentCenter;
		usernameTextfield.borderStyle = UITextBorderStyleBezel;
		usernameTextfield.placeholder = @"Username";
		usernameTextfield.font = [UIFont boldSystemFontOfSize:16];
		usernameTextfield.returnKeyType = UIReturnKeyDone;
		usernameTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
		usernameTextfield.delegate = self;
		
		self.usernameField = usernameTextfield;
		[self addSubview:usernameTextfield];
		[usernameTextfield release];
		
		//Pasword Textfield
		SMLoginTextField *passwortTextField = [[SMLoginTextField alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
		passwortTextField.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/4 + 1.5*passwortTextField.bounds.size.height );
		passwortTextField.textAlignment = YES;
		passwortTextField.secureTextEntry = YES;
		passwortTextField.borderStyle = UITextBorderStyleBezel;
		passwortTextField.placeholder = @"Password";
		passwortTextField.font = [UIFont boldSystemFontOfSize:16];
		passwortTextField.returnKeyType = UIReturnKeyDone;
		passwortTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		passwortTextField.delegate = self;
		
		self.passwordField = passwortTextField;
		[self addSubview:passwortTextField];
		[passwortTextField release];
		
		
		
		//Login Button
		UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		loginButton.frame = CGRectMake(0, 0, 250, 50);
		loginButton.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/6*5);
		[loginButton setTitle:@"Login" forState:UIControlStateNormal];
		[loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
		//Customize the button
		loginButton.layer.cornerRadius = loginButton.bounds.size.height/5;
		loginButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
		loginButton.layer.borderWidth = 2.0;
		loginButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
		loginButton.titleLabel.textColor = [UIColor darkGrayColor];
		loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
		[self addSubview:loginButton];
		self.loginButton = loginButton;
		
		//Loading Label and Indicator
		UIActivityIndicatorView *actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		actInd.hidesWhenStopped = NO;
		actInd.alpha = 0.0;
		
		UILabel *loadLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
		loadLab.text = @"Login in...";
		loadLab.font = [UIFont systemFontOfSize:16];
		loadLab.alpha = 0.0;
		
		CGSize textAreaSize = [loadLab.text sizeWithFont:loadLab.font];
		loadLab.frame = CGRectMake(0, 0, textAreaSize.width, textAreaSize.height);
		loadLab.backgroundColor = [UIColor clearColor];
		
		//Calculate the position of these two objects
		float totalWidht = actInd.frame.size.width + 5 + textAreaSize.width;
		actInd.center = CGPointMake(loginButton.center.x - totalWidht/2 + actInd.frame.size.width / 2, loginButton.center.y);
		loadLab.center = CGPointMake(loginButton.center.x + totalWidht / 2 - loadLab.frame.size.width / 2, loginButton.center.y);
		
		[self addSubview:actInd];
		[self addSubview:loadLab];
		self.loadingLabel = loadLab;
		self.loadingIndicator = actInd;
		[actInd release];
		[loadLab release];
		
				
		
		
		
		
	}
	return self;
}

-(id)initWithFrame:(CGRect)frame {
	//The given frame is ignored.
	return [self init];
}


#pragma mark - Drawing




-(void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	//Define the clipping area
	CGContextBeginPath(context);
	addRoundedRectToPath(context, self.bounds, kCornerRadius, kCornerRadius);
	CGContextClosePath(context);
	CGContextClip(context);
	
	//Add the color
	CGContextAddRect(context, self.bounds);
	CGContextSetFillColorWithColor(context, self.color.CGColor);
	CGContextFillPath(context);
	
	//gloss
	CGContextAddEllipseInRect(context, CGRectMake(-100, -50, self.bounds.size.width + 200, self.bounds.size.height/2 + 100));
	if ([self.color isEqual:[UIColor whiteColor]]) {
		CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.1].CGColor);
	}
	else {
		CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor);
	}
	CGContextFillPath(context);
	
	//And a border
	addRoundedRectToPath(context, CGRectInset(self.bounds, 1, 1), kCornerRadius-1, kCornerRadius-1);
	CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
	CGContextSetLineWidth(context, 3.0);
	CGContextStrokePath(context);
	
	CGContextRestoreGState(context);
}

#pragma mark - Memory Management

- (void)dealloc {
	self.delegate = nil;
	
	self.usernameField = nil;
	self.passwordField = nil;
	
	self.color = nil;

    [super dealloc];
}

#pragma mark - Shaking

-(void)shakeWithDuration:(float)duration;	 {
	int dx = 20;
		
	//The shake consists of 3 parts.
	[UIView animateWithDuration:duration/4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		self.transform = CGAffineTransformMakeTranslation(dx, 0);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:duration/2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
			self.transform = CGAffineTransformMakeTranslation(-dx, 0);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:duration/4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
				self.transform = CGAffineTransformMakeTranslation(0, 0);
			} completion:NULL];
		}];
	}];
	
}

-(void)shake {
	[self shakeWithDuration:0.25];
}
 

#pragma mark - Textfield Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.usernameField) {
		[self.passwordField becomeFirstResponder];
	}
	else if (textField == self.passwordField) {
		[textField resignFirstResponder];
		[self login];
	}
	
	return YES;
}

#pragma mark - Dismiss

-(void)login {
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginView:didFinishWithUsername:andPassword:)]) {
		[self.delegate loginView:self didFinishWithUsername:self.usernameField.text andPassword:self.passwordField.text];
	}
}

#pragma mark - Layout Changes

-(void)showLoadingViewAnimated:(NSNumber *)animated {
	self.loginButton.enabled = NO;
	[self.loadingIndicator startAnimating];
	//Disable the textfields
	self.usernameField.enabled = NO;
	self.passwordField.enabled = NO;
	
	if ([animated boolValue] == YES) {
		 
		[UIView animateWithDuration:0.2 animations:^(void) {
			self.loginButton.alpha = 0.0;
			self.loadingLabel.alpha = 1.0;
			self.loadingIndicator.alpha = 1.0;
		}];
	}
	else {
		self.loginButton.alpha = 0.0;
		self.loadingLabel.alpha = 1.0;
		self.loadingIndicator.alpha = 1.0;
	}
}

-(void)hideLoadingViewAnimated:(NSNumber *)animated {
	self.loginButton.enabled = YES;
	[self.loadingIndicator stopAnimating];
	//Enable the textfields
	self.usernameField.enabled = YES;
	self.passwordField.enabled = YES;
	if ([animated boolValue] == YES) {
		
		[UIView animateWithDuration:0.2 animations:^(void) {
			self.loginButton.alpha = 1.0;
			self.loadingLabel.alpha = 0.0;
			self.loadingIndicator.alpha = 0.0;
		}];
	}
	else {
		self.loginButton.alpha = 1.0;
		self.loadingLabel.alpha = 0.0;
		self.loadingIndicator.alpha = 0.0;
	}
}


#pragma mark - Responder

-(void)becomeFirstResponder {
	[self.usernameField becomeFirstResponder];
}

-(void)resignFirstResponder {
	[self.usernameField resignFirstResponder];
	[self.passwordField resignFirstResponder];
}



@end
