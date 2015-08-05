//
//  ViewController.m
//  DPPWeakBlockObserver
//
//  Created by Lee Higgins on 04/08/2015.
//  Copyright (c) 2015 DepthPerPixel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    DPPWeakBlockObserver* _blockObserver;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __block typeof(self) weakSelf = self;
    _blockObserver = [self.view blockObservePropertiesWithBlock:^(id object) {
                                                                         if(object)
                                                                         {
                                                                             NSLog(@"Object changed: %@",object);
                                                                             [weakSelf updateDisplay];
                                                                         }
                                                                     }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_blockObserver resume];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_blockObserver pause]; //LH sometimes maybe good idea to stop processing when view not shown
}

-(IBAction)tapped:(id)sender
{
    static int inc=0;
    //LH make a change to the view
    self.view.backgroundColor = ((inc++)%2)?[UIColor redColor]:[UIColor greenColor];
}

-(void)updateDisplay
{
    self.testLabel.text = [self.view.backgroundColor description];
}

@end
