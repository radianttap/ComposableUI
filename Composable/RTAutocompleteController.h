//
//  RTAutocompleteController.h
//  ComposableUI
//
//  Created by Aleksandar Vacić on 5.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTAutocompleteControllerDelegate;
@interface RTAutocompleteController : UIViewController

@property (nonatomic, weak) id<RTAutocompleteControllerDelegate> delegate;
@property (nonatomic, copy, nullable) NSString *autocompleteString;
@property (nonatomic) CGFloat verticalSpace;

- (void)deactivate;

@end

@protocol RTAutocompleteControllerDelegate <NSObject>

- (void)autocompleteControlerDidActivate:(RTAutocompleteController *)controller;
- (void)autocompleteControlerDidDeactivate:(RTAutocompleteController *)controller;
- (void)autocompleteControler:(RTAutocompleteController *)controller didSelectSearchString:(NSString *)searchString;

@end

NS_ASSUME_NONNULL_END