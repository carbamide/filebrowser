//
//  FBFilesTableViewController.m
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 18/06/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//

#import "FBFilesTableViewController.h"

@interface FBFilesTableViewController ()

@end

@implementation FBFilesTableViewController

- (id)initWithPath:(NSString *)path
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        [self setPath:path];
        [self setTitle:[path lastPathComponent]];
        
		NSError *error = nil;
        
        [self setFiles:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error]];
		
		if (error) {
			NSLog(@"ERROR: %@", error);
			
			if ([error code] == 257) {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:[error localizedDescription]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                
                [errorAlert show];
            }
            
            
		}
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self files] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
    
	NSString *newPath = [[self path] stringByAppendingPathComponent:[self files][[indexPath row]]];
	
	BOOL isDirectory;
	BOOL fileExists = [[NSFileManager defaultManager ] fileExistsAtPath:newPath isDirectory:&isDirectory];
	
    [[cell textLabel] setText:[self files][[indexPath row]]];
	
	if (fileExists && !isDirectory) {
        [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
        [[cell imageView] setImage:[UIImage imageNamed:@"document"]];
    }
	else if (isDirectory) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [[cell imageView] setImage:[UIImage imageNamed:@"folder"]];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSString *newPath = [[self path] stringByAppendingPathComponent:[self files][[indexPath row]]];
	
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[newPath lastPathComponent]];
	
	NSError *error = nil;
	
	[[NSFileManager defaultManager] copyItemAtPath:newPath toPath:tmpPath error:&error];
	
	if (error) {
		NSLog(@"ERROR: %@", error);
	}
    
	UIActivityViewController *shareActivity = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:tmpPath]] applicationActivities:nil];
	
    [shareActivity setCompletionHandler:^(NSString *activityType, BOOL completed){
		[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    }];
    
    
    [[self navigationController] presentViewController:shareActivity animated:YES completion:^{
        
    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *newPath = [[self path] stringByAppendingPathComponent:[self files][[indexPath row]]];
	
	BOOL isDirectory;
	BOOL fileExists = [[NSFileManager defaultManager ] fileExistsAtPath:newPath isDirectory:&isDirectory];
	
	if (fileExists) {
		if (isDirectory) {
			FBFilesTableViewController *vc = [[FBFilesTableViewController alloc] initWithPath:newPath];
			[[self navigationController] pushViewController:vc animated:YES];
		}
		else {
			QLPreviewController *preview = [[QLPreviewController alloc] init];
            [preview setDataSource:self];
			
			[[self navigationController] pushViewController:preview animated:YES];
		}
	}
}

#pragma mark - QuickLook

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return YES;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index
{
	NSString *newPath = [[self path] stringByAppendingPathComponent:[self files][[[[self tableView] indexPathForSelectedRow] row]]];
	
    return [NSURL fileURLWithPath:newPath];
}

@end
