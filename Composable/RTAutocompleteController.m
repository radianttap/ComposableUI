//
//  RTAutocompleteController.m
//  ComposableUI
//
//  Created by Aleksandar Vacić on 5.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTCommon.h"

#import "RTAutocompleteController.h"
#import "RTBlockLayout.h"
#import "RTBlockCell.h"
#import "RTCompactHeader.h"

typedef NS_ENUM(NSInteger, RTAutocompleteSection) {
	RTAutocompleteSectionRecents = 0,
	RTAutocompleteSectionResults,
	RTAutocompleteSectionsCOUNT
};

@interface RTAutocompleteController () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSLayoutConstraint *verticalSpacingConstraint;

@property (nonatomic, strong, nullable) NSArray< NSString * > *recentSearches;
@property (nonatomic, strong, nullable) NSArray< NSString* > *searchResults;

@end

@implementation RTAutocompleteController

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (instancetype)init {

	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if (!self) return nil;

	self.automaticallyAdjustsScrollViewInsets = NO;

	_verticalSpace = 0;
	_delegate = nil;
	_autocompleteString = nil;
	_recentSearches = @[
						@"old result 1",
						@"another result 3",
						@"previous result 3",
						@"more results..."
						];
	_searchResults = @[
					 @"Assistance",
					 @"Aspect Ratio",
					 @"Asteroid",
					 @"As...",
					 @"As...",
					 @"As...",
					 @"As...",
					 @"As...",
					 ];

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

	//	add loupe icon to the text field
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 18)];
	iv.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
	iv.contentMode = UIViewContentModeScaleAspectFit;
	iv.image = [UIImage imageNamed:@"loupe"];
	self.searchField.leftView = iv;
	self.searchField.leftViewMode = UITextFieldViewModeAlways;

	self.searchField.text = self.autocompleteString;
	[self.collectionView registerNib:[RTBlockCell nib] forCellWithReuseIdentifier:[RTBlockCell reuseIdentifier]];
	[self.collectionView registerNib:[RTCompactHeader nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[RTCompactHeader reuseIdentifier]];
}

- (void)initiateAutocompleteFor:(NSString *)searchString {

	self.autocompleteString = searchString;
	[self.collectionView reloadData];
}


#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {

	if (self.parentViewController) {
		[self.delegate autocompleteControlerDidActivate:self];
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
			[self.delegate autocompleteControlerDidDeactivate:self];
		} else {
			[self.delegate autocompleteControler:self didSelectSearchString:self.autocompleteString];
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

	return RTAutocompleteSectionsCOUNT;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

	switch ((RTAutocompleteSection)section) {
		case RTAutocompleteSectionRecents: {
			return (self.autocompleteString.length == 0) ? self.recentSearches.count : 0;
			break;
		}
		case RTAutocompleteSectionResults: {
			return (self.autocompleteString.length == 0) ? 0 : self.searchResults.count;
			break;
		}
		default:
			break;
	}
	return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

	switch ((RTAutocompleteSection)indexPath.section) {
		case RTAutocompleteSectionRecents: {
			RTCompactHeader *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[RTCompactHeader reuseIdentifier] forIndexPath:indexPath];
			v.captionLabel.text = [NSLocalizedString(@"Recent Searches", nil) uppercaseString];
			return v;
			break;
		}
		case RTAutocompleteSectionResults: {
			RTCompactHeader *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[RTCompactHeader reuseIdentifier] forIndexPath:indexPath];
			v.captionLabel.text = [NSLocalizedString(@"Autocomplete Results", nil) uppercaseString];
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
	cell.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.17];

	//	place to setup cell's label preferedWidth, if needed

	//	populate data
	switch ((RTAutocompleteSection)indexPath.section) {
		case RTAutocompleteSectionRecents: {
			cell.captionLabel.text = self.recentSearches[indexPath.item];
			break;
		}
		case RTAutocompleteSectionResults: {
			cell.captionLabel.text = self.searchResults[indexPath.item];
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

	switch ((RTAutocompleteSection)section) {
		case RTAutocompleteSectionRecents: {
			if (self.autocompleteString.length > 0 || self.recentSearches.count == 0) return CGSizeZero;
			break;
		}
		case RTAutocompleteSectionResults: {
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

	switch ((RTAutocompleteSection)indexPath.section) {
		case RTAutocompleteSectionRecents: {
			//	pickup recent search string
			NSString *searchString = [self.recentSearches[indexPath.item] lowercaseString];

			self.autocompleteString = searchString;
			self.searchField.text = searchString;

			[self initiateAutocompleteFor:searchString];

			break;
		}

		case RTAutocompleteSectionResults: {
			NSString *searchString = self.searchResults[indexPath.item];

			self.autocompleteString = searchString;
			self.searchField.text = searchString;

			if (self.parentViewController) {
				[self.delegate autocompleteControler:self didSelectSearchString:searchString];
				[self.searchField resignFirstResponder];
			}

			break;
		}

		default:
			break;
	}
	return;
}

#pragma mark - Actions

- (void)cancelSearch:(id)sender {

	self.searchResults = nil;
	self.autocompleteString = nil;
	self.searchField.text = nil;
	[self.collectionView.collectionViewLayout invalidateLayout];
	[self.collectionView reloadData];

	self.navigationItem.rightBarButtonItem = nil;
	[self.searchField resignFirstResponder];
}

/**
 *	called from parent controller
 */
- (void)deactivate {
	[self.searchField resignFirstResponder];
}

- (void)search {
	[self initiateAutocompleteFor:self.autocompleteString];
}

@end
