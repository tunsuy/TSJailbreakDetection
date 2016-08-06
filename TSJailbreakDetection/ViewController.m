//
//  ViewController.m
//  TSJailbreakDetection
//
//  Created by tunsuy on 29/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "ViewController.h"
#import "JailBreakHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height - 100)];
    infoLabel.textColor = [UIColor blueColor];
    if ([JailBreakHelper isJailBroken]) {
        infoLabel.text = @"this device is jailBreak";
    }
    else {
        infoLabel.text = @"this device is not jailBreak";
    }
    
    [self.view addSubview:infoLabel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
