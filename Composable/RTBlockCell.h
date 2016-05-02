//
//  RTBlockCell.h
//  ComposableUI
//
//  Created by Aleksandar Vacić on 2.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTBlockCell : UICollectionViewCell

//	hello there, compiler-friendly class methods 
+ (NSString *)reuseIdentifier;
+ (UINib *)nib;
+ (instancetype)nibInstance;

@property (nonatomic, weak, readonly) UILabel *captionLabel;

@end
