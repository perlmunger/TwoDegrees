//
//  SRSDetailViewController.h
//  TwoDegrees
//
//  Created by Matt Long on 12/11/12.
//  Copyright (c) 2012 Skye Road Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRSDetailViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end
