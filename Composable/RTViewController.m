//
//  RTViewController.m
//  ComposableUI
//
//  Created by Aleksandar Vacić on 2.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

@import PureLayout;
#import "RTCommon.h"

#import "RTViewController.h"
#import "RTBlockLayout.h"
#import "RTBlockCell.h"

@interface RTViewController () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >	//	RTAutocompleteControllerDelegate, RTLocationControllerDelegate, RTFilterControllerDelegate, RTDateRangeControllerDelegate

@property (nonatomic, strong, nonnull) UICollectionView *collectionView;
@property (nonatomic, strong, nonnull) NSArray< NSString* > *mainDataSource;

@end

@implementation RTViewController

- (instancetype)init {

	self = [super init];
	if (!self) return nil;

	self.automaticallyAdjustsScrollViewInsets = YES;

	_mainDataSource = @[
						@"Random",
						@"words that",
						@"don't really",
						@"go anywhere,",
						@"But sure",
						@"is nice to",
						@"not have to screw with",
						@"all of CoreData nuts & bolts.",
						@"I mean...",
						@"who loves to do that?",
						@"Xcode should have",
						@"random array generation",
						@"built in.",
						@"Hm.",
						@"Right.",
						];

	return self;
}

#pragma mark View hierarchy

- (void)loadView {
	[super loadView];

	//	collection view for main data set
	{
		RTBlockLayout *layout = [RTBlockLayout new];

		UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		collectionView.translatesAutoresizingMaskIntoConstraints = NO;
		collectionView.delegate = self;
		collectionView.dataSource = self;
		collectionView.alwaysBounceVertical = YES;
		collectionView.scrollsToTop = YES;
		[self.view addSubview:collectionView];
		self.collectionView = collectionView;
	}

	//	## layout

	//	main data set
	[self.collectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:0];
	//	set this as non-required constraints to avoid 0-height collection view
	[NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
		[self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
	}];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor lightGrayColor];
	self.collectionView.backgroundColor = [UIColor lightGrayColor];

	//	collection view setup
	[self.collectionView registerNib:[RTBlockCell nib] forCellWithReuseIdentifier:[RTBlockCell reuseIdentifier]];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

#pragma mark - CollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

	NSInteger ret = self.mainDataSource.count;
	return ret;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	//	get instance of cell
	RTBlockCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RTBlockCell reuseIdentifier] forIndexPath:indexPath];

	//	place to setup cell's label preferedWidth, if needed

	//	populate data
	cell.captionLabel.text = self.mainDataSource[indexPath.item];

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RTBlockLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

	return CGSizeMake(collectionView.bounds.size.width, collectionViewLayout.itemSize.height);
}

@end
