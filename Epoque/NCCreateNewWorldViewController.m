//
//  NCCreateNewWorldViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCCreateNewWorldViewController.h"
#import "NCUploadService.h"
#import "NCFireService.h"
#import "NCFormColorCell.h"
#import <WEPopover/WEPopoverController.h>
@interface NCCreateNewWorldViewController ()

@end

@implementation NCCreateNewWorldViewController{
    NCUploadService *uploadService;
    NCFireService *fireService;
}

static NSString *yesStopTitle = @"Yes, I want to stop";
static NSString *cancelTitle = @"Cancel";
static NSString *cameraTitle = @"Camera";
static NSString *libraryTitle = @"Library";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.colorElementType = kBackground;
    
    uploadService = [NCUploadService sharedInstance];
    fireService = [NCFireService sharedInstance];
    
    NCCreateWorldForm *form = [[NCCreateWorldForm alloc]init];
    
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.tableView;
    self.formController.delegate = self;
    self.formController.form = form;
    self.tableView.separatorColor = [UIColor clearColor];
    self.title = @"CREATE A NEW WORLD";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonDidClick:)];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)submitButtonDidTap{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    [Amplitude logEvent:@"Create New World Button Did Click"];
    NCCreateWorldForm *form = (NCCreateWorldForm*)self.formController.form;
    if (!form.isValid) {
        [[[UIAlertView alloc]initWithTitle:@"Uh Oh" message:@"Give this world some information! Give it a name and description" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil]show];
        return;
    }
    [NCLoadingView showInView:self.view withTitleText:@"Creating World..."];
    @weakify(self);
    [Amplitude logEvent:@"Create New World"];
    [[[uploadService uploadImage:form.emblemImage] flattenMap:^RACStream *(NSString *imageUrl) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]init];
        worldModel.name = form.name;
        worldModel.detail = form.worldDescription;
        worldModel.imageUrl = imageUrl;
        worldModel.passcode = @"";
        worldModel.favoritedUserIds = @[myUserId];
        worldModel.moderatorUserIds = @[myUserId];
        worldModel.memberUserIds = @[myUserId];
        return [self createWorld:worldModel];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [Amplitude logEvent:@"Create New World" withEventProperties:x];
        [NCLoadingView hideAllFromView:self.view];
        [self commitDismiss];
    } error:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Uh oh" message:@"We encountered an error creating your world." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

-(RACSignal *)createWorld:(WorldModel *)worldModel{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [fireService.worldsRef.childByAutoId setValue:[worldModel toDictionary] withCompletionBlock:^(NSError *error, Firebase *ref) {
            if(error){
                [subscriber sendError:error];
            }else{
                worldModel.worldId = ref.key;
                [subscriber sendNext:worldModel];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

-(void)dismissButtonDidClick:(id)sender{
    NCCreateWorldForm *form = (NCCreateWorldForm *)self.formController.form;
    if ([form isDirty]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Hmm" message:@"Are you sure you want to stop creating a new world?" delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:yesStopTitle, nil];
        [alertView show];
    }else{
        [self commitDismiss];
    }
}

-(void)changeImage{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Image"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:cameraTitle, libraryTitle, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:cameraTitle]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{}];
    }
    if ([title isEqualToString:libraryTitle]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{}];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NCCreateWorldForm *form = (NCCreateWorldForm *)self.formController.form;
    form.emblemImage = selectedImage;
    [self.tableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:yesStopTitle]) {
        [self commitDismiss];
    }
}

-(void)commitDismiss{
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(shouldRefresh:)]) {
            [self.delegate shouldRefresh:nil];
        }
    }];
}

-(void)colorPopoverControllerDidSelectColor:(NSString *)hexColor{
    if (self.wePopoverController != nil) {
        [self.wePopoverController dismissPopoverAnimated:NO];
    }
    
    NCCreateWorldForm *worldForm =  (NCCreateWorldForm*)self.formController.form;
    UIColor *selectedColor = [GzColors colorFromHex:hexColor];
    [self.tableView reloadData];
}

-(void)backgroundColorCellDidTap {
    [self.wePopoverController dismissPopoverAnimated:YES];
    self.wePopoverController = nil;
    
    self.colorElementType = kBackground;
    CGRect backgroundFrame = [self  backgroundColorCellFrame];
    if (!self.wePopoverController) {
        ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
        self.wePopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        self.wePopoverController.delegate = self;
        self.wePopoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
        [self.wePopoverController presentPopoverFromRect:backgroundFrame
                                                  inView:self.view
                                permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                                animated:YES];
        
    }
}


-(void)foregroundColorCellDidTap{
    [self.wePopoverController dismissPopoverAnimated:YES];
    self.wePopoverController = nil;
    
    self.colorElementType = kForeground;
    CGRect backgroundFrame = [self  forgroundColorCellFrame];
    if (!self.wePopoverController) {
        ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
        self.wePopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        self.wePopoverController.delegate = self;
        self.wePopoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
        [self.wePopoverController presentPopoverFromRect:backgroundFrame
                                                  inView:self.view
                                permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                                animated:YES];
        
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return YES;
}

-(CGRect)forgroundColorCellFrame{
    NSArray *visibleCells = [self.tableView visibleCells];
    for (UITableViewCell *cell in visibleCells) {
        if([cell isKindOfClass:[NCFormColorCell class]]){
            NCFormColorCell *formColorCell = (NCFormColorCell *)cell;
            if ([formColorCell.formFieldTextLabel.text containsString:@"Foreground"]) {
                return cell.frame;
            }
            
        }
    }
    return CGRectMake(0, 0, 0, 0);
}

-(CGRect)backgroundColorCellFrame{
    NSArray *visibleCells = [self.tableView visibleCells];
    for (UITableViewCell *cell in visibleCells) {
        if([cell isKindOfClass:[NCFormColorCell class]]){
            NCFormColorCell *formColorCell = (NCFormColorCell *)cell;
            if ([formColorCell.formFieldTextLabel.text containsString:@"Background"]) {
                return cell.frame;
            }
            
        }
    }
    return CGRectMake(0, 0, 0, 0);
}

@end
