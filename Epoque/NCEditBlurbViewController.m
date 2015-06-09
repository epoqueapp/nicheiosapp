//
//  NCEditBlurbViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 6/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCEditBlurbViewController.h"

@interface NCEditBlurbViewController ()

@end

@implementation NCEditBlurbViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpDismissButtonWithTarget:self selector:@selector(dismissMe:)];
    self.formController = [[FXFormController alloc]init];
    self.formController.tableView = self.tableView;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#141414"];
    
    NCBlurbForm *form = [[NCBlurbForm alloc]init];
    if (self.blurbId) {

    }else{
        
    }
    self.formController.form = form;
}

-(void)dismissMe:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
