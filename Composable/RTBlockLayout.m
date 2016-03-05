//
//  RTBlockLayout.m
//  ComposableUI
//
//  Created by Aleksandar Vacić on 2.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTBlockLayout.h"

@implementation RTBlockLayout

- (instancetype)init {

	self = [super init];
	if ( !self ) return nil;

	[self commonInit];

	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self commonInit];
}

- (void)commonInit {

	self.itemSize = CGSizeMake(320, 44);
	self.headerReferenceSize = CGSizeMake(320, 36);
//	self.estimatedItemSize = CGSizeMake(320, 64);

	self.scrollDirection = UICollectionViewScrollDirectionVertical;
	self.sectionInset = UIEdgeInsetsZero;
	self.minimumLineSpacing = 1;
	self.minimumInteritemSpacing = 0;
	self.footerReferenceSize = CGSizeZero;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {

	return ( !CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size) );
}

//- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes {
//	return ( !CGRectEqualToRect(originalAttributes.frame, preferredAttributes.frame) );
//}

@end
