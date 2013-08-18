//
//  ProductViewController.m
//  SampleApp
//
//  Created by James Jacoby on 8/17/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ProductViewController.h"

@interface ProductViewController ()

@property (nonatomic, retain) ANObject* product;

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
    
    if (self.productId) {
        
    } else {
        self.product = [ANObject objectWithType:@"product"];
    }
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
    
    [self.product setObject:name forKey:@"name"];
    [self.product setObject:description forKey:@"description"];
    [self.product setObject:price forKey:@"price"];
    
    [self.product saveWithBlock:^(id object, NSError *error) {
        if (error) {
            NSString* message = [NSString stringWithFormat:@"%d - %@", error.code, error.localizedDescription];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {                        
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Product saved!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

- (IBAction)refreshProductAction:(id)sender {
    [self.product reloadWithBlock:^(id object, NSError *error) {
        if (error) {
            NSString* message = [NSString stringWithFormat:@"%d - %@", error.code, error.localizedDescription];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Product refreshed!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
            self.nameInput.text = [object objectForKey:@"name"];
            self.descriptionInput.text = [object objectForKey:@"description"];
            
            NSNumber* price = [object objectForKey:@"price"];
            self.priceInput.text = [NSString stringWithFormat:@"%@", price];
        }
    }];
}

- (IBAction)deleteProductAction:(id)sender {
    [self.product destroyWithBlock:^(id object, NSError *error) {
        if (error) {
            NSString* message = [NSString stringWithFormat:@"%d - %@", error.code, error.localizedDescription];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Product deleted!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];        
        }
    }];
}

@end
