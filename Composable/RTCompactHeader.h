//
//  RTCompactHeader.h
//  ComposableUI
//
//  Created by Aleksandar Vacić on 5.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCompactHeader : UICollectionReusableView

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;
+ (instancetype)nibInstance;

@property (nonatomic, weak, readonly) UILabel *captionLabel;

@end

NS_ASSUME_NONNULL_END