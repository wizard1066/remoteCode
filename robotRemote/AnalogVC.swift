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
     let blob = value.components(separatedBy: ":")
    // Change the labels on the buttons
//    print("blob.count",blob.count,value)
    if blob.count <= 2 {
      return // corrupted data
    }

    // Change the labels of the ports
    for ports in xPort {
      if blob[1] == ports.key {
        xPort[ports.key] = blob[2]
      }
    }
    // Change the text return when you hit keys
    for button in xButton {
      if blob[1] == button.key {
        xButton[button.key] = blob[2]
      }
    }
  }
  
  func ok(_ value: String) {
    let alertController = UIAlertController(title: value, message: value, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func bad(_ value: String) {
    let alertController = UIAlertController(title: value, message: value, preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
      alertController.addAction(defaultAction)
      self.present(alertController, animated: true, completion: {
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
          chatRoom.stopChat()
          self.performSegue(withIdentifier: "returnToConnect", sender: self)
        })
      })
  }
  
  func port(_ value: String) {
    let blob = value.components(separatedBy: ":")

    switch blob[0] {
      case "port1":
        let replaced = value.replacingOccurrences(of: "port1", with: xPort["port1"]!)
        port1.text = replaced
        break
      case "port2":
        let replaced = value.replacingOccurrences(of: "port2", with: xPort["port2"]!)
        port2.text = replaced
        break
      case "port3":
        let replaced = value.replacingOccurrences(of: "port3", with: xPort["port3"]!)
        port3.text = replaced
        break
      case "port4":
        let replaced = value.replacingOccurrences(of: "port4", with: xPort["port4"]!)
        port4.text = replaced
        break
      case "portA":
        let replaced = value.replacingOccurrences(of: "portA", with: xPort["portA"]!)
        portA.text = replaced
        break
      case "portB":
        let replaced = value.replacingOccurrences(of: "portB", with: xPort["portB"]!)
        portB.text = replaced
        break
      case "portC":
        let replaced = value.replacingOccurrences(of: "portC", with: xPort["portC"]!)
        portC.text = replaced
        break
      case "portD":
        let replaced = value.replacingOccurrences(of: "portD", with: xPort["portD"]!)
        portD.text = replaced
        break
      default:
        print("syntax \(value)")
      }
  }
  
  @IBOutlet weak var topSV: UIStackView!
  @IBOutlet weak var lowSV: UIStackView!
  
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
  
  override func viewDidAppear(_ animated: Bool) {
    chatRoom.sendMessage(message: "#\n")
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = event?.allTouches?.first {
      let position:CGPoint = touch.location(in: touchPad)
      if position.x < 0 || position.y < 0 || position.x > 240 || position.y > 240 {
        // ignore it
      } else {
        let figure2S = calcPoint(cord2D: position) + "\n"
        chatRoom.sendMessage(message: figure2S)
      }
    }
  }
  
  func calcPoint(cord2D: CGPoint) -> String {
    // Need to subtract 120 cause the pad is 240 pixels wide
  
    let xPosition = cord2D.x - 120
    let yPosition = cord2D.y - 120
    
    // Need to multiply by a negative number cause the model needs to work that way
    // Need to multiply by 100 cause I need a number between 1-100
    
    let joyX = round(xPosition / 120 * 100)
    let joyY = round(yPosition / 120 * -100)
    print("XX \(xPosition) \(yPosition) \(joyX) \(joyY)")
    
    let string2R = "@:\(joyX):\(joyY)"
    return string2R
    
//    if xPosition < 0 && yPosition > 0 {
//      let joyX = -round(xPosition / 120 * -10)/10
//      let joyY = round(yPosition / 120 * 10)/10
////      print("BL \(xPosition) \(yPosition) \(joyX) \(joyY)")
//      let string2R = "@:\(joyX):\(joyY)"
////      print("string2R \(string2R)\n")
//      return string2R
//    }
//
//    if xPosition > 0 && yPosition > 0 {
//      let joyX = round(xPosition / 120 * 10)/10
//      let joyY = round(yPosition / 120 * 10)/10
////      print("BR \(xPosition) \(yPosition) \(joyX) \(joyY)")
//      let string2R = "@:\(joyX):\(joyY)"
////      print("string2R \(string2R)\n")
//      return string2R
//    }
//
//    if xPosition < 0 && yPosition < 0 {
//      let joyX = -round(xPosition / 120 * -10)/10
//      let joyY = -round(yPosition / 120 * -10)/10
////      print("TL \(xPosition) \(yPosition) \(joyX) \(joyY)")
//      let string2R = "@:\(joyX):\(joyY)"
////      print("string2R \(string2R)\n")
//      return string2R
//    }
//
//    if xPosition > 0 && yPosition < 0 {
//      let joyX = round(xPosition / 120 * 10)/10
//      let joyY = -round(yPosition / 120 * -10)/10
////      print("TR \(xPosition) \(yPosition) \(joyX) \(joyY)")
//      let string2R = "@:\(joyX):\(joyY)"
////      print("string2R \(string2R)\n")
//      return string2R
//    }
////    let string2R = "@:\(0):\(0)"
////    print("string2R \(string2R)\n")
////    return string2R
  }
  
  override func viewDidLayoutSubviews() {
    if appStart {
      appStart = false
      detectOrientation()
    }
  }
  
    var topYaxisSV:NSLayoutConstraint!
    var topXaxisSV:NSLayoutConstraint!
    var lowYaxisSV:NSLayoutConstraint!
    var lowXaxisSV:NSLayoutConstraint!
  
  func detectOrientation() {
    topSV.translatesAutoresizingMaskIntoConstraints = false
    lowSV.translatesAutoresizingMaskIntoConstraints = false
    
    let margins = view.layoutMarginsGuide

    if UIDevice.current.orientation.isLandscape {
        // do your stuff here for landscape
        if topYaxisSV != nil {
          topYaxisSV.isActive = false
          topXaxisSV.isActive = false
          lowYaxisSV.isActive = false
          lowXaxisSV.isActive = false
        }
    
        topYaxisSV = topSV.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: 1)
        topYaxisSV.isActive = true
        topXaxisSV = topSV.leftAnchor.constraint(equalToSystemSpacingAfter: margins.leftAnchor, multiplier: 1)
        topXaxisSV.isActive = true
    
        lowYaxisSV = lowSV.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: 1)
        lowYaxisSV.isActive = true
        lowXaxisSV = lowSV.rightAnchor.constraint(equalToSystemSpacingAfter: margins.rightAnchor, multiplier: 1)
        lowXaxisSV.isActive = true
    } else {
      
        if topYaxisSV != nil {
          topYaxisSV.isActive = false
          topXaxisSV.isActive = false
          lowYaxisSV.isActive = false
          lowXaxisSV.isActive = false
        }

//          topYaxisSV = topSV.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8)
          topYaxisSV = topSV.bottomAnchor.constraint(equalTo: touchPad.topAnchor, constant: -8)
          topYaxisSV.isActive = true
          topXaxisSV = topSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
          topXaxisSV.isActive = true
      
//          lowYaxisSV = lowSV.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8)
          lowYaxisSV = lowSV.topAnchor.constraint(equalTo: touchPad.bottomAnchor, constant: 8)
          lowYaxisSV.isActive = true
          lowXaxisSV = lowSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
          lowXaxisSV.isActive = true
    }
}
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    detectOrientation()
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      let alertController = UIAlertController(title: "Disconnect?", message: "Do you want to disconnect", preferredStyle: .alert)
      let ignoreAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      let okAction = UIAlertAction(title: "Disconnect", style: .default) { (action2T) in
        chatRoom.stopChat()
        self.performSegue(withIdentifier: "returnToSegue", sender: self)
      }
      alertController.addAction(ignoreAction)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  


}
