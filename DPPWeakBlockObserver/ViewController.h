//
//  ViewController.h
//  DPPWeakBlockObserver
//
//  Created by Lee Higgins on 04/08/2015.
//  Copyright (c) 2015 DepthPerPixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPPWeakBlockObserver.h"

@interface ViewController : UIViewController


@property(nonatomic,weak) IBOutlet UILabel* testLabel;
@property(nonatomic,weak) IBOutlet UIButton* testButton;


@end

