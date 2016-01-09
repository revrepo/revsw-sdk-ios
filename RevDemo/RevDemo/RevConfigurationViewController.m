/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

#import "RevConfigurationViewController.h"
#import <RevSDK/RevSDK.h>

@interface RevConfigurationViewController ()

@property (weak, nonatomic) IBOutlet UITextView *configurationTextView;

@end

@implementation RevConfigurationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateConfiguration];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(updateConfiguration)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)updateConfiguration
{
    NSString *config = [RevSDK debug_getLatestConfiguration];
    if ([config length] > 0) {
        NSLog(@"debug_getLatestConfiguration: %@", config);
        [self.configurationTextView setText:config];
    }
}

+ (NSString*)formatJSONPretty:(id)obj
{
    NSData *d = [NSJSONSerialization dataWithJSONObject:obj
                                                options:NSJSONWritingPrettyPrinted
                                                  error:nil];
    
    return [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}

#pragma mark - Actions

- (IBAction)onUpdateButtonTapped:(id)sender
{
    [RevSDK debug_forceConfigurationUpdate];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(updateConfiguration)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)onLogsButtonTapped:(id)sender
{
    [RevSDK debug_showLogInViewController:self];
}


@end
