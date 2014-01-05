//
//  SRMainViewController.m
//  Bolted!
//
//  Created by Soemarko Ridwan on 1/4/14.
//  Copyright (c) 2014 Soemarko Ridwan. All rights reserved.
//

#import "SRMainViewController.h"
#import "KeychainItemWrapper.h"
#import "NSString+Stringy.h"

@interface SRMainViewController ()

@end

@implementation SRMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.navigationItem.title = @"Bolted!";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	[self.navigationItem setLeftBarButtonItem:refreshBtn];

	UIBarButtonItem *loginBtn = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(login)];
	[self.navigationItem setRightBarButtonItem:loginBtn];

	[self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)refresh {
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BoltLogin" accessGroup:nil];
	NSString *user = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
	NSData *passData = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
	NSString *pass = [[NSString alloc] initWithBytes:passData.bytes length:passData.length encoding:NSUTF8StringEncoding];

	if ([user isEqualToString:@""] && [pass isEqualToString:@""]) {
		return;
	}

	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.boltsuper4g.com/my-bolt.html"]];
	[req setHTTPMethod:@"post"];

	NSString *body = [NSString stringWithFormat:@"msisdn=%@&password=%@&login-submit=", user, pass];
	[req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];

	[NSURLConnection connectionWithRequest:req delegate:self];

	_label.text = @"Logging in...";
}

- (void)login {
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BoltLogin" accessGroup:nil];
	NSString *user = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
	NSData *passData = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
	NSString *pass = [[NSString alloc] initWithBytes:passData.bytes length:passData.length encoding:NSUTF8StringEncoding];

	dialog = [[UIAlertView alloc] initWithTitle:@"Bolt! Login" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];

	[dialog setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];

	UITextField *userField = [dialog textFieldAtIndex:0];
	[userField setPlaceholder:@"999xxxxxxx"];
	[userField setText:user];
	[userField setKeyboardType:UIKeyboardTypeNumberPad];

	UITextField *passField = [dialog textFieldAtIndex:1];
	[passField setText:pass];
	[passField setDelegate:self];

	[dialog show];
}

#pragma mark - Delegates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.cancelButtonIndex) {
		dialog = nil;
		return;
	}

	UITextField *userField = [alertView textFieldAtIndex:0];
	UITextField *passField = [alertView textFieldAtIndex:1];

	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BoltLogin" accessGroup:nil];
	[keychainItem setObject:userField.text forKey:(__bridge id)(kSecAttrAccount)];
	[keychainItem setObject:passField.text forKey:(__bridge id)(kSecValueData)];

	dialog = nil;

	[self refresh];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[dialog dismissWithClickedButtonIndex:dialog.firstOtherButtonIndex animated:YES];
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_label.text = [error localizedDescription];
	responseData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	_label.text = @"Parsing result...";

	NSString *responseStr = [[NSString stringWithUTF8String:responseData.bytes] stringByStrippingHTML];

	NSString *quota = [responseStr stringBetweenString:@"Kuota Utama" andString:@"GB"];
	if (!quota) {
		_label.text = @"Error!\nPlease check your username or password.";
		return;
	}

	quota = [quota stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	quota = [quota stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	quota = [quota stringByReplacingOccurrencesOfString:@">" withString:@"\n"];

	_label.text = [NSString stringWithFormat:@"Kuota Utama%@ GB", quota];
}

@end
