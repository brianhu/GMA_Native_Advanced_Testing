//
//  PageContentViewController.h
//  NativeAdvancedExample
//
//  Created by Brian Hu on 1/15/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (nonatomic) NSUInteger index;
@end

NS_ASSUME_NONNULL_END
