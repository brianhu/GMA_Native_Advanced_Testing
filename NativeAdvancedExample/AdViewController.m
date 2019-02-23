// Copyright (C) 2015 Google, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "AdViewController.h"
#import <GoogleMobileAds/GADNativeAdMediaAdLoaderOptions_Preview.h>
#import "VideoEndOverlayViewController.h"

// Native Advanced ad unit ID for testing.
//static NSString *const TestAdUnit = @"ca-app-pub-6536861780333891/2010935537";
//static NSString *const TestAdUnit = @"ca-app-pub-3940256099942544/3269769710";
static NSString *const TestAdUnit = @"ca-app-pub-8370525519628947/9701723297";

@interface AdViewController () <GADUnifiedNativeAdLoaderDelegate,
GADVideoControllerDelegate,
GADUnifiedNativeAdDelegate,
VideoEndOverlayViewControllerDelegate>

/// You must keep a strong reference to the GADAdLoader during the ad loading
/// process.
@property(nonatomic, strong) GADAdLoader *adLoader;

/// The native ad view that is being presented.
@property(nonatomic, strong) GADUnifiedNativeAdView *nativeAdView;

/// The height constraint applied to the ad view, where necessary.
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property(nonatomic) NSUInteger endCounter;
@property(nonatomic, strong) VideoEndOverlayViewController *videoEndOverlayVC;
@property(nonatomic, strong) UIView *originCTAView;
@end

@implementation AdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [GADRequest sdkVersion];
    
    NSArray *nibObjects =
    [[NSBundle mainBundle] loadNibNamed:@"TikTokAdView" owner:nil options:nil];
    [self setAdView:[nibObjects firstObject]];
    [self refreshAd:nil];
    
    _endCounter = 0;
    
    self.videoEndOverlayVC = [[VideoEndOverlayViewController alloc] initWithNibName:@"VideoEndOverlayView" bundle:nil];
    self.videoEndOverlayVC.delegate = self;
}


- (IBAction)refreshAd:(id)sender {
    // Loads an ad for unified native ad.
    self.refreshButton.enabled = NO;
    
    GADNativeAdMediaAdLoaderOptions *mediaOptions = [[GADNativeAdMediaAdLoaderOptions alloc] init];
    mediaOptions.mediaAspectRatio = GADMediaAspectRatioPortrait;
    
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.customControlsRequested = @YES;
    
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:TestAdUnit
                                       rootViewController:self
                                                  adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                                  options:@[ mediaOptions, videoOptions ]];
    self.adLoader.delegate = self;
    GADRequest *request = [GADRequest request];
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"disable_content_ad": @YES, @"allow_custom_controls": @YES};
    [request registerAdNetworkExtras:extras];
    [self.adLoader loadRequest:request];
    self.videoStatusLabel.text = @"";
}

- (void)setAdView:(GADUnifiedNativeAdView *)view {
    // Remove previous ad view.
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = view;
    
    // Add new ad view and set constraints to fill its container.
    [self.nativeAdPlaceholder addSubview:view];
    [self.nativeAdView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_nativeAdView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nativeAdView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nativeAdView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDictionary]];
}

/// Gets an image representing the number of stars. Returns nil if rating is
/// less than 3.5 stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
    double starRating = numberOfStars.doubleValue;
    if (starRating >= 5) {
        return [UIImage imageNamed:@"stars_5"];
    } else if (starRating >= 4.5) {
        return [UIImage imageNamed:@"stars_4_5"];
    } else if (starRating >= 4) {
        return [UIImage imageNamed:@"stars_4"];
    } else if (starRating >= 3.5) {
        return [UIImage imageNamed:@"stars_3_5"];
    } else {
        return nil;
    }
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%@ failed with error: %@", adLoader, error);
    self.refreshButton.enabled = YES;
}

#pragma mark GADUnifiedNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
    self.refreshButton.enabled = YES;
    
    GADUnifiedNativeAdView *nativeAdView = self.nativeAdView;
    
    // Deactivate the height constraint that was set when the previous video ad loaded.
    self.heightConstraint.active = NO;
    
    nativeAdView.nativeAd = nativeAd;
    nativeAdView.mediaView.backgroundColor = [UIColor blackColor];
    
    // Set ourselves as the ad delegate to be notified of native ad events.
    nativeAd.delegate = self;
    self.videoController = nativeAd.videoController;
    
    // Populate the native ad view with the native ad assets.
    // The headline is guaranteed to be present in every native ad.
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
    [nativeAdView.headlineView sizeToFit];
    
    // Some native ads will include a video asset, while others do not. Apps can
    // use the GADVideoController's hasVideoContent property to determine if one
    // is present, and adjust their UI accordingly.
    if (nativeAd.videoController.hasVideoContent) {
        // This app uses a fixed width for the GADMediaView and changes its height
        // to match the aspect ratio of the video it displays.
        if (nativeAd.videoController.aspectRatio > 0) {
            self.heightConstraint =
            [NSLayoutConstraint constraintWithItem:nativeAdView.mediaView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nativeAdView.mediaView
                                         attribute:NSLayoutAttributeWidth
                                        multiplier:(1 / nativeAd.videoController.aspectRatio)
                                          constant:0];
            self.heightConstraint.active = YES;
        }
        
        // By acting as the delegate to the GADVideoController, this ViewController
        // receives messages about events in the video lifecycle.
        nativeAd.videoController.delegate = self;
        
        self.videoStatusLabel.text = @"Ad contains a video asset.";
    } else {
        self.videoStatusLabel.text = @"Ad does not contain a video.";
    }
    
    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;
    [nativeAdView.bodyView sizeToFit];
    
    [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
                                                 forState:UIControlStateNormal];
    nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
    nativeAdView.callToActionView.layer.zPosition = 1;
    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;
    
    ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
    nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;
    
    ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
    nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;
    
    ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
    nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;
    
    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
    nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
    
    // In order for the SDK to process touch events properly, user interaction
    // should be disabled.
    nativeAdView.callToActionView.userInteractionEnabled = NO;
}

#pragma mark GADVideoControllerDelegate implementation

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
    if (++_endCounter < 2) {
        [self.videoController play];
    } else {
        self.videoEndOverlayVC.view.frame = self.nativeAdView.bounds;
        [self.nativeAdView addSubview:self.videoEndOverlayVC.view];
        self.originCTAView = self.nativeAdView.callToActionView;
        self.nativeAdView.callToActionView = self.videoEndOverlayVC.callToActionButton;
        [self.videoEndOverlayVC.callToActionButton setTitle:self.nativeAdView.nativeAd.callToAction forState:UIControlStateNormal];
        [self.videoEndOverlayVC.callToActionButton sizeToFit];
    }
}

- (void)videoControllerDidPlayVideo:(GADVideoController *)videoController {
    if (self.pageViewController.percentage != 0.0) {
        [self.videoController stop];
    }
}

#pragma VideoEndOverlayViewControllerDelegate
- (void)didClickPlayButton {
    [self.videoController play];
    [self.videoEndOverlayVC.view removeFromSuperview];
    self.nativeAdView.callToActionView = self.originCTAView;
}

- (void)didClickCTAButton {

}

#pragma mark GADUnifiedNativeAdDelegate

- (void)nativeAdDidRecordClick:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidRecordImpression:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillPresentScreen:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillDismissScreen:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidDismissScreen:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillLeaveApplication:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
