//
//  ProvinceTableViewCell.swift
//  TheFinalAssignment
//
//  Created by 杨威 on 16/8/4.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class ProvinceTableViewCell: UITableViewCell {
  
  //MARK: - IBOutlet
  
  
  @IBOutlet weak var backgroundImage: UIImageView!
  
  
  
  @IBOutlet weak var provinceNameLabel: CellUILabel!
  
  
  //MARK: - Modal
  var bgImage: UIImage!{
    didSet{
      backgroundImage.image = bgImage
      updateUI()
    }
  }
  
  var name: String!{
    didSet{
      provinceNameLabel.text = name
      provinceNameLabel.sizeToFit()
      updateUI()
    }
  }
  
  
  
 
  private func updateUI(){
    setNeedsDisplay()
  }
  
  

  
  

  
}


class CellUILabel: UILabel{
  private var padding = UIEdgeInsetsZero
  
  @IBInspectable
  var paddingLeft: CGFloat {
    get { return padding.left }
    set { padding.left = newValue }
  }
  
  @IBInspectable
  var paddingRight: CGFloat {
    get { return padding.right }
    set { padding.right = newValue }
  }
  
  @IBInspectable
  var paddingTop: CGFloat {
    get { return padding.top }
    set { padding.top = newValue }
  }
  
  @IBInspectable
  var paddingBottom: CGFloat {
    get { return padding.bottom }
    set { padding.bottom = newValue }
  }
  
  override func drawTextInRect(rect: CGRect) {
    super.drawTextInRect(UIEdgeInsetsInsetRect(rect, padding))
  }
  
  override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    let insets = self.padding
    var rect = super.textRectForBounds(UIEdgeInsetsInsetRect(bounds, insets), limitedToNumberOfLines: numberOfLines)
    rect.origin.x    -= insets.left
    rect.origin.y    -= insets.top
    rect.size.width  += (insets.left + insets.right)
    rect.size.height += (insets.top + insets.bottom)
    return rect
  }
}
