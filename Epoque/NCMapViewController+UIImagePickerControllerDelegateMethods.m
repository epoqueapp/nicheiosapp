//
//  NCMapViewController+UIImagePickerControllerDelegateMethods.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+UIImagePickerControllerDelegateMethods.h"
#import "NCUploadService.h"
@implementation NCMapViewController (UIImagePickerControllerDelegateMethods)


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];

    @weakify(self);
    [NCLoadingView showInView:self.view];
    [[[[NCUploadService sharedInstance] uploadImage:chosenImage] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *imageUrl) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [self submitImageMessage:imageUrl.copy];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [[[UIAlertView alloc]initWithTitle:nil message:@"Ran into an issue uploading your image" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }];
}

-(void)submitImageMessage:(NSString *)imageUrl{
    SendMessageModel *sendMessageModel = [[SendMessageModel alloc]init];
    sendMessageModel.messageText = @"";
    sendMessageModel.messageImageUrl = imageUrl;
    sendMessageModel.location = self.lastKnownLocation;
    [self sendMessage:sendMessageModel];
}


@end
