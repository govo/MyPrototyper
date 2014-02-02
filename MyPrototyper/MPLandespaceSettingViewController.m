//
//  MPLandespaceSettingViewController.m
//  MyPrototyper
//
//  Created by govo on 14-1-18.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPLandespaceSettingViewController.h"

@interface MPLandespaceSettingViewController (){
    NSInteger _lastSelected;
}

@end

@implementation MPLandespaceSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    switch (self.orientation) {
        case UIInterfaceOrientationMaskPortrait:
            _lastSelected = 0;
            break;
        case UIInterfaceOrientationMaskLandscape:
        case UIInterfaceOrientationMaskLandscapeLeft:
        case UIInterfaceOrientationMaskLandscapeRight:
            _lastSelected = 1;
            break;
        case UIInterfaceOrientationMaskAll:
        case UIInterfaceOrientationMaskAllButUpsideDown:
            _lastSelected = 2;

    }
    NSLog(@"orientation:%ld",(long)_lastSelected);
    
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    
//    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSelected inSection:0]];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == _lastSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSelected inSection:0]];
    lastCell.accessoryType=UITableViewCellAccessoryNone;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _lastSelected = indexPath.row;
    if (self.delegate) {
        switch (indexPath.row) {
            case 0:
                [self.delegate didSelected:UIInterfaceOrientationMaskPortrait];
                break;
            case 1:
                [self.delegate didSelected:UIInterfaceOrientationMaskLandscapeLeft];
                break;
            case 2:
                [self.delegate didSelected:UIInterfaceOrientationMaskAllButUpsideDown];
                break;
        }
    }
}



@end
