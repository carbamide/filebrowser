//
//  FBAppDelegate.m
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 18/06/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//

#import "FBAppDelegate.h"
#import "FBFilesTableViewController.h"

#include <sys/stat.h>

NSString *startingPath = @"/";

@implementation FBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    
    [[self window] setBackgroundColor:[UIColor whiteColor]];
    [[self window] makeKeyAndVisible];
	
	FBFilesTableViewController *startingVC = [[FBFilesTableViewController alloc] initWithPath:startingPath];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:startingVC];
	
    [[self window] setRootViewController:navController];
	
    return YES;
}

@end
