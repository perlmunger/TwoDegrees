//
//  SRSMasterViewController.m
//  TwoDegrees
//
//  Created by Matt Long on 12/11/12.
//  Copyright (c) 2012 Skye Road Systems. All rights reserved.
//

#import "SRSMasterViewController.h"
#import "SRSDetailViewController.h"

@interface SRSMasterViewController ()

@end

@implementation SRSMasterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self downloadTimeline];
}

- (void)downloadTimeline
{
  ACAccountStore *accountStore = [[ACAccountStore alloc] init];
  ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  [accountStore requestAccessToAccountsWithType:accountType
                                        options:nil
                                     completion:^(BOOL granted, NSError *error) {
     if (granted == YES) {
       NSArray *accounts = [accountStore accountsWithAccountType:accountType];
       
       if ([accounts count] > 0) {
         ACAccount *account = [accounts lastObject];
         
         NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
         
         NSDictionary *parameters = @{@"count" : @"200"};
         
         SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                 requestMethod:SLRequestMethodGET
                                                           URL:url
                                                    parameters:parameters];
         
         [request setAccount:account];
         
         [request performRequestWithHandler:^(NSData *responseData,
                                              NSHTTPURLResponse *urlResponse,
                                              NSError *error) {
           id response = [NSJSONSerialization
                           JSONObjectWithData:responseData
                           options:NSJSONReadingMutableLeaves
                           error:&error];
           
           [self setStories:[[response filteredArrayUsingPredicate:(NSPredicate*)[NSPredicate predicateWithFormat:@"retweet_count > 0 and retweeted_status.entities.urls.@count > 0"]] valueForKeyPath:@"retweeted_status"]];
           
            if ([response count] > 0) {
              dispatch_async(dispatch_get_main_queue(), ^{
                [[self tableView] reloadData];
                // Hack to reload every minute
                [self performSelector:@selector(downloadTimeline) withObject:nil afterDelay:60];
              });
            }
          }];
       }
     } else {
       DLog(@"Failed to get twitter account");
     }
   }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_stories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoryCellIdentifier" forIndexPath:indexPath];
 
  NSDictionary *story = [_stories objectAtIndex:[indexPath row]];

  [[cell textLabel] setText:[story valueForKeyPath:@"user.name"]];
  [[cell detailTextLabel] setText:[story valueForKey:@"text"]];
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  SRSDetailViewController *detailController = [[[self splitViewController] viewControllers] objectAtIndex:1];

  NSDictionary *story = [_stories objectAtIndex:[indexPath row]];

  NSString *url = [[story valueForKeyPath:@"entities.urls.expanded_url"] lastObject];
  [[detailController webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
  
}

@end
