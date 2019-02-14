//
//  PageContentViewController.m
//  NativeAdvancedExample
//
//  Created by Brian Hu on 1/15/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _indexLabel.text = [NSString stringWithFormat:@"page %d", _index];
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
