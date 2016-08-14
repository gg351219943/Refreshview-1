//
//  Refreshview.swift
//  Refreshview
//
//  Created by wangzhangjie on 16/8/14.
//  Copyright © 2016年 wangzhangjie. All rights reserved.
//

import UIKit


public enum refreshState : String{
    case PullRefresh    = "下拉刷新.."
    case ReleaseRefresh = "松手即可刷新.."
    case Refreshing     = "正在为您加载.."
    case PushRefresh    = "上拉加载更多.."
    case None           = ""
}


public extension UITableView{
    
    /**添加刷新组件，同时支持下拉刷新和上拉加载,会自动加载到当前view上，
     *@param:自定义的刷新图片，
     *@param:图片的位置和文字的位置。图片的默认位置为中间
     *
     */
    public func addRefreshControl(images:[UIImage]?,imageCgrect: CGRect?, labelCgrect: CGRect?) ->RefreshView{
        
        var refreshview1 : RefreshView?
        
        refreshview1 = RefreshView(scrollView: self, images: images!, imageCgrect: imageCgrect, labelCgrect: labelCgrect)
        
        self.addSubview(refreshview1!)
        
        return refreshview1!
    }
    
}
@objc
public class RefreshView: UIView/* UIScrollView*/ {
    
    weak var scrollview = UIScrollView()
    
    var isRefreshing = false
    /**是否能下拉加载，默认能，为true*/
    var refreshDownPullEnable : Bool = true
    /**是否有上拉加载效果，默认没有*/
    var refreshUpEnable : Bool = false
    var offsetYY = 0.0
    // 默认动画
    //var indicator = UIActivityIndicatorView()
    // var isAnimating = false
    /*下拉刷新状态，枚举*/
    var refreshStatus : refreshState = .PullRefresh
    // 下拉事件
    var downpullAction : (() -> ())? = nil
    //上拉事件
    var uppullAction  : (() -> ())? = nil
    /**加载的图片*/
    var imageview = UIImageView()
    /**加载的label*/
    var label     = UILabel()
    /**额外信息的label*/
    var extraLabel = UILabel()
    
    var progress : CGFloat = 0.0
    var progressFoot : CGFloat = 0.0
    /**是否渐变，默认true*/
    var isFade = true
    
    // 是否正在上拉
    var directUP : Bool = false
    var tmp : CGFloat  = 0.0
    
    //每次上拉后 新增 内容高度
    var difValue : CGFloat = 0.0 {
        
        willSet{
            
        }
    }
    // contentsize的高度
    var footY : CGFloat = CGFloat(0.0) {
        didSet{
            
            if self.footY - oldValue > 0{
                
                difValue = self.footY - oldValue
                
            }
            
        }
        willSet{
            
            if directUP == true{
                
                self.frame.origin.y = self.footY
                
            }else{
                
            }
            
        }
    }
    
    deinit{
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame : CGRect , scrollView : UITableView){
        scrollview = scrollView
        super.init(frame: frame)
        
        scrollView.delaysContentTouches = false
        self.alpha = 1.0
    }
    
    public convenience init(scrollView : UITableView){
        
        if let sv = scrollView.superview{
            self.init(frame : CGRect(x: 0, y: -60, width: sv.frame.size.width, height: 60) , scrollView : scrollView)
        }else{
            self.init(frame : CGRect(x: 0, y: -60, width: scrollView.frame.size.width, height: 60) , scrollView : scrollView)
        }
        
    }
    
    
    public convenience init(scrollView : UITableView,images :[UIImage],imageCgrect: CGRect?,labelCgrect : CGRect?){
        self.init(scrollView : scrollView)
        if imageCgrect != nil {
            initAndAddImages(imageCgrect!, images: images)
        }else{
            initAndAddImages(CGRect(x: self.frame.size.width/2 - 6 , y: self.frame.size.height/2 - 12, width: 12/*26*/, height: 12/*26*/), images: images)
        }
        
        if labelCgrect != nil{
            initLabel(CGRect(x: self.frame.size.width/2 + 17, y: self.frame.size.height/2 - 26, width: 100, height: 40))
        }else{
            
        }
        
    }
  
    func initExtraLabel(frame : CGRect){
        extraLabel.frame = frame
        
        extraLabel.font = UIFont.systemFontOfSize(12)
        extraLabel.textColor = UIColor.blackColor()
        
        self.addSubview(extraLabel)
    }
    func initLabel(frame :CGRect){
        
        label.frame = frame
        
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.blackColor()
        
        self.addSubview(label)
        
    }
    
    func initAndAddImages(frame : CGRect,images : [UIImage]){
        
        imageview.frame = frame
        
        if images.count < 1{
            print("[UIImage]中没有图片")
        }else if images.count == 1{
            imageview.image = images.last
            
        }else{
            imageview.animationImages = images
            
        }
        
        self.addSubview(imageview)
    }
    
    /**开始执行动画*/
    func executeImagesAnimating(){
        
        
        if imageview.image != nil {
            
        }
        if  imageview.animationImages != nil{
            
            imageview.startAnimating()
            
        }
    }
    /**结束动画*/
    func endImagesAnimating(){
        if imageview.image != nil || imageview.animationImages != nil{
            imageview.stopAnimating()
        }
    }
    
    func endLabelAnimating(){
        refreshStatus = .None
        label.text = refreshStatus.rawValue
    }
    
    /**开始'下拉刷新'*/
    func beginRefresh(){
        if refreshDownPullEnable {
            self.isRefreshing = true
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.3) {
                    
                    //self.scrollview!.contentInset.top += 60
                    self.scrollview!.contentInset.top = 60
                    //self.scrollview?.contentOffset.y  = -60
                    self.alpha = 1
                    self.imageview.animationDuration = 0.8
                    self.imageview.animationRepeatCount = 0
                    self.executeImagesAnimating()
                    self.refreshStatus = .Refreshing
                    self.label.text = self.refreshStatus.rawValue
                }
            }
        }else{
            
        }
    }
    
    /**开始'上拉加载'*/
    func beginRefreshFoot(){
        if refreshUpEnable {
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.3) {
                    self.isRefreshing = true
                    self.executeImagesAnimating()
                    if self.scrollview != nil{
                        self.scrollview!.contentInset.bottom -= 60
                    }
                    //self.scrollview!.frame.origin.y -= 60
                    self.alpha = 1
                    
                }
            }
        }else{
            
        }
        
    }
    /**结束'下拉刷新'的动画。*/
    public func endRefresh(){
        if refreshDownPullEnable {
            dispatch_async(dispatch_get_main_queue()) {
                self.isRefreshing = false
                
                self.endImagesAnimating()
                self.refreshStatus = .None
                
                if self.scrollview is UITableView{
                    (self.scrollview as! UITableView).reloadData()
                }
                
                UIView.animateWithDuration(0.3) {
                    
                    if self.scrollview != nil {
                        self.scrollview!.contentInset.top = 0
                        
                    }
                    self.endImagesAnimating()
                    self.endLabelAnimating()
                }
            }
        }else{
            
        }
        
    }
    
    /**结束'上拉加载'的动画。*/
    public func endRefreshFoot(){
        // self.frame.origin.y = self.scrollview.frame.size.height + 60
        if refreshUpEnable {
            dispatch_async(dispatch_get_main_queue()) {
                self.isRefreshing = false
                
                self.endImagesAnimating()
                self.endLabelAnimating()
                
                if self.scrollview is UITableView{
                    (self.scrollview as! UITableView).reloadData()
                    
                }
                
                UIView.animateWithDuration(0.01) {
                    // 防止刷新控件飘上来－ + self.scrollview.frame.size.height
                    self.frame.origin.y = self.footY + self.scrollview!.frame.size.height
                    if self.scrollview != nil {
                        self.scrollview!.contentInset.bottom += 60
                    }
                    self.alpha = 0.0
                    
                }
            }
            
        }else{
            
        }
    }
    
}


extension RefreshView {
    
    func freshviewDidScroll(scrollView : UIScrollView){
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.footY = scrollView.contentSize.height
        // offY应判断上拉下拉
        let offY = max(-1 * (scrollView.contentOffset.y + scrollView.contentInset.top), 0)
        self.progress = min(offY / self.frame.size.height , 1.0)
        
        // -navigation,tabbar
        let offY_foot = max(scrollView.contentOffset.y /*+ scrollView.contentInset.bottom  - 49 + 60*/, 0)
        // 画个图就能明白上拉的原理了，满足判断条件
        if self.footY < scrollView.frame.size.height{
            
            self.progressFoot = min(offY_foot / 2/*self.frame.size.height*/, 1.0)
        }else{
            //self.progressFoot = min(offY_foot  / (self.frame.size.height + self.footY - scrollView.frame.size.height), 1.0)
            //wzj
            let minusHeight = max(offY_foot + scrollView.frame.size.height - self.footY - 49, 0)
            self.progressFoot = min( minusHeight / 2/*self.frame.size.height*/ , 1.0)
            
        }
        
        
        if refreshDownPullEnable {
            if self.progress > 0 && self.progressFoot == 0{
                self.executeImagesAnimating()
                self.directUP = false
                
                if scrollView.dragging && !self.isRefreshing {
                    //正在下拉
                    self.frame.origin.y = -60
                    
                }else {
                    
                }
                
                if !self.isRefreshing{
                    if self.progress < 1 {
                        self.refreshStatus = .PullRefresh
                        self.label.text = self.refreshStatus.rawValue
                        
                    }else{
                        self.refreshStatus = .ReleaseRefresh
                        //   self.label.text = self.refreshStatus.rawValue
                        
                    }
                }else{
                    self.refreshStatus = .Refreshing
                    // self.label.text = self.refreshStatus.rawValue
                    
                }
                // 透明度
                
                if self.progress < 0.1 {
                    if self.isRefreshing {
                        self.alpha = 1
                    }else{
                        self.alpha = 0
                    }
                    
                }else{
                    
                    if self.isRefreshing {
                        self.alpha = 1
                    }else{
                        self.alpha = 4 * (self.progress - 0.1)
                    }
                    
                }
                
            }
        }else{
            
        }
        // 上拉的逻辑部分
        if refreshUpEnable {
            
            if progressFoot > 0 && progress == 0{
                executeImagesAnimating()
                
                if scrollView.dragging && !isRefreshing{
                    
                    //正在上拉
                    self.directUP = true
                    
                    self.footY = scrollView.contentSize.height
                    
                }else {
                    // self.directUP = false
                }
                
                // 上拉文字以及状态的变化
                if !isRefreshing{
                    if progressFoot < 1 {
                        refreshStatus = .PushRefresh
                        label.text = refreshStatus.rawValue
                        
                        self.alpha = 4 * (progressFoot - 0.2)
                        
                    }else{
                        refreshStatus = .ReleaseRefresh
                        label.text = refreshStatus.rawValue
                        
                        self.alpha = 1
                    }
                }else{
                    refreshStatus = .Refreshing
                    label.text = refreshStatus.rawValue
                    
                    self.alpha = 1
                    //悬停,直接动scrollview
                }
                
            }
            
        }else{
            
        }
        
        if !self.isRefreshing && self.progressFoot == 0 && self.progress == 0{
            self.endImagesAnimating()
            self.endLabelAnimating()
            self.isRefreshing = false
        }
    }
    
    func freshviewDidEndDragging(/*decelerate: Bool ,*/yourRefreshAction : (() -> ())?,yourUpPullAction : (() -> ())?){
        
        //if (!decelerate) {
        if !self.isRefreshing && self.progress >= 1 && self.progressFoot == 0 {
            if refreshDownPullEnable {
                self.beginRefresh()
                
                dispatch_async(dispatch_get_main_queue(), {
                    if yourRefreshAction != nil {
                        yourRefreshAction!()
                        
                    }
                })
                
            }
        }
        
        //上拉标示
        if !self.isRefreshing && self.progressFoot >= 1 && progress == 0 {
            
            if refreshUpEnable {
                self.beginRefreshFoot()
                
                dispatch_async(dispatch_get_main_queue(), {
                    if yourUpPullAction != nil{
                        yourUpPullAction!()
                    }
                })
            }
        }
        
        // progressFoot 和 progress应一起比较
        if !self.isRefreshing && self.progressFoot > 0 && progress == 0{
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.3) {
                    //回到内容的底部
                    self.imageview.stopAnimating()
                    
                    self.scrollview!.contentInset.bottom = 49 //tabbar
                    self.frame.origin.y = self.footY
                    self.alpha = 1.0
                    
                }
            }
        }
        
        self.directUP = false
    }
    
    // }
}


extension RefreshView : UIScrollViewDelegate{
    
}

