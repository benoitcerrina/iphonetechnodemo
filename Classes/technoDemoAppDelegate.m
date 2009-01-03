//
//  technoDemoAppDelegate.m
//  technoDemo
//
//  Created by Benoit Cerrina on 8/16/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "technoDemoAppDelegate.h"


@implementation technoDemoAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
}


/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

