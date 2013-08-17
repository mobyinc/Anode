//
//  ProductViewController.m
//  SampleApp
//
//  Created by James Jacoby on 8/17/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ProductViewController.h"

@interface ProductViewController ()

@end

@implementation ProductViewController

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

- (IBAction)saveProductAction:(id)sender {
    NSString* name = self.nameInput.text;
    NSString* description = self.descriptionInput.text;
    NSNumber* price = [NSNumber numberWithFloat:[self.priceInput.text floatValue]];
    
    ANObject* product = [ANObject objectWithType:@"Product"];
    [product setObject:name forKey:@"name"];
    [product setObject:description forKey:@"description"];
    [product setObject:price forKey:@"price"];
    
    [product saveWithBlock:^(NSError *error) {
        if (error) {
            NSString* message = [NSString stringWithFormat:@"%d - %@", error.code, error.localizedDescription];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {                        
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Product saved!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

@end
