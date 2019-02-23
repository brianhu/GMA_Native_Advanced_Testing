//
//  RootViewController.m
//  NativeAdvancedExample
//
//  Created by Brian Hu on 1/15/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import "RootViewController.h"
#import "PageContentViewController.h"
#import "AdViewController.h"
#import "TikTokPageViewController.h"

@interface RootViewController ()  <UIPageViewControllerDataSource>
@property (strong, nonatomic) TikTokPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *viewArray;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    NSMutableArray *adViewControllers = [[NSMutableArray alloc] init];
    _viewArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        if (i % 3 == 0) {
            AdViewController *adViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AdViewController"];
            adViewController.index = i;
            adViewController.pageViewController = self.pageViewController;
            [_viewArray addObject:adViewController];
            [adViewControllers addObject:adViewController];
        } else {
            PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
            pageContentViewController.index = i;
            [_viewArray addObject:pageContentViewController];
        }
    }
    
    PageContentViewController *startingViewController = _viewArray[0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.adViewControllers = adViewControllers;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController *) viewController).index;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    return _viewArray[--index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).index;
    
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [_viewArray count]) {
        return nil;
    }
    
    
    return _viewArray[index];
}
@end
