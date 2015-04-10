//
//  NCPrivateChatViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "SLKTextViewController.h"

@interface NCPrivateChatViewController : SLKTextViewController<TTTAttributedLabelDelegate>

@property (nonatomic, copy) NSString *regardingUserId;
@property (nonatomic, copy) NSString *regardingUserName;

@property (nonatomic, strong) NSMutableArray *messages;

@end
