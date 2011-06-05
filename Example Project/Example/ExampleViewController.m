//
//  ExampleViewController.m
//  Example
//
//  Created by Sandro Meier on 05.06.11.
//  Copyright 2011 Fidelis Factory. All rights reserved.
//

#import "ExampleViewController.h"

@implementation ExampleViewController


- (void)dealloc
{
	[loginView release]; loginView = nil;
	[username release]; username = nil;
	[password release]; password = nil;
	
    [super dealloc];
}


#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{

	loginView = [[SMLoginView alloc] init];
	loginView.delegate = self;
	loginView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/3);
	[self.view addSubview:loginView];
	[loginView becomeFirstResponder];

    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



#pragma mark - SMLoginView Delegate

-(void)loginView:(SMLoginView *)aLoginView didFinishWithUsername:(NSString *)user andPassword:(NSString *)pass {
	
	/*
	 Normally you send the password to a webservice or compare it with a keychain value. But in this example we just show the loading indicator and check the password after 2 seconds.
	 */
	
	//Check the password
	[aLoginView showLoadingViewAnimated:[NSNumber numberWithBool:YES]];
	
	username = [user retain];
	password = [pass retain];
	[aLoginView performSelector:@selector(hideLoadingViewAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0];
	[self performSelector:@selector(checkPassword) withObject:nil afterDelay:2.0];
}


-(void)checkPassword {
	if ([username isEqualToString:@"FidelisFactory"] && [password isEqualToString:@"LoginPassword"]) {
		UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You logged in successfully" delegate:nil cancelButtonTitle:@"I did it!" otherButtonTitles: nil];
		[alertview show];
		[alertview release];
	}
	else {
		[loginView shake];
		loginView.usernameField.text = @"";
		loginView.passwordField.text = @"";
	}
}

@end
