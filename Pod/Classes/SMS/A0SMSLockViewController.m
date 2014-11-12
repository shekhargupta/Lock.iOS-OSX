// A0SMSLockViewController.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0SMSLockViewController.h"
#import "A0Theme.h"
#import "A0SMSSendCodeViewController.h"
#import "A0AuthParameters.h"
#import "A0SMSCodeViewController.h"
#import <libextobjc/EXTScope.h>
#import "A0NavigationView.h"


@interface A0SMSLockViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *iconContainerView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)close:(id)sender;

@end

@implementation A0SMSLockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        _closable = NO;
        _authenticationParameters = [A0AuthParameters newDefaultParams];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.closeButton.enabled = self.closable;
    self.closeButton.hidden = !self.closable;
    A0Theme *theme = [A0Theme sharedInstance];
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor defaultColor:self.view.backgroundColor];
    self.iconContainerView.backgroundColor = [theme colorForKey:A0ThemeIconBackgroundColor defaultColor:self.iconContainerView.backgroundColor];
    self.iconImageView.image = [theme imageForKey:A0ThemeIconImageName defaultImage:self.iconImageView.image];
    [self displayController:[self buildSMSSendCode]];
}

- (void)close:(id)sender {
    Auth0LogVerbose(@"Dismissing SMS view controller on user's request.");
    if (self.onUserDismissBlock) {
        self.onUserDismissBlock();
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (A0SMSSendCodeViewController *)buildSMSSendCode {
    A0SMSSendCodeViewController *controller = [[A0SMSSendCodeViewController alloc] init];
    @weakify(self);
    controller.onRegisterBlock = ^{
        @strongify(self);
        [self displayController:[self buildSMSCode]];
    };
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"ALREADY HAVE A CODE?") actionBlock:^{
        @strongify(self);
        [self displayController:[self buildSMSCode]];
    }];
    return controller;
}

- (A0SMSCodeViewController *)buildSMSCode {
    @weakify(self);
    A0SMSCodeViewController *controller = [[A0SMSCodeViewController alloc] init];
    void(^showRegister)() = ^{
        @strongify(self);
        [self displayController:[self buildSMSSendCode]];
    };
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"DIDN'T RECEIVE CODE?") actionBlock:showRegister];
    return controller;
}

@end
