//
//  VideoEndOverlayViewController.h
//  NativeAdvancedExample
//
//  Created by Brian Hu on 2/19/19.
//  Copyright © 2019 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VideoEndOverlayViewControllerDelegate <NSObject>

- (void)didClickPlayButton;
- (void)didClickCTAButton;

@end

@interface VideoEndOverlayViewController : UIViewController
- (IBAction)playVideo:(id)sender;
- (IBAction)excuteCallToAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *callToActionButton;
@property (weak, nonatomic) id<VideoEndOverlayViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
