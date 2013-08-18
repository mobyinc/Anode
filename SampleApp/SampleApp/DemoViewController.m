//
//  DemoViewController.m
//  SampleApp
//
//  Created by James Jacoby on 8/13/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "DemoViewController.h"
#import "ProductViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createProductSegue"]) {
        NSLog(@"segue create new product");
    } else if ([segue.identifier isEqualToString:@"findProductSegue"]) {
        ProductViewController* controller = segue.destinationViewController;
        controller.productId = [self.objectIdInput.text intValue];
    }
}

@end
