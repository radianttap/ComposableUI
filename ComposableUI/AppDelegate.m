//
//  AppDelegate.m
//  ComposableUI
//
//  Created by Aleksandar Vacić on 2.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTCommon.h"

#import "AppDelegate.h"

#import "RTViewController.h"
#import "RTAutocompleteController.h"
#import "RTLocationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	DDLogVerbose(@"App will finish lanching");
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	RTViewController *vc = [RTViewController new];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
	self.window.rootViewController = nc;

	//	comment out the part above
	//	uncomment any one of the controllers below, to test them independently

//	RTAutocompleteController *vc = [RTAutocompleteController new];
//	self.window.rootViewController = vc;

//	RTLocationController *vc = [RTLocationController new];
//	self.window.rootViewController = vc;

	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	DDLogVerbose(@"App did finish lanching");

	[self.window makeKeyAndVisible];
	return YES;
}

@end
