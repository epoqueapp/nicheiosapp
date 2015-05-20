//
//  NCNameChoiceViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/14/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCNameChoiceViewController.h"
#import "NCWorldsViewController.h"

#import "NCFireService.h"
#import <MBFaker/MBFaker.h>
@interface NCNameChoiceViewController ()

@end

@implementation NCNameChoiceViewController{
    NCFireService *fireService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    fireService = [NCFireService sharedInstance];
    self.spriteImageView.userInteractionEnabled = YES;
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
    UITapGestureRecognizer *spriteTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goToSprites:)];
    [self.spriteImageView addGestureRecognizer:spriteTapGesture];
    
    self.nameTextField.backgroundColor = [UIColor colorWithHexString:@"#51A3F2" alpha:0.4];
    self.nameTextField.layer.cornerRadius = 4.0;
    self.nameTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.nameTextField.layer.masksToBounds = YES;
    self.nameTextField.text = [MBFakerName name];
    self.nameTextField.textColor = [UIColor whiteColor];
    self.nameTextField.delegate = self;
    self.nameTextField.returnKeyType = UIReturnKeyGo;
    self.nameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.textAlignment = NSTextAlignmentCenter;
    
    [self.scrollView setContentOffset: CGPointMake(0, self.scrollView.contentOffset.y)];
    self.scrollView.directionalLockEnabled = YES;
    
    @weakify(self);
    [RACObserve(self, spriteUrl) subscribeNext:^(id x) {
        @strongify(self);
        [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:x]];
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self submit];
        return NO;
    }
    return YES;
}

-(void)goToSprites:(id)sender{
    NCSpritesViewController *spritesViewController = [[NCSpritesViewController alloc]init];
    spritesViewController.delegate = self;
    [self presentViewController:spritesViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didSelectSpriteFromModal:(NSString *)spriteUrl{
    self.spriteUrl = [spriteUrl copy];
}

-(void)submit{
    UserModel *newUserModel = [[UserModel alloc]init];
    newUserModel.name = self.nameTextField.text;
    newUserModel.email = @"";
    newUserModel.imageUrl = @"";
    newUserModel.spriteUrl = self.spriteUrl;
    newUserModel.role = @"normal";
    newUserModel.about = @"";
    [[NSUserDefaults standardUserDefaults] setIsObscuring:YES];
    @weakify(self);
    [[fireService.usersRef childByAutoId] setValue:[newUserModel toDictionary] withCompletionBlock:^(NSError *error, Firebase *ref) {
        @strongify(self);
        NSString *userId = ref.key;
        newUserModel.userId = userId;
        [[NSUserDefaults standardUserDefaults] setUserModel:newUserModel];
        [Amplitude setUserId:userId];
        [Amplitude setUserProperties:[newUserModel toDictionary]];
        NCWorldsViewController *worldsViewController = [[NCWorldsViewController alloc]init];
        [self.navigationController pushFadeViewController:worldsViewController];
    }];
}

@end
