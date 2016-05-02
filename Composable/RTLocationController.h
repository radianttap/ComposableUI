//
//  RTLocationController.h
//  ComposableUI
//
//  Created by Aleksandar Vacić on 1.5.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

@import UIKit;
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

@protocol RTLocationControllerDelegate;

@interface RTLocationController : UIViewController

@property (nonatomic, weak) id< RTLocationControllerDelegate > delegate;
@property (nonatomic) CGFloat verticalSpace;

- (void)deactivate;

@end


@protocol RTLocationControllerDelegate <NSObject>

- (void)locationControllerDidActivate:(RTLocationController *)controller;
- (void)locationControllerDidDeactivate:(RTLocationController *)controller;
- (void)locationController:(RTLocationController *)controller didSelectString:(NSString *)locationString location:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END