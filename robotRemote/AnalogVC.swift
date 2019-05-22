//
//  AnalogVC.swift
//  robotRemote
//
//  Created by localadmin on 22.05.19.
//  Copyright © 2019 ch.cqd.remoteCode. All rights reserved.
//

import UIKit

class AnalogVC: UIViewController, UpdateDisplayDelegate, FeedBackConnection, ChangeTag {

  func newName(_ value: String) {
    // rien
  }
  
  func ok(_ value: String) {
    // rien
  }
  
  func bad(_ value: String) {
    // rien
  }
  
  func port(_ value: String) {
    // rein
  }
  

  @IBOutlet weak var port1: UILabel!
  @IBOutlet weak var port2: UILabel!
  @IBOutlet weak var port3: UILabel!
  @IBOutlet weak var port4: UILabel!
  
  @IBOutlet weak var portA: UILabel!
  @IBOutlet weak var portB: UILabel!
  @IBOutlet weak var portC: UILabel!
  @IBOutlet weak var portD: UILabel!
  
  @IBOutlet weak var touchPad: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    chatRoom.delegate = self
    chatRoom.connection = self
    chatRoom.rename = self
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = event?.allTouches?.first {
      
      let position:CGPoint = touch.location(in: touchPad)
//      print("position")
      if position.x < 0 || position.y < 0 || position.x > 240 || position.y > 240 {
//        print("outside")
      } else {
        let figure2S = calcPoint(cord2D: position) + "\n"
        chatRoom.sendMessage(message: figure2S)
      }
    }
  }
  
  func calcPoint(cord2D: CGPoint) -> String {
    let xPosition = cord2D.x - 120
    let yPosition = cord2D.y - 120
    
    if xPosition < 0 && yPosition > 0 {
      let joyX = -round(xPosition / 120 * -100)
      let joyY = round(yPosition / 120 * 100)
//      print("BL \(xPosition) \(yPosition) \(joyX) \(joyY)")
      let string2R = "J:\(joyX):\(joyY)"
//      print("string2R \(string2R)\n")
      return string2R
    }
    
    if xPosition > 0 && yPosition > 0 {
      let joyX = round(xPosition / 120 * 100)
      let joyY = round(yPosition / 120 * 100)
//      print("BR \(xPosition) \(yPosition) \(joyX) \(joyY)")
      let string2R = "J:\(joyX):\(joyY)"
//      print("string2R \(string2R)\n")
      return string2R
    }
    
    if xPosition < 0 && yPosition < 0 {
      let joyX = -round(xPosition / 120 * -100)
      let joyY = -round(yPosition / 120 * -100)
//      print("TL \(xPosition) \(yPosition) \(joyX) \(joyY)")
      let string2R = "J:\(joyX):\(joyY)"
//      print("string2R \(string2R)\n")
      return string2R
    }
    
    if xPosition > 0 && yPosition < 0 {
      let joyX = round(xPosition / 120 * 100)
      let joyY = -round(yPosition / 120 * -100)
//      print("TR \(xPosition) \(yPosition) \(joyX) \(joyY)")
      let string2R = "J:\(joyX):\(joyY)"
//      print("string2R \(string2R)\n")
      return string2R
    }
    let string2R = "J:\(0):\(0)"
//    print("string2R \(string2R)\n")
    return string2R
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    if let touch = event?.allTouches?.first {
//      let position:CGPoint = touch.location(in: touchPad)
//      print("position")
//      if position.x < 0 || position.y < 0 || position.x > 240 || position.y > 240 {
//        print("outside")
//      } else {
//        print("inside \(position)")
//      }
    }
    

        // Do any additional setup after loading the view.
    
  
  
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
