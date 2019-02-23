//
//  TikTokPageViewController.h
//  NativeAdvancedExample
//
//  Created by Brian Hu on 2/23/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TikTokPageViewController : UIPageViewController
@property (nonatomic) CGFloat percentage;
@property (nonatomic, strong) NSArray *adViewControllers;
@end

NS_ASSUME_NONNULL_END
