//
//  touchPad.swift
//  robotRemote
//
//  Created by localadmin on 22.05.19.
//  Copyright © 2019 ch.cqd.remoteCode. All rights reserved.
//

import UIKit

class TouchPad: UIView {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = event?.allTouches?.first {
      let position:CGPoint = touch.location(in: self)
      print("position")
      if position.x < 0 || position.y < 0 || position.x > 240 || position.y > 240 {
        print("outside")
      } else {
        print("inside \(position)")
      }
      
      /*
       // Only override draw() if you perform custom drawing.
       // An empty implementation adversely affects performance during animation.
       override func draw(_ rect: CGRect) {
       // Drawing code
       }
       */
      
    }
  }
}
