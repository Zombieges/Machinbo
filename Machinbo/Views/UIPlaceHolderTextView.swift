//
//  UIPlaceHolderTextView.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/04/08.
//  Copyright (c) 2016年 Zombieges. All rights reserved.
//

import UIKit

class PlaceholderProperty:NSObject
{
    var PlaceholderString:String!
    var PlaceholderColor :UIColor = UIColor.lightGrayColor()
    var PlaceholderFont  :UIFont!
    
    
}

class UIPlaceHolderTextView: UITextView {
    
    private var PlaceholderLabel:UILabel?;
    private var PlaceholderColor:UIColor?
    
    func addPlaceholder(){
        
        let leff:CGFloat=5,top:CGFloat=0,height:CGFloat=30;
        PlaceholderLabel=UILabel(frame: CGRectMake(leff, top, CGRectGetWidth(self.frame)-2*leff, height));
        
        self.addSubview(PlaceholderLabel!);
        PlaceholderLabel!.backgroundColor=UIColor.clearColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changeDidText:"), name: UITextViewTextDidChangeNotification, object: nil);
        
        
    }
    
    
    /// 重载 原来 text 属性
    override var text:String!{
        get{
            
            return super.text;
        }
        set(Newtext){
            if Newtext.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
            {
                PlaceholderLabel?.hidden=true;
            }
            
            super.text=Newtext;
        }
        
    }
    
    
    
    func changeDidText(noti : NSNotification){
        if self.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)==0
        {
            PlaceholderLabel!.hidden=false
        }
        else
        {
            PlaceholderLabel!.hidden=true
        }
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    
    init(frame: CGRect, textContainer: NSTextContainer? ,Placeholder: PlaceholderProperty) {
        super.init(frame: frame, textContainer: textContainer)
        self.addPlaceholder()
        PlaceholderLabel!.text=Placeholder.PlaceholderString;
        PlaceholderLabel!.textColor=Placeholder.PlaceholderColor
        PlaceholderLabel!.font=Placeholder.PlaceholderFont==nil ? Placeholder.PlaceholderFont:self.font;
        //PlaceholderLabel!.font=UIFont(name: self.font.fontName, size: 13)!
        
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}
