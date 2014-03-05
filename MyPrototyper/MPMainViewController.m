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
#import "MPDevice.h"
#import "MPAVObject.h"


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

@property (strong,nonatomic) UIView *emptyView;

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
    
    NSDictionary *globalSetting = [MPSettingUtils globalSetting];
    
    if ([[globalSetting objectForKey:kSettingIsFirstUse] boolValue]) {
        MPHelpViewController *helpController = [self.storyboard instantiateViewControllerWithIdentifier:@"help"];
        helpController.isFirstUse = YES;
        [self presentViewController:helpController animated:NO completion:nil];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSString *exampleFilename = NSLocalizedString(@"Prototyper Example", nil);
        
        NSString *examplePath =[kDocumentDictory stringByAppendingPathComponent:[exampleFilename stringByAppendingPathExtension:@"zip"]];
        if (![fileManager fileExistsAtPath:examplePath]) {
            [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Prototyper Example" ofType:@"zip"] toPath:examplePath error:nil];
        }
        
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    MPStorage *storage = [[MPStorage alloc]init];
    _segmentIndex = 0;
    _datas = _projectListArray = [NSMutableArray arrayWithArray: [storage getDatasWithLimit:10]];
    if (_datas.count == 0) {
        _segmentIndex = 1;
        [self switchToTableList:_segmentIndex];
        self.segment.selectedSegmentIndex = _segmentIndex;
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Edit",@"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed:)];

    
    /*
    
    NSInteger luanchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"luanchCount"];
    luanchCount ++;
    NSInteger appVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue];
    NSInteger lastCommentVersion = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastCommentVersion"];
    [[NSUserDefaults standardUserDefaults]setInteger:luanchCount forKey:@"luanchCount"];
    if (luanchCount>0 && luanchCount%8==0 && lastCommentVersion<appVersion) {
        NSLog(@"luanch count:%ld",(long)luanchCount);
        
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"rateTitle", nil) message:NSLocalizedString(@"rateMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"rateNotNow", nil) otherButtonTitles:NSLocalizedString(@"rateYes",nil),NSLocalizedString(@"rateRefuce", nil), nil];
    alert.tag = 8888;
    [alert show];
    NSLog(@"luanch count:%ld,version:%d,%d",(long)luanchCount,appVersion,lastCommentVersion);
    */
    
    //UUID:http://www.doubleencore.com/2013/04/unique-identifiers/
    //http://kensou.blog.51cto.com/3495587/1249734
    //企业证书不能保存keychain
    //http://blog.k-res.net/archives/1081.html
    //http://www.cnblogs.com/smileEvday/p/UDID.html
    
    /*
    AVObject *previewCounter = [MPAVObject previewCounter];
    [previewCounter incrementKey:KEY_AV_COUNT];
    [previewCounter saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"increased");
        }else{
            NSLog(@"increase failed:%@",error);
        }
    }];
     */
    
}

-(void)viewWillAppear:(BOOL)animated{
    if (_segmentIndex==1) {
        [self listenDocumentChange];
    }
    self.title = NSLocalizedString(@"List", nil);
    
}
-(void)viewWillDisappear:(BOOL)animated{
    if (_segmentIndex==1) {
        [self stopListenDocumentChange];
    }
    self.title = NSLocalizedString(@"Back", nil);
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

-(void)emptyButtonTouched:(id)sender
{
    self.segment.selectedSegmentIndex=1;
    [self switchToTableList:1];
}
-(void)addEmptyHeader:(UITableView *)tableView
{

    UIView *emptyView = [[[NSBundle mainBundle] loadNibNamed:@"EmptyView" owner:self options:nil] firstObject];
    tableView.scrollEnabled = NO;
    emptyView.frame = CGRectMake(0, 0, tableView.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height);

    switch (_segmentIndex) {
        case 0:
        {
            if (_localFilesArray==nil) {
                _localFilesArray = [NSMutableArray arrayWithArray:[self listFileAtPath:kDocumentDictory]];
            }
            if (_localFilesArray!=nil && _localFilesArray.count==0) {
                
                [emptyView viewWithTag:1].hidden = YES;
            }else{
                
                [emptyView viewWithTag:2].hidden = YES;
                UIView *view = [[emptyView viewWithTag:1] viewWithTag:3];
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)view;
                    [button addTarget:self action:@selector(emptyButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            
        }
            break;
        case 1:
            [emptyView viewWithTag:1].hidden = YES;

    }
    [tableView setTableHeaderView:emptyView];
    
}
-(void)removeEmptyHeader:(UITableView *)tableView
{
    tableView.tableHeaderView = nil;
    tableView.scrollEnabled = YES;
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
//            cell.detailTextLabel.textColor = [UIColor grayColor];

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
                    HUD.labelText = NSLocalizedString(@"Deleting", nil);
                    [HUD show:YES];
                    
                    [filemanager removeItemAtPath:project.path error:&error];
                    if (error) {
                        [HUD hide:NO];
                        
                        HUD = [self whiteHUD];
                        HUD.labelText = NSLocalizedString(@"Deleting Error occurred", nil);
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
                HUD.labelText = NSLocalizedString(@"Deleting", nill);
                [HUD show:NO];
                
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
        
        if (_datas.count==0) {
            if (self.tableView.isEditing) {
                [self editPressed:self.navigationItem.rightBarButtonItem];
            }
            [tableView reloadData];
            [self addEmptyHeader:tableView];
        }else{
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
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
                    title = NSLocalizedString(@"Re-Unzip",nil);
                    message =
                    [NSString stringWithFormat:NSLocalizedString(@"\"%@\" exists,\nOverwrite?",nil),[file stringByDeletingPathExtension] ,nil];
//                    [[@"已有原型“" stringByAppendingString:[file stringByDeletingPathExtension]] stringByAppendingString:@"”，\n重新解压将覆盖原有文件，\n是否重新解压？"];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") otherButtonTitles:NSLocalizedString(@"Re-Unzip",nil),NSLocalizedString(@"Just Preview",nil), nil];
                    alert.tag = 30;
                    [alert show];
                    
                    [storage.db closeOpenResultSets];
//                    NSLog(@"last:%@",_lastUnZip);
                }else{
                    
                    [storage.db closeOpenResultSets];
                    
                    [HUD hide:NO];
                    HUD = [self whiteHUDWithIndeterminate];

                    HUD.labelText = NSLocalizedString(@"Unziping",nil);
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
        [self.navigationController pushViewController:controller animated:YES];

    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}
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
    return [directoryContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] %@",@"zip"]];
}
-(void)unZipFile:(NSString *)file withPassword:(NSString *)password
{
    
    NSString *projectPath = kProjectDictory;

    [self stopListenDocumentChange];

    
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
            NSLog(@"Do here?%@",isUnZiped?@"yes":@"no");
            if (isUnZiped) {
                BOOL needPassworld =[zip UnzipIsEncrypted];
                if (needPassworld && !password) {
                    NSLog(@"needPassword:%@",file);
                    _zipNeedPassword = file;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [HUD hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Protection",nil) message:NSLocalizedString(@"passwordTips", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Unzip","@Unzip"), nil];
                        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        [alert show];
                        
                        [self listenDocumentChange];
                    });
                    return;
                }
                //Unzip to File
                NSString *currentProjectPath = [projectPath stringByAppendingPathComponent:[self MD5:file]];
                
                if([zip UnzipFileTo:currentProjectPath overWrite:YES]){
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
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unzip Successful!",nil) message:NSLocalizedString(@"Preview now?", @"Preview it!") delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil) otherButtonTitles:NSLocalizedString(@"Do Preview", nil), nil];
                        alert.tag = 10;
                        _lastUnZip = currentProjectPath;
                        [alert show];
                        
                        [self listenDocumentChange];
                    });
                    //                    NSLog(@"UnZipFile %@ to %@", file,currentProjectPath);
                }else if(needPassworld && password){
                    
                    NSLog(@"retype password:%@",file);
                    _zipNeedPassword = file;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [HUD hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password not correct", @"Wrong Password") message:NSLocalizedString(@"Please Input the Correct Password", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") otherButtonTitles:NSLocalizedString(@"Unzip", @"Unzip"), nil];
                        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        [alert show];
                        
                        [self listenDocumentChange];
                    });
                    return;
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [HUD hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unzip Error occurred", nil) message:NSLocalizedString(@"Unable To Unzip File",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"好") otherButtonTitles: nil];
                        [alert show];
                        
                        [self listenDocumentChange];
                    });
                    return;
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unzip Error occurred", nil) message:NSLocalizedString(@"canNotUnzip", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"好") otherButtonTitles: nil];
                    [alert show];
                    
                    [self listenDocumentChange];
                });
            }
         
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
                if (_localFilesArray.count>0) {
                    [self removeEmptyHeader:self.tableView];
                }
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
    if (self.tableView.isEditing) {
        [self editPressed:self.navigationItem.rightBarButtonItem];
    }
    UISegmentedControl *segmented = (UISegmentedControl *) sender;
    [self switchToTableList:segmented.selectedSegmentIndex];
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
    if (_datas.count==0) {
        [self addEmptyHeader:self.tableView];
    }else{
        [self removeEmptyHeader:self.tableView];
    }
    [self.tableView reloadData];
    NSInteger animation = _segmentIndex==0? UITableViewRowAnimationRight:UITableViewRowAnimationLeft;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==8888) {
        return;
    }
    
    NSString *unziping = NSLocalizedString(@"Unziping",nil);
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
                HUD.labelText = unziping;
                [HUD show:YES];
                
                [self unZipFile:_zipNeedPassword withPassword:[alertView textFieldAtIndex:0].text];
                _zipNeedPassword = nil;
            }else if(_unZipFile && (alertView.tag == 20 || alertView.tag == 30)){
                
                [HUD hide:NO];
                HUD = [self whiteHUDWithIndeterminate];
                HUD.labelText = unziping;
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
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"help"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)editPressed:(id)sender {
    if (self.tableView.editing) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Edit",@"Edit");
        [self.tableView setEditing:NO animated:YES];
    }else{
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done",@"Done");
    }
}
@end
