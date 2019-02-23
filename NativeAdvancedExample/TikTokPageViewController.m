//
//  TikTokPageViewController.m
//  NativeAdvancedExample
//
//  Created by Brian Hu on 2/23/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import "TikTokPageViewController.h"
#import "AdViewController.h"

@interface TikTokPageViewController () <UIScrollViewDelegate>

@end

@implementation TikTokPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:UIScrollView.class]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            scrollView.delegate = self;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint point = scrollView.contentOffset;
    self.percentage = fabs(point.y - self.view.frame.size.height) / self.view.frame.size.height;
    if (self.percentage != 0.0) {
        for (AdViewController *vc in self.adViewControllers) {
            [vc.videoController stop];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
