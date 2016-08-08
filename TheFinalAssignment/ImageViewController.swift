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
    sib.backgroundColor = UIColor.init(white: 0.667, alpha: 0.5)//LightGrayColor
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
  
  private func addTapEvent(){
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.doubleTapToZoomToRect))
    doubleTap.numberOfTapsRequired = 2
    doubleTap.numberOfTouchesRequired = 1
    
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.singleTapToHideNavBar))
    singleTap.numberOfTouchesRequired = 1
    singleTap.numberOfTouchesRequired = 1
    singleTap.requireGestureRecognizerToFail(doubleTap)
    //添加到self.view中
    self.view.addGestureRecognizer(doubleTap)
    self.view.addGestureRecognizer(singleTap)
  }
 
  @objc private func doubleTapToZoomToRect(sender: UITapGestureRecognizer){
    guard image != nil else {
      return
    }
    //更新 设置当内容的size大于等于边界时 就缩放到适合屏幕的大小
    //否则 放大两倍
    if scrollView.contentSize.height >= UIScreen.mainScreen().bounds.height && scrollView.contentSize.width >= UIScreen.mainScreen().bounds.width{
      scrollView.setZoomScale(scrollCurrentScale(), animated: true)
    }else {
      let newScale = scrollView.zoomScale * 2
      let zoomRect = zoomRectForScale(newScale, withCenter: sender.locationInView(scrollView))
      scrollView.zoomToRect(zoomRect, animated: true)
    }

  }
  
  @objc private func singleTapToHideNavBar(sender: UITapGestureRecognizer){
    isNavBarHidden = !isNavBarHidden
    self.navigationController?.setNavigationBarHidden(isNavBarHidden, animated: true)
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
      //设置初始的比例  设置false的animated 在变化比例时不需要动画 更符合zhihu之类
      scrollView.setZoomScale(scrollCurrentScale(), animated: false)
      //居中处理
      setScorllImageViewCenter()
      spinner.stopAnimating()
    }
  }
  
  
  private func scrollCurrentScale() -> CGFloat{
    if let image = image,aspectratio = aspectratio{
      //如果图片是高窄的
      if aspectratio >= 1 && image.size.height > UIScreen.mainScreen().bounds.height{
        let zoomToHeight = UIScreen.mainScreen().bounds.height / image.size.height
        scrollView.minimumZoomScale = zoomToHeight
        return zoomToHeight
      } else if aspectratio < 1 && image.size.width > UIScreen.mainScreen().bounds.width{
        //图片是宽矮的
        let zoomToWidth =  UIScreen.mainScreen().bounds.width / image.size.width
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
  
  var isNavBarHidden = false
  
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
  
  //MARK: - UIViewController Method
  //隐藏系统的状态栏  电量 时间 信号等信息
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.addSubview(imageView)
    addTapEvent()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if image == nil{
      fetchImageFromURL()
    }
    
    if imageView.image != nil{
      //设置初始的比例
      scrollView.setZoomScale(scrollCurrentScale(), animated: false)
      //居中处理
      setScorllImageViewCenter()
      //重新设置保存按钮的位置 。。。。 学习怎么用代码来实现autolayout！
      saveImageButton.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 86, y: UIScreen.mainScreen().bounds.height - 60, width: 66, height: 45)
    }
  }
  

  
  //屏幕旋转后 再次居中 适应比例 // 放弃在这里调整 采用UIScreen来获取设备的size
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

  }
  
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    if imageView.image != nil{
      //依据iOS照片app  放弃在旋转后 调整缩放
      //scrollView.setZoomScale(scrollCurrentScale(), animated: false)
      
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
    let boundWidth = UIScreen.mainScreen().bounds.width
    let boundHeight = UIScreen.mainScreen().bounds.height
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
