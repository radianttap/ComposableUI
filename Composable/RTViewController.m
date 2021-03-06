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

#import "RTAutocompleteController.h"
#import "RTLocationController.h"

@interface RTViewController () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RTAutocompleteControllerDelegate, RTLocationControllerDelegate >

@property (nonatomic, strong, nonnull) UIBarButtonItem *cancelButton;
@property (nonatomic, strong, nonnull) UICollectionView *collectionView;
@property (nonatomic, strong, nonnull) NSArray< NSString* > *mainDataSource;

@property (nonatomic, getter=isLocalLayoutUpdateScheduled) BOOL localLayoutUpdateScheduled;

@property (nonatomic, strong) UIView *autocompleteContainer;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *autocompletePanelHeightConstraint;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *autocompletePanelBottomConstraint;
@property (nonatomic, strong) RTAutocompleteController *autocompleteController;
@property (nonatomic, getter=isAutocompleteActivated) BOOL autocompleteActivated;

@property (nonatomic, strong) UIView *locationContainer;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *locationPanelHeightConstraint;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *locationPanelBottomConstraint;
@property (nonatomic, strong) RTLocationController *locationController;
@property (nonatomic, getter=isLocationActivated) BOOL locationActivated;


@end

@implementation RTViewController

- (instancetype)init {

	self = [super init];
	if (!self) return nil;

	self.automaticallyAdjustsScrollViewInsets = NO;

	_localLayoutUpdateScheduled = NO;
	_autocompleteActivated = NO;
	_locationActivated = NO;
	_mainDataSource = @[
						@"Random cell text to act",
						@"as some sort of results",
						@"random words that",
						@"don't really",
						@"go anywhere.",
						@"–––",
						@"But sure",
						@"is nice to",
						@"not have to mess with",
						@"all of CoreData nuts & bolts.",
						@"–––",
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
		layout.headerReferenceSize = CGSizeZero;

		UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		collectionView.translatesAutoresizingMaskIntoConstraints = NO;
		collectionView.delegate = self;
		collectionView.dataSource = self;
		collectionView.alwaysBounceVertical = YES;
		collectionView.scrollsToTop = YES;
		[self.view addSubview:collectionView];
		self.collectionView = collectionView;
	}

	{	//	container for autocomplete panel
		UIView *v = [UIView newAutoLayoutView];
		v.clipsToBounds = YES;
		[self.view addSubview:v];
		self.autocompleteContainer = v;
	}
	{	//	container for location search panel
		UIView *v = [UIView newAutoLayoutView];
		v.clipsToBounds = YES;
		[self.view addSubview:v];
		self.locationContainer = v;
	}


	//	## layout


	//	AUTOCOMPLETE starts from filters edge and either shows...
	[self.autocompleteContainer autoPinToTopLayoutGuideOfViewController:self withInset:0];
	[self.autocompleteContainer autoPinEdgeToSuperviewEdge:ALEdgeLeading];
	[self.autocompleteContainer autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
	//	1. just the text field (inactive state)
	self.autocompletePanelHeightConstraint = [self.autocompleteContainer autoSetDimension:ALDimensionHeight toSize:52];
	self.autocompletePanelHeightConstraint.active = YES;
	//	2. both text field *and* results (active state)
	self.autocompletePanelBottomConstraint = [self.autocompleteContainer autoPinToBottomLayoutGuideOfViewController:self withInset:0];
	self.autocompletePanelBottomConstraint.active = NO;

	//	LOCATION starts from autocomplete edge and either shows...
	[self.locationContainer autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.autocompleteContainer];
	[self.locationContainer autoPinEdgeToSuperviewEdge:ALEdgeLeading];
	[self.locationContainer autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
	//	1. just the location label (inactive state)
	self.locationPanelHeightConstraint = [self.locationContainer autoSetDimension:ALDimensionHeight toSize:52];
	self.locationPanelHeightConstraint.active = YES;
	//	2. both text field *and* results (active state)
	self.locationPanelBottomConstraint = [self.locationContainer autoPinToBottomLayoutGuideOfViewController:self withInset:0];
	self.locationPanelBottomConstraint.active = NO;



	//	local results
	[self.collectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.locationContainer withOffset:0];
	//	set this as non-required constraints to avoid 0-height collection view
	[NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
		[self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
	}];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor orangeColor];
	{
		UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSearch:)];
		self.cancelButton = btn;
	}

	//	collection view setup
	self.collectionView.backgroundColor = self.view.backgroundColor;
	[self.collectionView registerNib:[RTBlockCell nib] forCellWithReuseIdentifier:[RTBlockCell reuseIdentifier]];

	//	embed controllers
	[self loadAutocompleteController];
	[self loadLocationController];
}

#pragma mark

- (void)updateLocalLayout {

	if (self.isLocalLayoutUpdateScheduled) return;
	self.localLayoutUpdateScheduled = YES;

	[UIView animateWithDuration:.4
						  delay:.1
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [self.view layoutIfNeeded];
					 } completion:^(BOOL finished) {
						 self.localLayoutUpdateScheduled = NO;
					 }];
}

- (void)initiateSearch {

	[self.collectionView reloadData];
}

- (void)cancelSearch:(id)sender {
	//	cancel whatever text field is activated

	if (self.isAutocompleteActivated) {
		self.autocompleteActivated = NO;
		self.navigationItem.rightBarButtonItem = nil;
		[self.autocompleteController deactivate];

	} else if (self.isLocationActivated) {
		self.locationActivated = NO;
		self.navigationItem.rightBarButtonItem = nil;
		[self.locationController deactivate];
	}

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
	cell.captionLabel.textColor = [UIColor whiteColor];
	cell.contentView.backgroundColor = collectionView.backgroundColor;

	//	place to setup cell's label preferedWidth, if needed

	//	populate data
	cell.captionLabel.text = self.mainDataSource[indexPath.item];

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RTBlockLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(collectionView.bounds.size.width, collectionViewLayout.itemSize.height);
}






#pragma mark - Autocomplete

- (void)loadAutocompleteController {

	RTAutocompleteController *vc = [RTAutocompleteController new];
	vc.delegate = self;
	[self addChildViewController:vc];
	[self.autocompleteContainer addSubview:vc.view];
	vc.view.translatesAutoresizingMaskIntoConstraints = NO;
	[vc didMoveToParentViewController:self];
	self.autocompleteController = vc;

	self.autocompleteContainer.backgroundColor = vc.view.backgroundColor;

	[NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
		[vc.view autoPinEdgesToSuperviewEdges];
	}];
}

- (void)autocompleteControlerDidActivate:(RTAutocompleteController *)controller {

	self.autocompleteActivated = YES;
	//	deactivate location search, if it's active
	[self.locationController deactivate];

	//	expand autocomplete
	self.autocompletePanelHeightConstraint.active = NO;
	self.autocompletePanelBottomConstraint.active = YES;
	[self updateLocalLayout];

	self.navigationItem.rightBarButtonItem = self.cancelButton;
}

- (void)autocompleteControlerDidDeactivate:(RTAutocompleteController *)controller {

	self.autocompleteActivated = NO;
	//	collapse autocomplete
	self.autocompletePanelBottomConstraint.active = NO;
	self.autocompletePanelHeightConstraint.active = YES;
	[self updateLocalLayout];

	self.navigationItem.rightBarButtonItem = nil;
}

- (void)autocompleteControler:(RTAutocompleteController *)controller didSelectSearchString:(NSString *)searchString {

	//	collapse autocomplete
	self.autocompleteActivated = NO;

	//	perform search
	[self initiateSearch];
}

#pragma mark - Location

- (void)loadLocationController {

	RTLocationController *vc = [RTLocationController new];
	vc.delegate = self;
	[self addChildViewController:vc];
	[self.locationContainer addSubview:vc.view];
	vc.view.translatesAutoresizingMaskIntoConstraints = NO;
	[vc didMoveToParentViewController:self];
	self.locationController = vc;

	self.locationContainer.backgroundColor = vc.view.backgroundColor;

	[NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
		[vc.view autoPinEdgesToSuperviewEdges];
	}];
}

- (void)locationControllerDidActivate:(RTLocationController *)controller {

	self.locationActivated = YES;
	//	deactivate autocomplete search, if it's active
	[self.autocompleteController deactivate];

	//	expand location search
	self.locationPanelHeightConstraint.active = NO;
	self.locationPanelBottomConstraint.active = YES;
	[self updateLocalLayout];

	self.navigationItem.rightBarButtonItem = self.cancelButton;
}

- (void)locationControllerDidDeactivate:(RTLocationController *)controller {

	self.locationActivated = NO;
	//	collapse autocomplete
	self.locationPanelBottomConstraint.active = NO;
	self.locationPanelHeightConstraint.active = YES;
	[self updateLocalLayout];

	self.navigationItem.rightBarButtonItem = nil;
}

- (void)locationController:(RTLocationController *)controller didSelectString:(NSString *)locationString location:(CLLocation *)location {

	//	collapse autocomplete
	self.locationActivated = NO;

	//	perform search
	[self initiateSearch];
}

@end
