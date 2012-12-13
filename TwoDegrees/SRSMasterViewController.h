//
//  SRSMasterViewController.h
//  TwoDegrees
//
//  Created by Matt Long on 12/11/12.
//  Copyright (c) 2012 Skye Road Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRSMasterViewController : UITableViewController

@property (nonatomic, strong) NSArray *stories;

- (void)downloadTimeline;

@end
