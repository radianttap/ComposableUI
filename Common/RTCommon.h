//
//  RTCommon.h
//  ComposableUI
//
//  Created by Aleksandar Vacić on 2.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

@import Foundation;

/**
 *	Weakify / Strongify macros for breaking block retain cycles
 */
#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")

/**
 *	Common stuff. This should be included at the top of any .m file in the project
 */

//	dummy stuff for CocoaLumberjack.
//	Remove in actual app where you have the actual library
#define DDLogVerbose	NSLog
#define DDLogDebug		NSLog
#define DDLogInfo		NSLog
#define DDLogWarn		NSLog
#define DDLogError		NSLog
