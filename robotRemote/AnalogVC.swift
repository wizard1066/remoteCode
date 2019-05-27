//
//  AnalogVC.swift
//  robotRemote
//
//  Created by localadmin on 22.05.19.
//  Copyright © 2019 ch.cqd.remoteCode. All rights reserved.
//

import UIKit

class AnalogVC: UIViewController, UpdateDisplayDelegate, FeedBackConnection, ChangeTag, UIGestureRecognizerDelegate {
  
  func newName(_ value: String) {
    let blob = value.components(separatedBy: ":")
    // Change the labels on the buttons
    
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
        self.performSegue(withIdentifier: "returnToSegue", sender: self)
      })
    })
  }
  
  func port(_ value: String) {
    let blob = value.components(separatedBy: ":")
    if blob.count < 2 {
      return
    }
    
    let portAssign = ["P1":port1,"P2":port2,"P3":port3,"P4":port4,"PA":portA,"PB":portB,"PC":portC,"PD":portD]
    let port2A = blob[0]
    let port2B = portAssign[blob[0]]
    if xPort[port2A] != nil {
      let replaced = value.replacingOccurrences(of: port2A, with: xPort[port2A]!)
      if port2B!?.text != nil {
        DispatchQueue.main.async {
          port2B!?.text = replaced
          self.view.setNeedsDisplay()
        }
        
      }
    }
  }
  
  class MyPortTapGesture: UITapGestureRecognizer {
    var port:String?
  }
  
  @objc func openPortTap(sender : MyPortTapGesture) {
    let tag = "+:port" + sender.port! + "\n"
    
    chatRoom.sendMessage(message: tag)
  }
  
  func configurePorts() {
    let ports2D = ["1":port1,"2":port2,"3":port3,"4":port4,"A":portA,"B":portB,"C":portC,"D":portD]
    for portVariable in ports2D {
      let portTapGesture = MyPortTapGesture(target: self, action: #selector(self.openPortTap))
      portTapGesture.port = portVariable.key
      portTapGesture.numberOfTapsRequired = 1
      portVariable.value?.addGestureRecognizer(portTapGesture)
      portVariable.value?.isUserInteractionEnabled = true
    }
  }
  
  func confirmPortNames() {
    let portAssign = ["P1":port1,"P2":port2,"P3":port3,"P4":port4,"PA":portA,"PB":portB,"PC":portC,"PD":portD]
    if portNames.count != 0 {
      for ports in portAssign {
        if portNames[ports.key] != nil {
          portAssign[ports.key]!?.text = portNames[ports.key]
        }
      }
    }
  }
  
  @IBOutlet weak var topSV: UIStackView!
  @IBOutlet weak var lowSV: UIStackView!
  
  @IBOutlet weak var xFactor: UILabel!
  @IBOutlet weak var yFactor: UILabel!
  
  @IBOutlet weak var port1: UILabel!
  @IBOutlet weak var port2: UILabel!
  @IBOutlet weak var port3: UILabel!
  @IBOutlet weak var port4: UILabel!
  
  @IBOutlet weak var portA: UILabel!
  @IBOutlet weak var portB: UILabel!
  @IBOutlet weak var portC: UILabel!
  @IBOutlet weak var portD: UILabel!
  
  @IBOutlet weak var legoImage: UIImageView!
  @IBOutlet weak var touchPad: UIView!
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
      return true
  }
  
  @IBAction func unwindAnalogVC(segue: UIStoryboardSegue) {
    print("AnalogVC")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    detectOrientation()
    chatRoom.delegate = self
    chatRoom.connection = self
    chatRoom.rename = self
    configurePorts()
    
    let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
    edgePan.edges = .left
    edgePan.delegate = self
    let otherPan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(otherEdgeSwiped))
    otherPan.edges = .right
    otherPan.delegate = self
    view.addGestureRecognizer(edgePan)
    view.addGestureRecognizer(otherPan)
    chatRoom.sendMessage(message: "#:begin")
  }
  
  @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    if recognizer.state == .recognized {
      
      self.performSegue(withIdentifier: "returnToSegue", sender: self)
    }
  }
  
  @objc func otherEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    if recognizer.state == .recognized {
      self.performSegue(withIdentifier: "returnToSegue", sender: self)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    chatRoom.sendMessage(message: "#:analog")
    analogVC = true
 
    confirmPortNames()
  }
  
  var position: CGPoint!
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if timer != nil {
      timer.invalidate()
    }
    if let touch = event?.allTouches?.first {
      position = touch.location(in: touchPad)
      if position.x < 0 || position.y < 0 || position.x > 240 || position.y > 240 {
        // ignore it
      } else {
        let (joyX,joyY,figure2S) = calcPoint(cord2D: position)
//        if position.x > 128 && position.y < 128 {
//          //          legoImage.image = UIImage(named: "topRight")
//        }
//        if position.x < 128 && position.y < 128 {
//          //          legoImage.image = UIImage(named: "topLeft")
//        }
//        if position.x < 128 && position.y > 128 {
//          //          legoImage.image = UIImage(named: "lowLeft")
//        }
//        if position.x > 128 && position.y > 128 {
//          //          legoImage.image = UIImage(named: "lowRight")
//        }
        xFactor.text = String(Int(joyX))
        yFactor.text = String(Int(joyY))
        //         launch this on a timer
        //        self.legoImage.image = UIImage(named: "center")
        
        chatRoom.sendMessage(message: figure2S)
      }
    }
  }
  
  var timer:Timer!
  var loop:Int = 0
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    loop = 4
    //    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(slowDownAndStop), userInfo: nil, repeats: true)
    let figure2S = "@:0:0"
    chatRoom.sendMessage(message: figure2S)
  }
  
  @objc func slowDownAndStop() {
    loop -= 1
    
    position.x = position.x + 120
    position.y = position.y + 120
    if position.x > position.y {
      //      let loop = Int(Float(position.x).squareRoot())
      //      for _ in 0 ... loop {
      if position.x < 120 {
        position.x = round(position.x * 2)
      } else {
        position.x = round(position.x / 2)
      }
      
      if position.y < 120 {
        position.y = round(position.y * 2)
      } else {
        position.y = round(position.y / 2)
      }
      
      
      
      //        let string2R = "@:\(position.x):\(position.y)"
      let (_,_,figure2S) = calcPoint(cord2D: position)
      chatRoom.sendMessage(message: figure2S)
      
      if loop == 0 {
        let figure2S = "@:0:0"
        position.y = 0
        position.x = 0
        chatRoom.sendMessage(message: figure2S)
        if timer != nil {
          timer.invalidate()
        }

      }

    } else {

      
      if position.x < 120 {
        position.x = round(position.x * -2)
      } else {
        position.x = round(position.x / 2)
      }
      
      if position.y < 120 {
        position.y = round(position.y * -2)
      } else {
        position.y = round(position.y / 2)
      }


      let (_,_,figure2S) = calcPoint(cord2D: position)
      chatRoom.sendMessage(message: figure2S)
      
      if loop == 0 {
        let figure2S = "@:0:0"
        position.y = 0
        position.x = 0
        chatRoom.sendMessage(message: figure2S)
        if timer != nil {
          timer.invalidate()
        }
        //          break
      }
      //      }
    }
  }
  
  func calcPoint(cord2D: CGPoint) -> (CGFloat, CGFloat, String) {
    // Need to subtract 120 cause the pad is 240 pixels wide
    
    let xPosition = cord2D.x - 120
    let yPosition = cord2D.y - 120
    
    // Need to multiply by a negative number cause the model needs to work that way
    // Need to multiply by 100 cause I need a number between 1-100
    
    let joyX = round(xPosition / 120 * 100)
    let joyY = round(yPosition / 120 * -100)
    
    
    let string2R = "@:\(joyX):\(joyY)"
    return (joyX,joyY,string2R)
    
    
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
      topYaxisSV = topSV.bottomAnchor.constraint(equalTo: touchPad.topAnchor, constant: -32)
      topYaxisSV.isActive = true
      topXaxisSV = topSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
      topXaxisSV.isActive = true
      
      //          lowYaxisSV = lowSV.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8)
      lowYaxisSV = lowSV.topAnchor.constraint(equalTo: touchPad.bottomAnchor, constant: 32)
      lowYaxisSV.isActive = true
      lowXaxisSV = lowSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
      lowXaxisSV.isActive = true
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    chatRoom.sendMessage(message: "#:end")
}
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    detectOrientation()
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      let alertController = UIAlertController(title: "Disconnect?", message: "Do you want to disconnect", preferredStyle: .alert)
      let ignoreAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      let okAction = UIAlertAction(title: "Disconnect", style: .default) { (action2T) in
        chatRoom.sendMessage(message: "#:exit")
        chatRoom.stopChat()
        self.performSegue(withIdentifier: "returnToSegue", sender: self)
      }
      alertController.addAction(ignoreAction)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
}

