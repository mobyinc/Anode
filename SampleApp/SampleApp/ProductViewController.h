//
//  ProductViewController.h
//  SampleApp
//
//  Created by James Jacoby on 8/17/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductViewController : UIViewController

@property (nonatomic, strong) NSNumber* productId;

@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameInput;
@property (strong, nonatomic) IBOutlet UITextField *descriptionInput;
@property (strong, nonatomic) IBOutlet UITextField *priceInput;
@property (strong, nonatomic) IBOutlet UITextField *releaseDateInput;

- (IBAction)saveProductAction:(id)sender;
- (IBAction)refreshProductAction:(id)sender;
- (IBAction)deleteProductAction:(id)sender;


@end
