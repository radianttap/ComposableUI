//
//  RTBlockCell.m
//  ComposableUI
//
//  Created by Aleksandar Vacić on 2.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTCommon.h"
#import "RTBlockCell.h"

@interface RTBlockCell ()

@property (nonatomic, weak) IBOutlet UILabel *captionLabel;

@end

@implementation RTBlockCell

+ (NSString *)reuseIdentifier {
	return [NSStringFromClass([self class]) uppercaseString];
}

+ (UINib *)nib {
	return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (instancetype)nibInstance {
	return [[[self nib] instantiateWithOwner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.contentView.backgroundColor = [UIColor whiteColor];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {

	UICollectionViewLayoutAttributes *attributes = [layoutAttributes copy];
	[self layoutSubviews];

	CGRect frame = attributes.frame;
	CGSize fittingSize = CGSizeMake(frame.size.width, UILayoutFittingCompressedSize.height);
	frame.size = [self systemLayoutSizeFittingSize:fittingSize withHorizontalFittingPriority:UILayoutPriorityDefaultHigh verticalFittingPriority:UILayoutPriorityFittingSizeLevel];

	attributes.frame = frame;
	return attributes;
}

@end
