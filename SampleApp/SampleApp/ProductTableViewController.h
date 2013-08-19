//
//  ProductTableViewController.h
//  SampleApp
//
//  Created by FourtyTwo on 8/19/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* products;

@end
