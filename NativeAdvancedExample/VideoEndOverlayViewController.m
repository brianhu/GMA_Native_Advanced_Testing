//
//  VideoEndOverlayViewController.m
//  NativeAdvancedExample
//
//  Created by Brian Hu on 2/19/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import "VideoEndOverlayViewController.h"

@interface VideoEndOverlayViewController ()

@end

@implementation VideoEndOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)playVideo:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPlayButton)]) {
        [_delegate didClickPlayButton];
    }
}

- (IBAction)excuteCallToAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickCTAButton)]) {
        [_delegate didClickCTAButton];
    }
}
@end
