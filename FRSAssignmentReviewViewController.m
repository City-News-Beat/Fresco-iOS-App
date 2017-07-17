//
//  FRSAssignmentReviewViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 7/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAssignmentReviewViewController.h"
#import "FRSAssignment.h"
#import "FRSMapCircle.h"
#import "FRSAssignmentAnnotation.h"
#import "ReviewContainerView.h"

@interface FRSAssignmentReviewViewController () <MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) ReviewContainerView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic) CGSize kbSize;
@end


@implementation FRSAssignmentReviewViewController

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self showKeyboardAnimation];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showKeyboardAnimation];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self hideKeyboardAnimation];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideKeyboardAnimation];
}

- (void)showKeyboardAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height - 226);
        } completion:nil];
        
        
        if ([self.containerView.titleTextField isFirstResponder]) {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else if ([self.containerView.captionTextView isFirstResponder]) {
            [self.scrollView setContentOffset:CGPointMake(0, 148) animated:YES];
        } else {
            CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
            [self.scrollView setContentOffset:bottomOffset animated:YES];
        }
    });
}

- (void)hideKeyboardAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height + 226);
        } completion:nil];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.containerView.expirationTextField.delegate = self;
    self.containerView.captionTextView.delegate = self;
    self.containerView.titleTextField.delegate = self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self configureNavigationBar];
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 790)];
    [self.view addSubview:self.scrollView];
    
    self.containerView = [[[NSBundle mainBundle] loadNibNamed:@"ReviewContainerView" owner:self options:nil] objectAtIndex:0];
    self.containerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.containerView.frame.size.height);
    [self.scrollView addSubview:self.containerView];
    
    self.scrollView.delaysContentTouches = NO;
    
    
    self.containerView.mapView.layer.borderColor = [UIColor frescoShadowColor].CGColor;
    self.containerView.mapView.layer.borderWidth = 0.5;
    self.containerView.mapView.delegate = self;
    
    MKCoordinateRegion region;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.assignment[@"location"][@"coordinates"][0] doubleValue] longitude:[self.assignment[@"location"][@"coordinates"][1] doubleValue]];
    region.center.latitude = location.coordinate.longitude;
    region.center.longitude = location.coordinate.latitude;
    [self.containerView.mapView setRegion:region animated:YES];
    
    [self zoomToCoordinates:region.center.latitude lon:region.center.longitude withRadius:@([self.assignment[@"radius"] doubleValue]) withAnimation:YES];
    [self.containerView.mapView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    [self addAssignmentAnnotation:self.assignment index:0];
    
    self.containerView.titleTextField.text = self.assignment[@"title"];
    self.containerView.captionTextView.text = self.assignment[@"caption"];
    
    
    // need to get expiration date from `ends_at`
    self.containerView.expirationTextField.text = self.assignment[@""];
//
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)dismiss {
    [self.containerView.expirationTextField resignFirstResponder];
    [self.containerView.titleTextField resignFirstResponder];
    [self.containerView.captionTextView resignFirstResponder];
}





- (void)zoomToCoordinates:(double)lat lon:(double)lon withRadius:(NSNumber *)radius withAnimation:(BOOL)animate {
    // Span uses degrees, 1 degree = 69 miles
    MKCoordinateSpan span = MKCoordinateSpanMake(
                                                 ([radius floatValue] / 30),
                                                 ([radius floatValue] / 30));
    MKCoordinateRegion region = { CLLocationCoordinate2DMake(lat, lon), span };
    MKCoordinateRegion regionThatFits = [self.containerView.mapView regionThatFits:region];
    
    [UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.containerView.mapView setRegion:regionThatFits animated:animate];
    } completion:nil];
}

- (void)addAssignmentAnnotation:(NSMutableDictionary *)dictionary index:(NSInteger)index {
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:delegate.managedObjectContext];
    [assignment configureWithDictionary:dictionary];
    
    FRSAssignmentAnnotation *ann = [[FRSAssignmentAnnotation alloc] initWithAssignment:assignment atIndex:index];
    // create center coordinate for the assignment
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([assignment.latitude floatValue], [assignment.longitude floatValue]);
    
    // create MKCircle surroudning the annotation
    CLLocationDistance distance = [assignment.radius floatValue] * metersInAMile;
    FRSMapCircle *circle = [FRSMapCircle circleWithCenterCoordinate:coord radius:distance];
    circle.circleType = FRSMapCircleTypeAssignment;
    
    [self.containerView.mapView addOverlay:circle];
    [self.containerView.mapView addAnnotation:ann];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *annotationIdentifer = @"assignment-annotation";
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.containerView.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifer];
    annotationView = nil; // clear these to force redraw, avoid yellow annotations that shoud be green and visa versa
    
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifer];
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        container.backgroundColor = [UIColor clearColor];
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(25.5, 25.5, 24, 24)];
        whiteView.layer.cornerRadius = 12;
        whiteView.backgroundColor = [UIColor whiteColor];
        
        whiteView.layer.shadowColor = [UIColor blackColor].CGColor;
        whiteView.layer.shadowOffset = CGSizeMake(0, 2);
        whiteView.layer.shadowOpacity = 0.15;
        whiteView.layer.shadowRadius = 1.5;
        whiteView.layer.shouldRasterize = YES;
        whiteView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(4, 4, 16, 16)];
        view.layer.cornerRadius = 8;
        
        view.backgroundColor = [UIColor frescoOrangeColor];
        
        
        [whiteView addSubview:view];
        [container addSubview:whiteView];
        [annotationView addSubview:container];
        
        annotationView.enabled = YES;
        annotationView.frame = CGRectMake(0, 0, 75, 75);
    } else {
        annotationView.annotation = annotation;
    }
    return annotationView;
}



- (void)configureNavigationBar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = @"REVIEW";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self configureBackButtonAnimated:YES];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self.navigationItem setTitleView:label];
}

@end
