//
//  ProductViewController.m
//  SampleApp
//
//  Created by James Jacoby on 8/17/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ProductViewController.h"

@interface ProductViewController ()

@property (nonatomic, strong) ANObject* product;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;

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
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
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
    NSDate* releaseDate = [self.dateFormatter dateFromString:self.releaseDateInput.text];
    
    [self.product setObject:name forKey:@"name"];
    [self.product setObject:description forKey:@"description"];
    [self.product setObject:price forKey:@"price"];
    [self.product setObject:releaseDate forKey:@"release_date"];
    
    [self.product saveWithBlock:^(id object, NSError *error) {
        if (error) {
            NSString* message = [NSString stringWithFormat:@"%d - %@", error.code, error.localizedDescription];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {                        
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Product saved!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [self updateInfoLabel];
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
            
            NSDate* releaseDate = [object objectForKey:@"release_date"];
            
            if (releaseDate) {
                self.releaseDateInput.text = [self.dateFormatter stringFromDate:releaseDate];
            }
            
            [self updateInfoLabel];
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
            
            [self updateInfoLabel];
        }
    }];
}

-(void)updateInfoLabel
{
    NSNumber* objectId = self.product.objectId;
    NSDate* updatedAt = self.product.updatedAt;
    
    NSString* labelText = [NSString stringWithFormat:@"Product #%@ updated: %@", objectId, [self.dateFormatter stringFromDate:updatedAt]];
    
    self.infoLabel.text = labelText;
}

@end
