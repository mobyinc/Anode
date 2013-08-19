//
//  ProductTableViewController.m
//  SampleApp
//
//  Created by FourtyTwo on 8/19/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ProductTableViewController.h"

@interface ProductTableViewController ()

@end

@implementation ProductTableViewController

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
	
    ANQuery* query = [ANQuery queryWithType:@"product"];
    query.limit = @(1000);

    
    [query findObjectsWithBlock:^(NSArray *objects, NSError *error) {
        self.products = objects;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.products.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    
    ANObject* product = self.products[indexPath.row];
    
    cell.textLabel.text = [product objectForKey:@"name"];
    
    return cell;
}

@end
