//
//  MPMainViewController.m
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPMainViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "MPStorage.h"
#import "MPProject.h"
#import "ZipArchive.h"
#import "MPWebViewController.h"
#import "MBProgressHUD.h"
#import "MPSettingUtils.h"
#import "MPHelpViewController.h"


#define PROJECT_PATH @"PROJECTS"

#define kDocumentDictory    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kProjectDictory [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:PROJECT_PATH]
#define kLocalFileNameColor [UIColor colorWithRed:0.f green:110.f/256.f blue:255.f/256.f alpha:1]

@interface MPMainViewController (){
    NSMutableArray *_datas;
    NSMutableArray *_localFilesArray;
    NSMutableArray *_projectListArray;
    NSInteger _segmentIndex;
    NSString *_lastUnZip;
    
    NSTimer *_timer;
    
    NSString *_zipNeedPassword;
    NSString *_unZipFile;
    
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *help;
- (IBAction)helpPressed:(id)sender;


@end

@implementation MPMainViewController

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
    NSLog(@"APP PATH:%@",kDocumentDictory);
    
    NSDictionary *baseSetting = [NSDictionary dictionaryWithContentsOfFile:[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]];
    if (baseSetting==nil) {
        baseSetting = @{@"knowShaking": [NSNumber numberWithBool:NO],@"appVersion":kAppVersion};
    }
    if (![[baseSetting objectForKey:@"knowShaking"] boolValue]) {
        MPHelpViewController *helpController = [self.storyboard instantiateViewControllerWithIdentifier:@"help"];
        helpController.isFirstUse = YES;
        [self presentViewController:helpController animated:NO completion:nil];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    MPStorage *storage = [[MPStorage alloc]init];
    _segmentIndex = 0;
    _datas = _projectListArray = [NSMutableArray arrayWithArray: [storage getDatasWithLimit:10]];
    

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editPressed:)];
}

-(void)viewWillAppear:(BOOL)animated{
    if (_segmentIndex==1) {
        [self listenDocumentChange];
    }
    self.title = @"列表";
    
}
-(void)viewWillDisappear:(BOOL)animated{
    if (_segmentIndex==1) {
        [self stopListenDocumentChange];
    }
    self.title = @"返回";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)MD5:(NSString *)source
{
    const char *ptr = [source UTF8String];
    
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return output;
}
-(MBProgressHUD *)whiteHUD
{
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.color = [UIColor colorWithWhite:.95 alpha:1];
    hud.labelColor = [UIColor colorWithWhite:.1 alpha:1];

    return hud;
}
-(MBProgressHUD *)whiteHUDWithIndeterminate
{
    MBProgressHUD *hud=[self whiteHUD];
    hud.mode = MBProgressHUDModeCustomView;
    UIActivityIndicatorView *indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indView.color = [UIColor blackColor];
    [indView startAnimating];
    hud.customView = indView;
    return hud;
}

-(void)showWebView:(NSString *)path
{
    MPWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    
    [controller loadHtmlAtPath:path];
    //    [self.navigationController pushViewController:controller animated:YES];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (_segmentIndex) {
        case 0:
        {
            MPProject *project = (MPProject *)[_datas objectAtIndex:indexPath.row];
            cell.textLabel.text = project.name;
            cell.textLabel.textColor=[UIColor blackColor];
//            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//            [formatter setDateStyle:NSDateFormatterMediumStyle];
//            [formatter setTimeStyle:NSDateFormatterMediumStyle];
//            cell.detailTextLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:project.modifiedTime]];
            cell.detailTextLabel.textColor = [UIColor grayColor];

            if (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1) {
                //iOS 7 and later
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
            }else{
                [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
            }
        }
            break;
            
        default:
        {
            cell.textLabel.text = [_datas objectAtIndex:indexPath.row];
            cell.textLabel.textColor=kLocalFileNameColor;
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 文件", [cell.textLabel.text pathExtension]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
            break;
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError *error;
    NSFileManager *filemanager;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        switch (_segmentIndex) {
            case 0:
            {
                filemanager = [[NSFileManager alloc] init];
                MPProject *project = (MPProject *)[_projectListArray objectAtIndex:indexPath.row];
                
                if ([filemanager fileExistsAtPath:project.path]) {
                    
                    [HUD hide:NO];
                    
                    HUD = [self whiteHUDWithIndeterminate];
                    HUD.labelText = @"正在删除";
                    [HUD show:YES];
                    
                    [filemanager removeItemAtPath:project.path error:&error];
                    if (error) {
                        [HUD hide:NO];
                        
                        HUD = [self whiteHUD];
                        HUD.labelText = @"删除出错";
                        HUD.detailsLabelText = [NSString stringWithFormat:@"%@",error];
                        HUD.customView =[[UIImageView alloc] initWithImage: [UIImage imageNamed:@"SVProgressHUD.bundle/error-black.png"]];
                        HUD.mode = MBProgressHUDModeCustomView;
                        [HUD show:YES];
                        [HUD hide:YES afterDelay:3];
                        
                        NSLog(@"remove file error:%@",error);
//                        [[[UIAlertView alloc]initWithTitle:@"删除错误" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                    }else{
                        MPStorage *storage = [[MPStorage alloc] init];
                        [storage deleteData:project];
                        
                        [_projectListArray removeObjectAtIndex:indexPath.row];
                        _datas = _projectListArray;
                        
                        [HUD hide:NO];
                    }
                    
                }else{
                    
                    MPStorage *storage = [[MPStorage alloc] init];
                    [storage deleteData:project];
                    [_projectListArray removeObjectAtIndex:indexPath.row];
                    _datas = _projectListArray;
                }
            }
                break;
                
            default:
            {
                [HUD hide:NO];
                
                HUD = [self whiteHUDWithIndeterminate];
                HUD.labelText = @"正在删除";
                [HUD show:YES];
                
                [self stopListenDocumentChange];
                filemanager = [[NSFileManager alloc] init];
                [filemanager removeItemAtPath:[kDocumentDictory stringByAppendingPathComponent:[_localFilesArray objectAtIndex:indexPath.row]] error:&error];
                [_localFilesArray removeObjectAtIndex:indexPath.row];
                _datas = _localFilesArray;
                [self listenDocumentChange];
                [HUD hide:NO];
            }
                break;
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_segmentIndex) {
        case 0:
        {
            MPProject *project = (MPProject *)[_projectListArray objectAtIndex:indexPath.row];
            
            if (project.path) {
                [self showWebView:project.path];
            }

        }
            break;
            
        case 1:
        {
            if (NSFoundationVersionNumber<=NSFoundationVersionNumber_iOS_6_1) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.textLabel.textColor = [UIColor whiteColor];
            }
            
            NSString *file = [_localFilesArray objectAtIndex:indexPath.row];
            if ([[file pathExtension] isEqualToString:@"zip"]) {
                
                _unZipFile = [kDocumentDictory stringByAppendingPathComponent:file];
                
                MPStorage *storage = [[MPStorage alloc] init];
                
                NSString *query = [NSString stringWithFormat:@"select * from %@ where %@ = ? limit 1;",TABLE_NAME,FIELD_ZIP];
                
                FMResultSet *rs = [storage.db executeQuery:query,_unZipFile];
                NSString *title,*message;
                if ([rs next]) {

                    _lastUnZip = [rs objectForColumnName:FIELD_PATH];
                    title = @"重新生成";
                    message = [[@"已有原型“" stringByAppendingString:[file stringByDeletingPathExtension]] stringByAppendingString:@"”，\n重新生成将覆盖原有文件，\n是否重新生成？"];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新生成",@"直接预览", nil];
                    alert.tag = 30;
                    [alert show];
                    
                    [storage.db closeOpenResultSets];
                    NSLog(@"last:%@",_lastUnZip);
                }else{
                    
                    [storage.db closeOpenResultSets];
                    
                    [HUD hide:NO];
                    HUD = [self whiteHUDWithIndeterminate];

                    HUD.labelText = @"正在生成";
                    [HUD show:YES];
                    
                    [self unZipFile:_unZipFile withPassword:nil];
                    _unZipFile = nil;
                }

            }
        }
            break;
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_segmentIndex==1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = kLocalFileNameColor;
    }
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (_segmentIndex==0) {
        MPSettingViewController *controller = (MPSettingViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
        
        MPProject *project = (MPProject *)[_projectListArray objectAtIndex:indexPath.row];
        
        if (project.path) {
            controller.path = project.path;
        }
        self.title = @"返回";
        [self.navigationController pushViewController:controller animated:YES];

    }
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 48.0f;
//}
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

#pragma mark - utils

-(NSArray *)listFileAtPath:(NSString *)path
{
    
    //-----> LIST ALL FILES <-----//
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    
/*
//    NSLog(@"LISTING ALL FILES FOUND");
    int count;
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *file = [directoryContent objectAtIndex:count];
        NSLog(@"File %d :%@", (count + 1), file);
    }
*/
    return directoryContent;
}
-(void)unZipFile:(NSString *)file withPassword:(NSString *)password
{
//    __block int count;
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//    NSString *projectPath = [[paths firstObject] stringByAppendingPathComponent:PROJECT_PATH];
    
    NSString *projectPath = kProjectDictory;
//    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    
    if (_segmentIndex==1) {
        [self stopListenDocumentChange];
    }
    
    dispatch_queue_t queue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
    
        BOOL isUnZiped = NO;
        ZipArchive *zip = [[ZipArchive alloc] init];
        _zipNeedPassword = nil;
        if ([[file pathExtension] isEqualToString:@"zip"]) {
            if (password) {
                isUnZiped = [zip UnzipOpenFile:file Password:password];
            }else{
                isUnZiped = [zip UnzipOpenFile:file];
            }
            if (!isUnZiped && !password) {
                if ([zip UnzipIsEncrypted]) {
                    NSLog(@"needPassword:%@",file);
                    _zipNeedPassword = file;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [HUD hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码保护" message:@"请输入解压密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"解压", nil];
                        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        [alert show];
                    });
                }else{
                    NSLog(@"unzip failed");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [HUD hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"解压错误" message:@"文件无法解压" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
                        [alert show];
                    });
                }
            }else if(!isUnZiped && password){
                
                NSLog(@"retype password:%@",file);
                _zipNeedPassword = file;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"解压密码错误" message:@"请输入正确的解压密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"解压", nil];
                    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    [alert show];
                });
            }else{
                NSString *currentProjectPath = [projectPath stringByAppendingPathComponent:[self MD5:file]];
                if([zip UnzipFileTo:currentProjectPath overWrite:YES])
                {
                    NSString *fileName = [file lastPathComponent];
                    
                    MPProject *project = [[MPProject alloc]init];
                    project.name = [fileName stringByDeletingPathExtension];
                    project.path = currentProjectPath;
                    project.zip = file;
                    project.modifiedTime = [[NSDate date] timeIntervalSince1970];
                    MPStorage *storage = [[MPStorage alloc] init];
//                    NSLog(@"project:%@",project);
                    
                    NSInteger rowId=0;
                    NSString *query = [NSString stringWithFormat:@"select * from %@ where %@ = ? limit 1;",TABLE_NAME,FIELD_ZIP];
                    FMResultSet *rs = [storage.db executeQuery:query,file];

                    if ([rs next]) {
                        project.idx = [rs longForColumn:FIELD_ID];
                        rowId = [storage updateData:project];
                    }else{
                        rowId = [storage insertData:project];
                        project.idx = rowId;
                        if(rowId>0){
                            [_projectListArray insertObject:project atIndex:0];
                        }
                    }
                    [storage.db closeOpenResultSets];
//                    [self listFileAtPath:currentProjectPath];// FOR testing
                    NSLog(@"unzip successed! row id:%ld",(long)rowId);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HUD hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"生成成功" message:@"马上去预览吧！" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"去预览", nil];
                        alert.tag = 10;
                        _lastUnZip = currentProjectPath;
                        [alert show];
                    });
//                    NSLog(@"UnZipFile %@ to %@", file,currentProjectPath);
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self listenDocumentChange];
            });
        }
    
    });
    
}

-(void)listenDocumentChange
{
    if (_timer!=nil) {
        [_timer invalidate];
    }

    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerTicked:) userInfo:nil repeats:NO];

}
-(void)stopListenDocumentChange
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
-(void)timerTicked:(NSTimer *)timer
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *newArray = [self listFileAtPath:kDocumentDictory];
        
//        NSLog(@"file changed:%ld,%ld",(unsigned long)[newArray count],(unsigned long)[_localFilesArray count]);
        if ([newArray count]!=[_localFilesArray count]) {
            _localFilesArray = [NSMutableArray arrayWithArray:newArray];
            _datas = _localFilesArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (_segmentIndex==1) {
                [self listenDocumentChange];
            }
        });
    });
}

- (IBAction)segmentedChange:(id)sender {
    UISegmentedControl *segmented = (UISegmentedControl *) sender;
    [self switchToTableList:segmented.selectedSegmentIndex];
    if (self.tableView.isEditing) {
        [self editPressed:self.navigationItem.rightBarButtonItem];
    }
}
-(void)switchToTableList:(NSInteger)tag
{
    
    switch (tag) {
        case 0:
        {
            _datas = _projectListArray;
            [self stopListenDocumentChange];
        }
            break;
            
        default:
            if (_localFilesArray==nil) {
                _localFilesArray = [NSMutableArray arrayWithArray:[self listFileAtPath:kDocumentDictory]];
            }
            [self listenDocumentChange];
            _datas = _localFilesArray;
            break;
    }
    _segmentIndex = tag;
    NSInteger animation = _segmentIndex==0? UITableViewRowAnimationRight:UITableViewRowAnimationLeft;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_lastUnZip && alertView.tag == 30 && buttonIndex ==2){
        [self showWebView:_lastUnZip];
        _lastUnZip = nil;
        return;
    }
    switch (buttonIndex) {
        case 1:
        {
            if (_zipNeedPassword) {
                
                [HUD hide:NO];
                HUD = [self whiteHUDWithIndeterminate];
                HUD.labelText = @"正在生成";
                [HUD show:YES];
                
                [self unZipFile:_zipNeedPassword withPassword:[alertView textFieldAtIndex:0].text];
                _zipNeedPassword = nil;
            }else if(_unZipFile && (alertView.tag == 20 || alertView.tag == 30)){
                
                [HUD hide:NO];
                HUD = [self whiteHUDWithIndeterminate];
                HUD.labelText = @"正在生成";
                [HUD show:YES];
                
                [self unZipFile:_unZipFile withPassword:nil];
                _unZipFile = nil;
                
            }else if(_lastUnZip && alertView.tag ==10){

                [self showWebView:_lastUnZip];
            }
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - rotation
-(BOOL)shouldAutorotate
{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - button
- (IBAction)helpPressed:(id)sender {
    self.title = @"返回";
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"help"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)editPressed:(id)sender {
    if (self.tableView.editing) {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editPressed:)];
        self.navigationItem.rightBarButtonItem.title = @"编辑";
        [self.tableView setEditing:NO animated:YES];
    }else{
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem.title = @"完成";
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(editPressed:)];
    }
}
@end
