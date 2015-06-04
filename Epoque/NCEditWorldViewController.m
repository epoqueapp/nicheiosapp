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
#import "NCFormColorCell.h"
@interface NCEditWorldViewController ()

@end

@implementation NCEditWorldViewController{
    NCUploadService *uploadService;
    NCFireService *fireService;
    BOOL shouldUpload;
    WorldModel *worldModel;
}

static NSString *yesStopTitle = @"Yes, I want to stop";
static NSString *cancelTitle = @"Cancel";
static NSString *cameraTitle = @"Camera";
static NSString *libraryTitle = @"Library";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpDismissButtonWithTarget:self selector:@selector(dismissMe:)];
    self.title = @"EDIT WORLD";
    shouldUpload = NO;
    
    uploadService = [NCUploadService sharedInstance];
    fireService = [NCFireService sharedInstance];
    
    self.formController = [[FXFormController alloc]init];
    self.formController.tableView = self.tableView;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#141414"];
    
    if (self.worldId == nil) {
        self.title = @"CREATE A WORLD";
        [self setUpAsANewWorld];
    }else{
        self.title = @"EDIT WORLD";
        [self setUpListener];
    }
}

-(void)dismissMe:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setUpAsANewWorld {
    worldModel = [[WorldModel alloc]init];
    NCEditWorldForm *form = [[NCEditWorldForm alloc]init];
    form.name = worldModel.name;
    form.worldDescription = worldModel.detail;
    form.isPrivate = worldModel.isPrivate;
    self.formController.form = form;
}

-(void)setUpListener{
    @weakify(self);
    self.tableView.alpha = 0;
    [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"worlds"] childByAppendingPath:self.worldId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        [UIView animateWithDuration:0.25 animations:^{
            self.tableView.alpha = 1;
        }];
        if (snapshot.value == [NSNull null]) {
            worldModel = [[WorldModel alloc]init];
        }else{
            worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        }
        
        NCEditWorldForm *form = [[NCEditWorldForm alloc]init];
        form.name = worldModel.name;
        form.worldDescription = worldModel.detail;
        form.isPrivate = worldModel.isPrivate;
        self.formController.form = form;

        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:worldModel.imageUrl] options:9 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                form.emblemImage = image;
            }
            [self.tableView reloadData];
        }];
    }];
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
    shouldUpload = YES;
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
    [Amplitude logEvent:@"Edit World Button Did Click"];
    NCEditWorldForm *form = (NCEditWorldForm *)self.formController.form;
    if (!form.isValid) {
        [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Hey! Fill in all the information or else we can't update your world!" duration:2.0];
        return;
    }
    @weakify(self);
    [NCLoadingView showInView:self.view withTitleText:@"Uploading your image..."];
    RACSignal *imageSignal;
    if (shouldUpload) {
        imageSignal = [uploadService uploadImage:form.emblemImage];
    }else{
        imageSignal = [RACSignal return:worldModel.imageUrl];
    }
    
    [[imageSignal flattenMap:^RACStream *(NSString *value) {
        @strongify(self);
        WorldModel *worldModelToUpdate = [[WorldModel alloc]init];
        worldModelToUpdate.worldId = [worldModel.worldId copy];
        worldModelToUpdate.name = form.name;
        worldModelToUpdate.imageUrl = [value copy];
        worldModelToUpdate.detail = form.worldDescription;
        worldModelToUpdate.isPrivate = form.isPrivate;
        worldModelToUpdate.isDefault = worldModel.isDefault;
        worldModelToUpdate.memberUserIds = worldModel.memberUserIds;
        worldModelToUpdate.favoritedUserIds = worldModel.favoritedUserIds;
        worldModelToUpdate.moderatorUserIds = worldModel.moderatorUserIds;
        worldModelToUpdate.passcode = [NSString generateRandomPIN:4];
        
        if (self.worldId == nil) {
            return [self createWorld:worldModelToUpdate];
        }
        return [self updateWorld:worldModelToUpdate];
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

-(RACSignal *)createWorld:(WorldModel *)worldModelToCreate {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[[Firebase alloc]initWithUrl:kFirebaseRoot]childByAppendingPath:@"worlds"] childByAutoId] setValue:[worldModelToCreate toDictionary] withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:ref];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}


-(RACSignal *)updateWorld:(WorldModel *)worldModelToUpdate{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[fireService.worldsRef childByAppendingPath:worldModelToUpdate.worldId] updateChildValues:[worldModelToUpdate toDictionary] withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:worldModel];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
