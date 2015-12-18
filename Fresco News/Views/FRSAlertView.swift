//
//  FRSAlertView.swift
//  FRSAlertView-Swift
//
//  Created by Omar Elfanek on 12/14/15.
//  Copyright © 2015 Omar Elfanek. All rights reserved.
//

import UIKit



protocol FRSAlertViewDelegate:class {
    func DidPressButtonAtIndex(index: Int)
}

@objc class FRSAlertView: UIView {
    let overlayView = UIView (frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    let alertView = UIView (frame: CGRectMake(0, 0, 0, 0))
    let titleLabel = UILabel (frame: CGRectMake(0, 0, 0, 44))
    let bodyLabel = UILabel (frame: CGRectMake(16, 44, 0, 120))
    let leftAction = UIButton(type: .System)
    let rightAction = UIButton(type: .System)
    let buttonShadow = UIView (frame: CGRectMake(0,0,0,0))
    weak var delegate:FRSAlertViewDelegate?
    
    
    init (title: String, body: String, height:CGFloat, actionCount:CGFloat, leftActionTitle:String, rightActionTitle:String, delegate:FRSAlertViewDelegate){
        
        super.init(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width), UIScreen.mainScreen().bounds.size.height, 0, 0))
        
        self.delegate = delegate
        
        /* Dark Overlay */
        self.overlayView.backgroundColor = UIColor.blackColor()
        self.overlayView.alpha = 0
        UIApplication.sharedApplication().keyWindow?.addSubview(self.overlayView)
        
        /* Alert Box */
        self.frame = CGRectMake((UIScreen.mainScreen().bounds.size.width - 270)/2, (UIScreen.mainScreen().bounds.size.height - height)/2,270,height)
        self.center = self.center
        self.backgroundColor = UIColor.init(red: 250, green: 250, blue: 250, alpha: 1)
        self.backgroundColor = UIColor.whiteColor()
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 4)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.1
        self.layer.cornerRadius = 2
        self.alpha = 0
        
        self.transform = CGAffineTransformMakeScale(1.175, 1.175)
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.alpha = 1
            self.titleLabel.alpha = 1
            self.bodyLabel.alpha = 1
            self.leftAction.alpha = 1
            self.overlayView.alpha = 0.26
            self.transform = CGAffineTransformMakeScale(1, 1)
            }) { (YES) -> Void in
        }
        
        /* Title Label */
        titleLabel.frame = (CGRectMake (0, 0, 270, 44))
        titleLabel.font = UIFont(name: "Nota-Bold", size: 17)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = title as String
        titleLabel.alpha = 0.87
        self.addSubview(titleLabel)
        
        /* Body Label */
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        let attributes = [NSParagraphStyleAttributeName : style]
        bodyLabel.attributedText = NSAttributedString(string: body as String, attributes:attributes)
        bodyLabel.frame = (frame: CGRectMake((self.frame.size.width - 238)/2, 44, 238, height - 96)) // buttonHeight + buttonHeight + 8px padding = 96
        bodyLabel.alpha = 0.54
        bodyLabel.textAlignment = NSTextAlignment.Center
        bodyLabel.text = body as String
        
        if #available(iOS 8.2, *) {
            bodyLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
        } else {
            // Fallback on earlier versions
//            bodyLabel.font = UIFont.fontNamesForFamilyName("")
//            bodyLabel.font = UIFont.init(name: "", size: 15)
        };
        
        bodyLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        bodyLabel.numberOfLines = 0
        bodyLabel.sizeToFit()
        self.addSubview(bodyLabel)
        bodyLabel.frame = CGRectMake((self.frame.size.width - bodyLabel.frame.size.width)/2, 44, bodyLabel.frame.size.width, bodyLabel.frame.size.height)
        
        /* Button Shadow */
        buttonShadow.frame = CGRectMake (0, height - 44, 270, 1)
        buttonShadow.backgroundColor = UIColor.whiteColor()
        buttonShadow.layer.shadowColor = UIColor.blackColor().CGColor
        buttonShadow.layer.shadowOffset = CGSizeMake(0, -1)
        buttonShadow.layer.shadowRadius = 0
        buttonShadow.layer.shadowOpacity = 0.12
        self.addSubview(buttonShadow)
        
        /* Action Buttons */
        if actionCount == 1{
            leftAction.frame = CGRectMake (0, height - 44, 270, 44)
            leftAction.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
            leftAction.setTitle(leftActionTitle, forState: .Normal)
            leftAction.setTitleColor(UIColor (colorLiteralRed: 0.0, green: 0.28, blue: 0.73, alpha: 1.0), forState: .Normal)
            leftAction.titleLabel!.font = UIFont(name: "Nota-Bold", size: 15)
            self.addSubview(leftAction)
            
        } else if actionCount == 2{
            
            /* Left Action */
            leftAction.frame = CGRectMake (0, height - 44, 85, 44)
            leftAction.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
            leftAction.setTitle(leftActionTitle, forState: .Normal)
            leftAction.setTitleColor(UIColor.blackColor(), forState: .Normal)
            leftAction.alpha = 0.87
            leftAction.backgroundColor = UIColor.whiteColor()
            leftAction.titleLabel!.font = UIFont(name: "Nota-Bold", size: 15)
            leftAction.layer.cornerRadius = 2
            leftAction.clipsToBounds = true
            self.addSubview(leftAction)
            
            /* Right Action */
            rightAction.frame = CGRectMake (169, height - 44, 101, 44)
            rightAction.addTarget(self, action: "customAction:", forControlEvents: .TouchUpInside)
            rightAction.setTitle(rightActionTitle, forState: .Normal)
            rightAction.setTitleColor(UIColor (colorLiteralRed: 0.0, green: 0.28, blue: 0.73, alpha: 1.0), forState: .Normal)
            rightAction.backgroundColor = UIColor.whiteColor()
            rightAction.titleLabel!.font = UIFont(name: "Nota-Bold", size: 15)
            rightAction.layer.cornerRadius = 2;
            rightAction.clipsToBounds = true
            self.addSubview(rightAction)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func dismiss(sender: UIButton!) {
        
        print("left action")
        
        if self.delegate != nil {
            self.delegate?.DidPressButtonAtIndex(0)
        }
        
        
        dismissAnimation()
        
    }
    
    func customAction(sender: UIButton!) {
        
        print("right action")
        
        if self.delegate != nil {
            self.delegate?.DidPressButtonAtIndex(1)
        }
        
        dismissAnimation()
    }
    
    func dismissAnimation() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.9, 0.9)
            self.alpha = 0
            self.titleLabel.alpha = 0
            self.bodyLabel.alpha = 0
            self.leftAction.alpha = 0
            self.overlayView.alpha = 0
            }) { (YES) -> Void in
                self.removeFromSuperview()
        }
    }
    
    class func CancelButtonIndex() -> Int {
        return 0
    }
}
