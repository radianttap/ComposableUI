//
//  RTLocationController.m
//  ComposableUI
//
//  Created by Aleksandar Vacić on 1.5.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTLocationController.h"
@import MapKit;
@import AddressBookUI;
@import ContactsUI;

#import "RTBlockLayout.h"
#import "RTBlockCell.h"
#import "RTCompactHeader.h"

typedef NS_ENUM(NSInteger, RTLocationSection) {
	RTLocationSectionRecents = 0,
	RTLocationSectionResults,
	RTLocationSectionsCOUNT
};

typedef NS_ENUM(NSInteger, RTLocationDisplayMode) {
	RTLocationDisplayModeDefault,
	RTLocationDisplayModeLocationKnown,
	RTLocationDisplayModeTextFieldActive
};

@interface RTLocationController () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property (nonatomic) RTLocationDisplayMode displayMode;

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationLabelButton;
@property (weak, nonatomic) IBOutlet UIButton *nearmeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *verticalSpacingConstraint;

@property (nonatomic) MKCoordinateRegion region;
@property (nonatomic, copy, nullable) NSString *autocompleteString;
@property (nonatomic, copy, nullable) CLLocation *currentLocation;
@property (nonatomic, copy, nullable) NSString *currentLocationString;

@property (nonatomic, strong, nullable) NSArray< NSString * > *recentSearches;
@property (nonatomic, strong, nullable) NSArray< MKPlacemark * > *searchResults;

@end

@implementation RTLocationController

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (instancetype)init {

	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if (!self) return nil;

	self.automaticallyAdjustsScrollViewInsets = NO;

	_displayMode = RTLocationDisplayModeDefault;

	_verticalSpace = 0;
	_delegate = nil;
	_autocompleteString = nil;
	_currentLocationString = nil;
	_currentLocation = nil;

	//	San Francisco downtown, more or less
	_region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.777499, -122.419968), MKCoordinateSpanMake(1, 1));

	_recentSearches = @[
						@"Starbucks",
						@"Blue Bottle",
						@"Peet's"
						];
	_searchResults = nil;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:UIKeyboardWillHideNotification object:nil];

	return self;
}

- (void)dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)notification {

	//	adjust collection view insets for the keyboard

	if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
		CGRect endRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
		double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
		UIViewAnimationOptions options = (curve << 16);

		[self adjustCollectionViewBottomInsetTo:CGRectGetHeight(endRect)];
		[UIView animateWithDuration:duration
							  delay:0
							options:options
						 animations:^{
							 [self.view layoutIfNeeded];
						 } completion:^(BOOL finished) {
						 }];

	} else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
		double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
		UIViewAnimationOptions options = (curve << 16);

		[self adjustCollectionViewBottomInsetTo:self.bottomLayoutGuide.length];
		[UIView animateWithDuration:duration
							  delay:0
							options:options
						 animations:^{
							 [self.view layoutIfNeeded];
						 } completion:^(BOOL finished) {
						 }];
	}
}

- (void)adjustCollectionViewBottomInsetTo:(CGFloat)bottom {

	UIEdgeInsets contentInset = self.collectionView.contentInset;
	contentInset.bottom = bottom;
	self.collectionView.contentInset = contentInset;
}

- (void)performLocalSearch {
	if ( self.autocompleteString.length == 0 ) return;

	MKLocalSearchRequest *request = [MKLocalSearchRequest new];
	request.naturalLanguageQuery = self.autocompleteString;
	request.region = self.region;

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
	[localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		if (error != nil) {
			return;
		}
		self.searchResults = [response.mapItems valueForKey:NSStringFromSelector(@selector(placemark))];
		[self.collectionView reloadData];
	}];
}

- (NSString *)locationStringForPlacemark:(MKPlacemark *)placemark {
	return [ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO) stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
}

- (void)setDefaultLocationCaption {
	self.locationLabel.text = self.defaultLocationCaption;
}

- (NSString *)defaultLocationCaption {
	return NSLocalizedString(@"← filter per location", nil);
}

- (void)setDisplayMode:(RTLocationDisplayMode)displayMode {

	if (_displayMode == displayMode) return;
	_displayMode = displayMode;

	[self processDisplayModeAnimated:YES];
}

- (void)processDisplayModeAnimated:(BOOL)animated {

	CGFloat fieldAlpha = 0;
	CGFloat nearmeAlpha = 0;
	CGFloat locationAlpha = 0;

	switch (self.displayMode) {
		case RTLocationDisplayModeDefault: {
			fieldAlpha = 0;
			locationAlpha = 1;
			self.locationButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
			[self.locationButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.5] forState:UIControlStateNormal];
			self.locationLabel.text = NSLocalizedString(@"← filter per location", nil);
			self.locationLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
			self.locationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
			nearmeAlpha = 1;
			break;
		}
		case RTLocationDisplayModeLocationKnown: {
			fieldAlpha = 0;
			locationAlpha = 1;
			self.locationButton.tintColor = [UIColor whiteColor];
			[self.locationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			self.locationLabel.textColor = [UIColor whiteColor];
			self.locationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
			nearmeAlpha = 1;
			break;
		}
		case RTLocationDisplayModeTextFieldActive: {
			self.locationButton.tintColor = [UIColor whiteColor];
			fieldAlpha = 1;
			nearmeAlpha = 0;
			locationAlpha = 0;
			break;
		}
		default: {
			break;
		}
	}

	[UIView animateWithDuration:(animated) ? .3 : 0
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 self.searchContainer.alpha = fieldAlpha;
						 self.nearmeButton.alpha = nearmeAlpha;
						 self.locationLabel.alpha = locationAlpha;
						 self.locationLabelButton.alpha = locationAlpha;
						 [self.view layoutIfNeeded];
					 } completion:nil];
}

#pragma mark

/**
 *	When this controller is embedded, container will set required verticalSpace
 */
- (void)didMoveToParentViewController:(UIViewController *)parent {

	self.verticalSpacingConstraint.constant = self.verticalSpace;
	[self.view setNeedsLayout];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

//	//	add loupe icon to the text field
//	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 18)];
//	iv.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
//	iv.contentMode = UIViewContentModeScaleAspectFit;
//	iv.image = [UIImage imageNamed:@"loupe"];
//	self.searchField.leftView = iv;
//	self.searchField.leftViewMode = UITextFieldViewModeAlways;

	self.searchContainer.layer.borderColor = [UIColor whiteColor].CGColor;
	self.searchField.tintColor = [UIColor whiteColor];
	self.searchField.textColor = [UIColor whiteColor];
	self.searchField.text = self.autocompleteString;
	self.searchField.placeholder = self.defaultLocationCaption;

	[self.collectionView registerNib:[RTBlockCell nib] forCellWithReuseIdentifier:[RTBlockCell reuseIdentifier]];
	[self.collectionView registerNib:[RTCompactHeader nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[RTCompactHeader reuseIdentifier]];

	[self processDisplayModeAnimated:NO];
}

- (void)initiateAutocompleteFor:(NSString *)searchString {

	self.autocompleteString = searchString;
	[self performLocalSearch];
}


#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {

	if (self.parentViewController) {
		[self.delegate locationControllerDidActivate:self];
	} else {
		//		self.navigationItem.rightBarButtonItem = self.cancelButton;
	}
}

- (IBAction)textFieldDidChangeValue:(UITextField *)textField {

	[self initiateAutocompleteFor:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	if (self.parentViewController) {
		if (self.autocompleteString.length == 0) {
			[self.delegate locationControllerDidDeactivate:self];
		} else {
			if (self.currentLocation && self.currentLocationString) {
				[self.delegate locationController:self didSelectString:self.currentLocationString location:self.currentLocation];
			} else {
				[self.delegate locationControllerDidDeactivate:self];
			}
		}
	}
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {

	self.searchResults = nil;
	self.autocompleteString = nil;

	[self.collectionView.collectionViewLayout invalidateLayout];
	[self.collectionView reloadData];

	return YES;
}



#pragma mark - CollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

	return RTLocationSectionsCOUNT;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

	switch ((RTLocationSection)section) {
		case RTLocationSectionRecents: {
			return (self.autocompleteString.length == 0) ? self.recentSearches.count : 0;
			break;
		}
		case RTLocationSectionResults: {
			return (self.autocompleteString.length == 0) ? 0 : self.searchResults.count;
			break;
		}
		default:
			break;
	}
	return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

	switch ((RTLocationSection)indexPath.section) {
		case RTLocationSectionRecents: {
			RTCompactHeader *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[RTCompactHeader reuseIdentifier] forIndexPath:indexPath];
			v.captionLabel.text = [NSLocalizedString(@"Recent Searches", nil) uppercaseString];
			return v;
			break;
		}
		case RTLocationSectionResults: {
			RTCompactHeader *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[RTCompactHeader reuseIdentifier] forIndexPath:indexPath];
			v.captionLabel.text = [NSLocalizedString(@"Location Search Results", nil) uppercaseString];
			return v;
			break;
		}
		default:
			break;
	}

	return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	//	get instance of cell
	RTBlockCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RTBlockCell reuseIdentifier] forIndexPath:indexPath];
	cell.captionLabel.textColor = [UIColor whiteColor];
	cell.contentView.backgroundColor = [UIColor clearColor];

	//	place to setup cell's label preferedWidth, if needed

	//	populate data
	switch ((RTLocationSection)indexPath.section) {
		case RTLocationSectionRecents: {
			cell.captionLabel.text = self.recentSearches[indexPath.item];
			break;
		}
		case RTLocationSectionResults: {
			MKPlacemark *placemark = self.searchResults[indexPath.item];
			cell.captionLabel.text = [self locationStringForPlacemark:placemark];
			break;
		}
		default: {
			break;
		}
	}

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RTBlockLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

	return CGSizeMake(collectionView.bounds.size.width, collectionViewLayout.itemSize.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RTBlockLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

	switch ((RTLocationSection)section) {
		case RTLocationSectionRecents: {
			if (self.autocompleteString.length > 0 || self.recentSearches.count == 0) return CGSizeZero;
			break;
		}
		case RTLocationSectionResults: {
			if (self.autocompleteString.length == 0 || self.searchResults.count == 0) return CGSizeZero;
			break;
		}
		default:
			break;
	}

	return CGSizeMake(collectionView.bounds.size.width, collectionViewLayout.headerReferenceSize.height);
}

#pragma mark Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];

	switch ((RTLocationSection)indexPath.section) {
		case RTLocationSectionRecents: {
			//	pickup recent search string
			NSString *searchString = [self.recentSearches[indexPath.item] lowercaseString];
			//	and re-use it
			self.searchField.text = searchString;
			[self initiateAutocompleteFor:searchString];

			break;
		}

		case RTLocationSectionResults: {
			MKPlacemark *placemark = self.searchResults[indexPath.item];
			self.currentLocationString = [self locationStringForPlacemark:placemark];
			self.currentLocation = placemark.location;

			if (self.parentViewController) {
				[self.delegate locationController:self didSelectString:self.currentLocationString location:self.currentLocation];
				[self deactivate];
			}

			break;
		}

		default:
			break;
	}
	return;
}

#pragma mark - Actions

- (IBAction)nearMeTapped:(UIButton *)sender {

	//	this should fetch current location and return that as location string
	//	but before that, it should check for CLLocationManager permissions and display proper error message if not given
}

- (IBAction)locationTapped:(UIButton *)sender {

	switch (self.displayMode) {
		case RTLocationDisplayModeDefault:
		case RTLocationDisplayModeLocationKnown: {
			self.displayMode = RTLocationDisplayModeTextFieldActive;
			if ([self.delegate respondsToSelector:@selector(locationControllerDidActivate:)]) {
				[self.delegate locationControllerDidActivate:self];
			}
			[self performLocalSearch];
			[self.collectionView reloadData];
			[self.searchField becomeFirstResponder];

			break;
		}
		case RTLocationDisplayModeTextFieldActive: {
			self.displayMode = (self.currentLocation) ? RTLocationDisplayModeLocationKnown : RTLocationDisplayModeDefault;
			if ([self.delegate respondsToSelector:@selector(locationControllerDidDeactivate:)]) {
				[self.delegate locationControllerDidDeactivate:self];
			}
			[self.searchField resignFirstResponder];
			[self.collectionView reloadData];

			break;
		}
	}

}

- (void)cancelSearch:(id)sender {

	self.searchResults = nil;
	self.searchField.text = nil;
	[self.collectionView reloadData];

	[self.searchField resignFirstResponder];
	[self.delegate locationControllerDidDeactivate:self];
}

/**
 *	called from parent controller
 */
- (void)deactivate {
	[self.searchField resignFirstResponder];
	[self.delegate locationControllerDidDeactivate:self];
}

- (void)search {
	[self initiateAutocompleteFor:self.autocompleteString];
}

@end
