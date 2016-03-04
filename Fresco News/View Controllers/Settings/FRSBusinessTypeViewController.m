//
//  FRSBusinessTypeViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBusinessTypeViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"

@interface FRSBusinessTypeViewController()

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIButton *button1;
@property (strong, nonatomic) UIButton *button2;
@property (strong, nonatomic) UIButton *button3;
@property (strong, nonatomic) UIButton *button4;
@property (strong, nonatomic) UIButton *button5;
@property (strong, nonatomic) UIButton *button6;
@property (strong, nonatomic) UIButton *button7;
@property (strong, nonatomic) UIButton *button8;

@property (strong, nonatomic) UILabel *label1;
@property (strong, nonatomic) UILabel *label2;
@property (strong, nonatomic) UILabel *label3;
@property (strong, nonatomic) UILabel *label4;
@property (strong, nonatomic) UILabel *label5;
@property (strong, nonatomic) UILabel *label6;
@property (strong, nonatomic) UILabel *label7;
@property (strong, nonatomic) UILabel *label8;

@property (strong, nonatomic) UIImageView *imageView1;
@property (strong, nonatomic) UIImageView *imageView2;
@property (strong, nonatomic) UIImageView *imageView3;
@property (strong, nonatomic) UIImageView *imageView4;
@property (strong, nonatomic) UIImageView *imageView5;
@property (strong, nonatomic) UIImageView *imageView6;
@property (strong, nonatomic) UIImageView *imageView7;
@property (strong, nonatomic) UIImageView *imageView8;

@property (nonatomic) NSInteger tag;

@end

@implementation FRSBusinessTypeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self configureUI];

    [self selectTag:1]; // Select first row if no other row is selected
    self.tag = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected-tag"];
    [self selectTag:self.tag];

}

-(void)configureUI{
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 352)];
    container.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:container];

    [self addLineToContainer:container AtYPos:0];
    [self addLineToContainer:container AtYPos:container.frame.size.height-1];
    
    self.button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,   self.view.frame.size.width, 44)];
    self.button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 44,  self.view.frame.size.width, 44)];
    self.button3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 88,  self.view.frame.size.width, 44)];
    self.button4 = [[UIButton alloc] initWithFrame:CGRectMake(0, 132, self.view.frame.size.width, 44)];
    self.button5 = [[UIButton alloc] initWithFrame:CGRectMake(0, 176, self.view.frame.size.width, 44)];
    self.button6 = [[UIButton alloc] initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 44)];
    self.button7 = [[UIButton alloc] initWithFrame:CGRectMake(0, 264, self.view.frame.size.width, 44)];
    self.button8 = [[UIButton alloc] initWithFrame:CGRectMake(0, 308, self.view.frame.size.width, 44)];
    
    [self.button1 addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3 addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button4 addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button5 addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button6 addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button7 addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button8 addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [container addSubview:self.button1];
    [container addSubview:self.button2];
    [container addSubview:self.button3];
    [container addSubview:self.button4];
    [container addSubview:self.button5];
    [container addSubview:self.button6];
    [container addSubview:self.button7];
    [container addSubview:self.button8];
    
    self.button1.tag = 1;
    self.button2.tag = 2;
    self.button3.tag = 3;
    self.button4.tag = 4;
    self.button5.tag = 5;
    self.button6.tag = 6;
    self.button7.tag = 7;
    self.button8.tag = 8;
    
    self.label1  = [[UILabel alloc] initWithFrame:CGRectMake(16, 11, self.view.frame.size.width, 20)];
    self.label1.text = @"Individual/Sole Proprietorship";
    self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.label1.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:self.label1];
    
    self.label2  = [[UILabel alloc] initWithFrame:CGRectMake(16, 55, self.view.frame.size.width, 20)];
    self.label2.text = @"Partnership";
    self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.label2.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:self.label2];
    
    self.label3  = [[UILabel alloc] initWithFrame:CGRectMake(16, 99, self.view.frame.size.width, 20)];
    self.label3.text = @"LLC (Partnership class)";
    self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.label3.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:self.label3];
    
    self.label4  = [[UILabel alloc] initWithFrame:CGRectMake(16, 143, self.view.frame.size.width, 20)];
    self.label4.text = @"LLC (C class)";
    self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.label4.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:self.label4];
    
    self.label5  = [[UILabel alloc] initWithFrame:CGRectMake(16, 187, self.view.frame.size.width, 20)];
    self.label5.text = @"LLC (S class)";
    self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.label5.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:self.label5];
    
    self.label6  = [[UILabel alloc] initWithFrame:CGRectMake(16, 231, self.view.frame.size.width, 20)];
    self.label6.text = @"C corporation";
    self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.label6.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:self.label6];
    
    self.label7  = [[UILabel alloc] initWithFrame:CGRectMake(16, 275, self.view.frame.size.width, 20)];
    self.label7.text = @"S corporation";
    self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.label7.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:self.label7];
    
    self.label8  = [[UILabel alloc] initWithFrame:CGRectMake(16, 319, self.view.frame.size.width, 20)];
    self.label8.text = @"Trust";
    self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.label8.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:self.label8];
    
    self.imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.imageView1.frame = CGRectMake(self.view.frame.size.width - 18 - 20, 10, 24, 24);
    [container addSubview:self.imageView1];
    
    self.imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.imageView2.frame = CGRectMake(self.view.frame.size.width - 18 - 20, 54, 24, 24);
    [container addSubview:self.imageView2];

    self.imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.imageView3.frame = CGRectMake(self.view.frame.size.width - 18 - 20, 98, 24, 24);
    [container addSubview:self.imageView3];

    self.imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.imageView4.frame = CGRectMake(self.view.frame.size.width - 18 - 20, 142, 24, 24);
    [container addSubview:self.imageView4];
    
    self.imageView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.imageView5.frame = CGRectMake(self.view.frame.size.width - 18 - 20, 186, 24, 24);
    [container addSubview:self.imageView5];
    
    self.imageView6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.imageView6.frame = CGRectMake(self.view.frame.size.width - 18 - 20, 230, 24, 24);
    [container addSubview:self.imageView6];
    
    self.imageView7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.imageView7.frame = CGRectMake(self.view.frame.size.width - 18 - 20, 274, 24, 24);
    [container addSubview:self.imageView7];
    
    self.imageView8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.imageView8.frame = CGRectMake(self.view.frame.size.width - 18 - 20, 318, 24, 24);
    [container addSubview:self.imageView8];

}

-(void)buttonTapped:(UIButton*)button{
    
    self.tag = button.tag;
    [[NSUserDefaults standardUserDefaults] setInteger:self.tag forKey:@"selected-tag"];

    switch (button.tag) {
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected-business-type" object:self.label1.text];
            [self selectTag:1];
            break;
        
        case 2:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected-business-type" object:self.label2.text];
            [self selectTag:2];
            break;
            
        case 3:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected-business-type" object:self.label3.text];
            [self selectTag:3];
            break;
            
        case 4:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected-business-type" object:self.label4.text];
            [self selectTag:4];
            break;
            
        case 5:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected-business-type" object:self.label5.text];
            [self selectTag:5];
            break;
            
        case 6:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected-business-type" object:self.label6.text];
            [self selectTag:6];
            break;
            
        case 7:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected-business-type" object:self.label7.text];
            [self selectTag:7];
            break;
            
        case 8:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected-business-type" object:self.label8.text];
            [self selectTag:8];
            break;
            
        default:
            break;
    }
}

-(void)selectTag:(NSInteger)tag{
    switch (tag) {
        case 1:
            self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            self.imageView1.image = [UIImage imageNamed:@"check-box-circle-filled"];
            
            self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView2.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView3.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView4.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView5.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView6.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView7.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView8.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            break;
        
        case 2:
            self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView1.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            self.imageView2.image = [UIImage imageNamed:@"check-box-circle-filled"];
            
            self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView3.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView4.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView5.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView6.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView7.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView8.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            break;
            
        case 3:
            self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView1.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView2.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            self.imageView3.image = [UIImage imageNamed:@"check-box-circle-filled"];
            
            self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView4.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView5.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView6.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView7.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView8.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            break;
            
        case 4:
            self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView1.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView2.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView3.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            self.imageView4.image = [UIImage imageNamed:@"check-box-circle-filled"];
            
            self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView5.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView6.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView7.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView8.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            break;
            
        case 5:
            self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView1.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView2.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView3.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView4.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            self.imageView5.image = [UIImage imageNamed:@"check-box-circle-filled"];
            
            self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView6.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView7.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView8.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            break;
            
        case 6:
            self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView1.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView2.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView3.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView4.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView5.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            self.imageView6.image = [UIImage imageNamed:@"check-box-circle-filled"];
            
            self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView7.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView8.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            break;
            
        case 7:
            self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView1.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView2.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView3.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView4.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView5.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView6.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            self.imageView7.image = [UIImage imageNamed:@"check-box-circle-filled"];
            
            self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView8.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            break;
            
        case 8:
            self.label1.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView1.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label2.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView2.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label3.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView3.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label4.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView4.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label5.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView5.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label6.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView6.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label7.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            self.imageView7.image = [UIImage imageNamed:@"check-box-circle-outline"];
            
            self.label8.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            self.imageView8.image = [UIImage imageNamed:@"check-box-circle-filled"];
            
            break;
            
        default:
            break;
    }
}

-(void)createLabelAtYPosition:(CGFloat)yPosition{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, yPosition, self.view.frame.size.width, 44)];
    title.text = @"Title/Titleship";
    title.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
}

-(void)addLineToContainer:(UIView*)container AtYPos:(CGFloat)yPos{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, self.view.frame.size.width, 1)];
    line.backgroundColor = [UIColor frescoLightTextColor];
    line.alpha = 0.5;
    [container addSubview:line];
}


@end
