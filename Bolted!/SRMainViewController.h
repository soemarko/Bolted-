//
//  SRMainViewController.h
//  Bolted!
//
//  Created by Soemarko Ridwan on 1/4/14.
//  Copyright (c) 2014 Soemarko Ridwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMainViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, NSURLConnectionDataDelegate> {
	UIAlertView *dialog;
	NSMutableData *responseData;
}

@property (weak, nonatomic) IBOutlet UILabel *label;

@end
