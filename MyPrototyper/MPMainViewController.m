//
//  MPMainViewController.m
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPMainViewController.h"
#import <CoreMotion/CoreMotion.h>
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

#define kAlertTagReUnzip            30
#define kAlertTagUnzipSuccessed     10



@interface MPMainViewController (){
    NSMutableArray *_datas;
    NSMutableArray *_localFilesArray;
    NSMutableArray *_projectListArray;
    NSInteger _segmentIndex;
    NSString *_lastUnZip;
    
    NSTimer *_timer;
    
    NSString *_zipNeedPassword;
    NSString *_unZipFile;
    BOOL _isReunzip;
    
    MBProgressHUD *HUD;
    
    NSString *_exampleZip;
    NSString *_exampleName;
    
    NSString *_viewName;

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
    if (APP_DEBUG) {
        NSLog(@"APP_DEBUG,now is DEBUG version>>>===========================================");
    }
    NSLog(@"APP PATH:%@",kDocumentDictory);
    _viewName = @"Main";
    
    
    _exampleName = nil;
    _exampleZip = nil;
    
    NSDictionary *globalSetting = [MPSettingUtils globalSetting];
    
    if ([[globalSetting objectForKey:kSettingIsFirstUse] boolValue]) {
        MPHelpViewController *helpController;
        helpController = [[MPHelpViewController alloc]initWithNibName:@"HelpView" bundle:nil];
        
        helpController.isFirstUse = YES;
        [self presentViewController:helpController animated:NO completion:nil];
    }
#if 0
    
    //Example ready
    NSString *exampleFilename = NSLocalizedString(@"Prototyper Example", nil);
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *examplePath =[cachePath stringByAppendingPathComponent:[exampleFilename stringByAppendingPathExtension:@"zip"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([[globalSetting objectForKey:kSettingIsFirstUse] boolValue]) {
        MPHelpViewController *helpController = [self.storyboard instantiateViewControllerWithIdentifier:@"help"];
        helpController.isFirstUse = YES;
        [self presentViewController:helpController animated:NO completion:nil];
        

        _exampleName = exampleFilename;
        _exampleZip = examplePath;
        
        if (![fileManager fileExistsAtPath:examplePath]) {
            [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Prototyper Example" ofType:@"zip"] toPath:examplePath error:nil];
        }
        
    }else if([fileManager fileExistsAtPath:examplePath]){
        
        _exampleName = exampleFilename;
        _exampleZip = examplePath;
    }
#endif
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Edit",@"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed:)];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    MPStorage *storage = [[MPStorage alloc]init];
    _segmentIndex = 0;
    _datas = _projectListArray = [NSMutableArray arrayWithArray: [storage getDatasWithLimit:500]];
    if (_datas.count == 0){
        self.navigationItem.rightBarButtonItem.enabled = NO;
        _segmentIndex = 1;
        [self switchToTableList:_segmentIndex];
        self.segment.selectedSegmentIndex = _segmentIndex;
    }


    
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
//    TEST
//    [MPAVObject previewCounterWithEvent:kAVObjectPreviewCounterEventFromZip];
//    [MPAVObject unzipCounterWithEvent:kAVObjectReUnzip hasPwd:NO];
//    [MPAVObject onTapedWithEvent:KEY_AV_RESULT data:@"good"];
    
    //user auto login
//    [MPAVObject userAutoLogin];
    
//    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Feedback"];
//    [self.navigationController pushViewController:vc animated:YES];
    
    
#if 0
    
    Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
    NSString *deviceID = nil;
    if(cls && [cls respondsToSelector:deviceIDSelector]){
        deviceID = [cls performSelector:deviceIDSelector];
    }
    NSLog(@"{\"oid\": \"%@\"}", deviceID);

#endif

}


-(void)viewWillAppear:(BOOL)animated{
    if (_segmentIndex==1) {
        [self listenDocumentChange];
    }
    self.title = NSLocalizedString(@"List", nil);
    [MPAVObject beginLogPageView:_viewName];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    if (_segmentIndex==1) {
        [self stopListenDocumentChange];
    }
    self.title = NSLocalizedString(@"Back", nil);
    [MPAVObject endLogPageView:_viewName];
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
            //检查是否存在压缩包，如果存在，提示用户可以去解压，否则提示用户可以传输文件
            if (_localFilesArray==nil) {
                _localFilesArray = [NSMutableArray arrayWithArray:[self listFileAtPath:kDocumentDictory]];
                if (_exampleZip) {
                    [_localFilesArray insertObject:_exampleZip atIndex:0];
                }
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
            if ([project.path rangeOfString:kProjectDictory].location!=NSNotFound) {
                cell.textLabel.textColor=[UIColor blackColor];
            }else{
                cell.textLabel.textColor = [UIColor darkGrayColor];
            }
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
            NSString *file = [_datas objectAtIndex:indexPath.row];
            if (_exampleZip && [file isEqualToString:_exampleZip]) {
                file = _exampleName;
                cell.textLabel.textColor = [UIColor darkGrayColor];
            }else{
                cell.textLabel.textColor=kLocalFileNameColor;
            }
            cell.textLabel.text = file;
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 文件", [cell.textLabel.text pathExtension]];
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
            break;
    }
    if (NSFoundationVersionNumber<=NSFoundationVersionNumber_iOS_6_1) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
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
                NSString *filename = [_localFilesArray objectAtIndex:indexPath.row];
                if (_exampleZip && [filename isEqualToString:_exampleZip]) {
                    [filemanager removeItemAtPath:_exampleZip error:&error];
                    _exampleZip = nil;
                    _exampleName = nil;
                }else{
                    [filemanager removeItemAtPath:[kDocumentDictory stringByAppendingPathComponent:filename] error:&error];
                }
                [_localFilesArray removeObjectAtIndex:indexPath.row];
                _datas = _localFilesArray;
                [self listenDocumentChange];
                [HUD hide:NO];
            }
                break;
        }
        [self.navigationItem.rightBarButtonItem setEnabled:_datas.count>0];
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
                
                [self updateOVAObjectPreviewWithEvent:kAVObjectPreviewCounterEventFromRow];
                
                [self showWebView:project.path];
            }

        }
            break;
            
        case 1:
        {
//            if (NSFoundationVersionNumber<=NSFoundationVersionNumber_iOS_6_1) {
//                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//                cell.textLabel.textColor = [UIColor darkGrayColor];
//            }
            
            NSString *file = [_localFilesArray objectAtIndex:indexPath.row];
            NSString *fileName = nil;
//            if (_exampleZip && [file isEqualToString:_exampleZip]) {
//                file = [_exampleName stringByAppendingPathExtension:@"zip"];
//            }
            
            if ([[file pathExtension] isEqualToString:@"zip"]) {
                if (_exampleZip && [file isEqualToString:_exampleZip]) {
                    _unZipFile = _exampleZip;
                    fileName = _exampleName;
                }else{
                    _unZipFile = [kDocumentDictory stringByAppendingPathComponent:file];
                    fileName = [file stringByDeletingPathExtension];
                }
                
                MPStorage *storage = [[MPStorage alloc] init];
                
                NSString *query = [NSString stringWithFormat:@"select * from %@ where %@ = ? limit 1;",TABLE_NAME,FIELD_ZIP];
                
                FMResultSet *rs = [storage.db executeQuery:query,_unZipFile];
                NSString *title,*message;
                if ([rs next]) {

                    _lastUnZip = [rs objectForColumnName:FIELD_PATH];
                    title = NSLocalizedString(@"Re-Unzip",nil);
                    message =
                    [NSString stringWithFormat:NSLocalizedString(@"\"%@\" exists,\nOverwrite?",nil),fileName ,nil];
//                    [[@"已有原型“" stringByAppendingString:[file stringByDeletingPathExtension]] stringByAppendingString:@"”，\n重新解压将覆盖原有文件，\n是否重新解压？"];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") otherButtonTitles:NSLocalizedString(@"Re-Unzip",nil),NSLocalizedString(@"Just Preview",nil), nil];
                    alert.tag = kAlertTagReUnzip;
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
        
        //AVOCloud
        [MPAVObject onTapedWithEvent:KEY_AV_SET data:@"out"];
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
-(void)updateOVAObjectPreviewWithEvent:(NSString *)event
{
    [MPAVObject previewCounterWithEvent:event];
}

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
    
    NSString *projectPath = nil;
    if (_exampleZip && [file isEqualToString:_exampleZip]) {
        projectPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] ;
    }else{
        projectPath = kProjectDictory;
    }
    
    BOOL hasPwd = password !=nil;

    [self stopListenDocumentChange];
    
    dispatch_queue_t queue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
    
        BOOL isUnZipOpened = NO;
        ZipArchive *zip = [[ZipArchive alloc] init];
        _zipNeedPassword = nil;
        if ([[file pathExtension] isEqualToString:@"zip"]) {
            

            if (password) {
                isUnZipOpened = [zip UnzipOpenFile:file Password:password];
            }else{
                isUnZipOpened = [zip UnzipOpenFile:file];
            }
            NSLog(@"Do here?%@",isUnZipOpened?@"yes":@"no");
            if (isUnZipOpened) {
                BOOL needPassworld =[zip UnzipIsEncrypted];
                if (needPassworld && !password) {
                    //need password but no password,then popup password input
                    
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
                
                //Unzip to Disk
                NSString *currentProjectPath = [projectPath stringByAppendingPathComponent:[self MD5:file]];
                
                if([zip UnzipFileTo:currentProjectPath overWrite:YES]){
                    //unzip successed!
                    
                    NSString *fileName = [file lastPathComponent];
                    
                    MPProject *project = [[MPProject alloc]init];
                    project.name = [fileName stringByDeletingPathExtension];
                    project.path = currentProjectPath;
                    project.zip = file;
                    project.modifiedTime = [[NSDate date] timeIntervalSince1970];
                    MPStorage *storage = [[MPStorage alloc] init];
                    
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
                    //[self listFileAtPath:currentProjectPath];// FOR testing
                    NSLog(@"unzip successed! row id:%ld",(long)rowId);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HUD hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unzip Successful!",nil) message:NSLocalizedString(@"Preview now?", @"Preview it!") delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil) otherButtonTitles:NSLocalizedString(@"Do Preview", nil), nil];
                        alert.tag = kAlertTagUnzipSuccessed;
                        _lastUnZip = currentProjectPath;
                        [alert show];
                        
                        [self listenDocumentChange];
                    });
                    //NSLog(@"UnZipFile %@ to %@", file,currentProjectPath);
                    
                    //AVOCloud
                    [MPAVObject unzipCounterWithEvent:(_isReunzip?kAVObjectReUnzip:kAVObjectUnzip) result:kAVObjectResultSuccessed hasPwd:hasPwd];
                    _isReunzip = NO;//RESULT
                    
                }else if(needPassworld && password){
                    //Need password but failed, then popup input again;
                    
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
                    
                    //AVOCloud
                    [MPAVObject unzipCounterWithEvent:(_isReunzip?kAVObjectReUnzip:kAVObjectUnzip) result:kAVObjectResultFailed hasPwd:hasPwd];
                    _isReunzip = NO;//RESET;
                    
                    return;
                }
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unzip Error occurred", nil) message:NSLocalizedString(@"canNotUnzip", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"好") otherButtonTitles: nil];
                    [alert show];
                    
                    [self listenDocumentChange];
                });
                [MPAVObject unzipCounterWithEvent:(_isReunzip?kAVObjectReUnzip:kAVObjectUnzip) result:kAVObjectResultFailed hasPwd:hasPwd];
                _isReunzip = NO;//RESET
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
        int count = [newArray count];
        if (_exampleZip) {
            count++;
        }
        
//        NSLog(@"file changed:%ld,%ld",(unsigned long)[newArray count],(unsigned long)[_localFilesArray count]);
        if (count!=[_localFilesArray count]) {
            _localFilesArray = [NSMutableArray arrayWithArray:newArray];
            if (_exampleZip) {
                [_localFilesArray insertObject:_exampleZip atIndex:0];
            }
            _datas = _localFilesArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.navigationItem.rightBarButtonItem setEnabled:_localFilesArray.count>0];
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
    
    //AVOCloud
    [MPAVObject onTapedWithEvent:KEY_AV_SEGMENTED data:[NSString stringWithFormat:@"%ld",(long)segmented.selectedSegmentIndex]];
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
            
//            if (NSFoundationVersionNumber<=NSFoundationVersionNumber_iOS_6_1) {
//
//            }
            if (_localFilesArray==nil) {
                _localFilesArray = [NSMutableArray arrayWithArray:[self listFileAtPath:kDocumentDictory]];
                if (_exampleZip) {
                    [_localFilesArray insertObject:_exampleZip atIndex:0];
                }
            }
            [self listenDocumentChange];
            _datas = _localFilesArray;
            break;
    }
    _segmentIndex = tag;
    
    [self.navigationItem.rightBarButtonItem setEnabled:_datas.count>0];
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
    
    NSString *unziping = NSLocalizedString(@"Unziping",nil);
    if(_lastUnZip && alertView.tag == kAlertTagReUnzip && buttonIndex ==2){
        [self showWebView:_lastUnZip];
        _lastUnZip = nil;
        [self updateOVAObjectPreviewWithEvent:kAVObjectPreviewCounterEventFromZip];
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
            }else if(_unZipFile && (alertView.tag == kAlertTagReUnzip)){
                
                [HUD hide:NO];
                HUD = [self whiteHUDWithIndeterminate];
                HUD.labelText = unziping;
                [HUD show:YES];
                _isReunzip = YES;
                [self unZipFile:_unZipFile withPassword:nil];
                
                _unZipFile = nil;
                
            }else if(_lastUnZip && alertView.tag == kAlertTagUnzipSuccessed){

                [self showWebView:_lastUnZip];
                [self updateOVAObjectPreviewWithEvent:kAVObjectPreviewCounterEventFromUnZip];
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
    
    MPHelpViewController *helpController;
    helpController = [[MPHelpViewController alloc]initWithNibName:@"HelpView" bundle:nil];

    [self.navigationController pushViewController:helpController animated:YES];
    
    //AVOCloud
    [MPAVObject onTapedWithEvent:KEY_AV_TAPED_COUNTER data:KEY_AV_HELP];
}

- (void)editPressed:(id)sender {
    if (self.tableView.editing) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Edit",@"Edit");
        [self.tableView setEditing:NO animated:YES];
    }else{
        
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done",@"Done");
        
        //AVOCloud
        [MPAVObject onTapedWithEvent:KEY_AV_TAPED_COUNTER data:KEY_AV_EDIT];
    }
    
}

@end
