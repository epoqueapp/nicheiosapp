//
//  NCEditWorldViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/11/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCEditWorldViewController.h"
#import "NCEditWorldForm.h"
#import "NCUploadService.h"
#import "NCFireService.h"
#import "NCWorldService.h"
#import "NCFormColorCell.h"
@interface NCEditWorldViewController ()

@end

@implementation NCEditWorldViewController{
    Mixpanel *mixpanel;
    NCUploadService *uploadService;
    NCWorldService *worldService;
    NCFireService *fireService;
}

static NSString *yesStopTitle = @"Yes, I want to stop";
static NSString *cancelTitle = @"Cancel";
static NSString *cameraTitle = @"Camera";
static NSString *libraryTitle = @"Library";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpBackButton];
    self.title = @"EDIT WORLD";
    
    mixpanel = [Mixpanel sharedInstance];
    
    uploadService = [NCUploadService sharedInstance];
    fireService = [NCFireService sharedInstance];
    worldService = [NCWorldService sharedInstance];
    
    NCEditWorldForm *form = [[NCEditWorldForm alloc]init];
    
    form.name = self.worldModel.name;
    form.worldDescription = self.worldModel.detail;
    form.isPrivate = self.worldModel.isPrivate;
    
    @weakify(self);
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.worldModel.imageUrl] options:9 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        @strongify(self);
        if (image) {
            form.emblemImage = image;
        }
        [self.tableView reloadData];
    }];
    
    self.formController = [[FXFormController alloc]init];
    self.formController.tableView = self.tableView;
    self.formController.form = form;
    self.tableView.separatorColor = [UIColor clearColor];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NCEditWorldForm *form = (NCEditWorldForm *)self.formController.form;
    form.emblemImage = selectedImage;
    [self.tableView reloadData];
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

-(void)submitButtonDidTap{
    [mixpanel track:@"Edit World Button Did Click"];
    NCEditWorldForm *form = (NCEditWorldForm *)self.formController.form;
    if (!form.isValid) {
        [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Hey! Fill in all the information or else we can't update your world!" duration:2.0];
        return;
    }
    @weakify(self);
    [NCLoadingView showInView:self.view];
    [[[uploadService uploadImage:form.emblemImage] flattenMap:^RACStream *(NSString *value) {
        @strongify(self);
        WorldModel *worldModelToUpdate = [[WorldModel alloc]init];
        worldModelToUpdate.worldId = [self.worldModel.worldId copy];
        worldModelToUpdate.name = form.name;
        worldModelToUpdate.imageUrl = [value copy];
        worldModelToUpdate.detail = form.worldDescription;
        worldModelToUpdate.isPrivate = form.isPrivate;
        worldModelToUpdate.isDefault = self.worldModel.isDefault;
        
        return [worldService updateWorld:worldModelToUpdate];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Awesome! We updated your world's information" duration:2.0];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Yuck. We ran into an issue updating your world's information." duration:2.0];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
