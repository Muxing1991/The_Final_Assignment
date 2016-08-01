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
      //设置scrollView不要延缓touch
      scrollView.delaysContentTouches = false
    }
  }
  
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  //MARK: - saveImageButton
  var saveImageButton: UIButton = {
    let sib = UIButton()
    sib.setTitle("保存", forState: .Normal)
    sib.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    sib.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
    sib.backgroundColor = UIColor.lightGrayColor()
    sib.layer.cornerRadius = 5.0
    sib.layer.masksToBounds = true
    sib.frame = CGRect(x: 0, y: 0, width: 1, height:1)
    //#selector  来自self ImageViewController.saveImage 触发条件为TouchDown
    sib.addTarget(nil, action: #selector(ImageViewController.saveImage), forControlEvents: .TouchDown)
    
    return sib
  }()
  
  func saveImage(){
    
    UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(ImageViewController.image(_:didFinishSavingWithError:contentInfo:)), nil)
  }
  

  func image(image: UIImage, didFinishSavingWithError: NSError?, contentInfo: AnyObject){
    if let error = didFinishSavingWithError{
      print(error)
    }else {
      messageSaveToAblum(true)
    }
  }

  //黑框显示 逐渐消失的动画  这里触发了viewDidLayoutSubview 所以 图片会调整 要修改
  //算了 不修改了
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
    msgLabel.text = success ? "成功保存 😉" : "保存失败 😳"
    msgLabel.textColor = UIColor.whiteColor()
    msgLabel.textAlignment = .Center
    msgLabel.backgroundColor = UIColor.clearColor()
    msgLabel.font = UIFont.boldSystemFontOfSize(20)
    msgLabel.sizeToFit()
    showView.addSubview(msgLabel)
    
    showView.frame = CGRectMake((view.frame.width - msgLabel.frame.width - 20) / 2, (view.frame.height - msgLabel.frame.height)/2, msgLabel.frame.width + 20, msgLabel.frame.height + 10)
    
    UIView.animateWithDuration(3, animations: {
        showView.alpha = 0
    }){ (_) in
      showView.removeFromSuperview()
    }
      
    
    
  }
  
  //MARK: - Gesture
  
  @IBAction func doubleTap(sender: UITapGestureRecognizer) {
    guard image != nil else{
      return
    }
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
      if newValue != nil {
        view.addSubview(saveImageButton)
        msgLabel.removeFromSuperview()
      }
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
  
  private var msgLabel = UILabel()
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
              //print("error can't get image data")
              //改成类似系统应用的灰色字体提示
              self.displayGrayNotification("无法下载图片 请检查网络连接")
            }
          }
          self.spinner.stopAnimating()
        }
      }
    }
  }
  
  
  private func displayGrayNotification(msg: String){
    msgLabel.text = msg
    msgLabel.textColor = UIColor.lightGrayColor()
    msgLabel.font = UIFont(name: "Arial", size: 34)
    msgLabel.backgroundColor = UIColor.clearColor()
    msgLabel.sizeToFit()
    msgLabel.frame.origin = scrollView.center
    msgLabel.frame.origin.x -= msgLabel.frame.width/2
    scrollView.addSubview(msgLabel)
  }
  
  
  
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.addSubview(imageView)
    //imageURL = NSURL(string: "http://p1.pichost.me/i/64/1884418.jpg")
    //imageURL = NSURL(string: "http://i7.umei.cc//img2012/2016/05/21/010Flash20141118/10.jpg")
    //imageURL = NSURL(string: "https://www.apple.com/cn/home/images/heros/apple_watch_trio_medium_2x.jpg")
    //image = UIImage(named: "apple_watch_trio_medium_2x")
    imageURL = NSURL(string: "http://images.apple.com/v/iphone/home/s/home/images/why_iphone_bg_large_2x.jpg")
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
      //重新设置保存按钮的位置 。。。。 学习怎么用代码来实现autolayout！
      saveImageButton.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 86, y: UIScreen.mainScreen().bounds.height - 60, width: 66, height: 45)
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
