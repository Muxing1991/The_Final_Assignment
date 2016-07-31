//
//  ImageViewController.swift
//  MyTrack2
//
//  Created by 杨威 on 16/7/22.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
  
  //MARK: - IBOutlet
  
  @IBOutlet weak var scrollView: UIScrollView!{
    didSet{
      scrollView.delegate = self
      //imageView就是书桌
      scrollView.contentSize = imageView.frame.size
      scrollView.maximumZoomScale = 5
    }
  }
  
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  
  //MARK: - Gesture
  
  @IBAction func longPressToSaveImage(sender: UILongPressGestureRecognizer) {
    if sender.state == .Began{
      let alert = UIAlertController(title: nil, message: "保存图片", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "保存", style: .Default){
        (alert) in
        UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(ImageViewController.image(_:didFinishSavingWithError:contentInfo:)), nil)
        })
      presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  
  func image(image: UIImage, didFinishSavingWithError: NSError?, contentInfo: AnyObject){
    if let error = didFinishSavingWithError{
      print(error)
    }else {
      messageSaveToAblum(true)
    }
  }

  //通知栏 显示保存成功与否
  //使用UILocalNotification fireData: 设置激发时间 alertBody: 设置内容
  // timeZone: 设置激发时区  soundName: 设置声音
  //applicationBadgeNumber: 设置图标的通知数 现在没啥卵用
  //使用scheduleLocalNotification 将 通知加入队列即可
  
  //经实验 本地通知只能在app在后台时才能以横幅的形式展现
//  private func messageSaveToAblum(succelss: Bool){
//    let localNotifcation = UILocalNotification()
//    localNotifcation.fireDate = NSDate(timeIntervalSinceNow: 5)
//    localNotifcation.alertBody = succelss ? "保存成功 😉" : "保存失败 😳"
//    localNotifcation.timeZone = NSTimeZone.defaultTimeZone()
//    localNotifcation.soundName = UILocalNotificationDefaultSoundName
//    
//    //TODO: 图标的完成
//    //localNotifcation.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
//    UIApplication.sharedApplication().scheduleLocalNotification(localNotifcation)
//    
//  }
  
  //黑框显示 逐渐消失的动画  这里出发了viewDidLayoutSubview 所以 图片会调整 要修改
  // 位置要调整
  private func messageSaveToAblum(success: Bool){
    let showView = UIView()
    showView.backgroundColor = UIColor.blackColor()
    showView.frame = CGRectMake(1, 1, 1, 1)
    showView.alpha = 1.0
    showView.layer.cornerRadius = 5.0
    showView.layer.masksToBounds = true
    view.addSubview(showView)
    
    let msgLabel = UILabel()
    msgLabel.frame.origin = CGPointMake(10, 5)
    msgLabel.text = "成功保存 😉"
    msgLabel.textColor = UIColor.whiteColor()
    msgLabel.textAlignment = .Center
    msgLabel.backgroundColor = UIColor.clearColor()
    msgLabel.font = UIFont.boldSystemFontOfSize(20)
    msgLabel.sizeToFit()
    showView.addSubview(msgLabel)
    
    showView.frame = CGRectMake((view.frame.width - msgLabel.frame.width - 20) / 2, view.frame.height - 200, msgLabel.frame.width + 20, msgLabel.frame.height + 10)
    
    UIView.animateWithDuration(3, animations: {
        showView.alpha = 0
    }){ (_) in
      showView.removeFromSuperview()
    }
      
    
    
  }
  
  @IBAction func doubleTap(sender: UITapGestureRecognizer) {
    sender.numberOfTapsRequired = 2
  
    if scrollView.zoomScale > scrollView.minimumZoomScale{
      scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    } else {
      let newScale = scrollView.zoomScale * 2
      let zoomRect = zoomRectForScale(newScale, withCenter: sender.locationInView(scrollView))
      scrollView.zoomToRect(zoomRect, animated: true)
    }
  }
  
  private func zoomRectForScale(scale: CGFloat, withCenter center: CGPoint) -> CGRect{
    var zoomRect = CGRect()
    zoomRect.size.height = imageView.frame.size.height / scale
    zoomRect.size.width = imageView.frame.size.width / scale
    //把双击的位置从scrollView 转换到 imageView
    let newCenter = imageView.convertPoint(center, fromView: scrollView)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
    
    return zoomRect
  }
  
  //MARK: - Model
  
  var imageURL: NSURL?{
    didSet{
      image = nil
      if view.window != nil{
        fetchImageFromURL()
      }
    }
  }
  
  var image: UIImage?{
    get{
      return imageView.image
    }
    set{
      imageView.image = newValue
      aspectratio = newValue?.aspectratio
      imageView.sizeToFit()
      //设定滑动的区域为图片的大小
      scrollView.contentSize = imageView.frame.size
      //设置初始的比例
      scrollView.setZoomScale(scrollCurrentScale(), animated: true)
      //居中处理
      setScorllImageViewCenter()
      spinner.stopAnimating()
    }
  }
  
  private func scrollCurrentScale() -> CGFloat{
    if let image = image,aspectratio = aspectratio{
      //如果图片是高窄的
      if aspectratio >= 1 && image.size.height > scrollView.frame.height{
        let zoomToHeight = scrollView.frame.height / image.size.height
        scrollView.minimumZoomScale = zoomToHeight
        return zoomToHeight
      } else if aspectratio < 1 && image.size.width > scrollView.frame.width{
        //图片是宽矮的
        let zoomToWidth =  scrollView.frame.width / image.size.width
        scrollView.minimumZoomScale = zoomToWidth
        return zoomToWidth
      }
      
    }
    return 1
  }
  
  
  
  //图片纵横比 高／宽
  var aspectratio: CGFloat?
  //这是用来展示图片的View
  private var imageView = UIImageView()
  
  //MARK: Method
  private func fetchImageFromURL(){
    if let url = imageURL{
      spinner.startAnimating()
      dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
        let imageData = NSData(contentsOfURL: url)
        dispatch_async(dispatch_get_main_queue()){
          if url == self.imageURL{
            if let data = imageData{
              self.image = UIImage(data: data)
            }else {
              print("error can't get image data")
            }
          }
          self.spinner.stopAnimating()
        }
      }
    }
  }
  
  
  
  
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.addSubview(imageView)
    imageURL = NSURL(string: "http://p1.pichost.me/i/64/1884418.jpg")
    //imageURL = NSURL(string: "http://i7.umei.cc//img2012/2016/05/21/010Flash20141118/10.jpg")
    //imageURL = NSURL(string: "https://www.apple.com/cn/home/images/heros/apple_watch_trio_medium_2x.jpg")
    //image = UIImage(named: "apple_watch_trio_medium_2x")
    //imageURL = NSURL(string: "http://images.apple.com/v/iphone/home/s/home/images/why_iphone_bg_large_2x.jpg")
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if image == nil{
      fetchImageFromURL()
    }
  }
  
  //屏幕旋转后 再次居中 适应比例
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if imageView.image != nil{
      //设置初始的比例
      scrollView.setZoomScale(scrollCurrentScale(), animated: true)
      //居中处理
      setScorllImageViewCenter()
    }
  }
  
  
  //MARK: - UIScrollViewDelegate
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  //在缩放时 实时计算居中
  func scrollViewDidZoom(scrollView: UIScrollView) {
    setScorllImageViewCenter()
  }
  
  private func setScorllImageViewCenter(){
    let boundWidth = scrollView.bounds.width
    let boundHeight = scrollView.bounds.height
    let contentWidth = scrollView.contentSize.width
    let contentHeight = scrollView.contentSize.height
    //在图片被缩小到screen以内时 才修正offset
    let offSetX = boundWidth > contentWidth ? (boundWidth - contentWidth)*0.5 : 0.0
    let offSetY = boundHeight > contentHeight ? (boundHeight - contentHeight)*0.5 : 0.0
    imageView.center = CGPointMake(contentWidth*0.5 + offSetX, contentHeight*0.5 + offSetY)
  }
}

extension UIImage{
  var aspectratio: CGFloat{
    return size.height / size.width
  }
}
