//
//  MotionVC.swift
//  robotRemote
//
//  Created by localadmin on 23.05.19.
//  Copyright © 2019 ch.cqd.remoteCode. All rights reserved.
//

import UIKit
import CoreMotion

class MotionVC: UIViewController, UpdateDisplayDelegate, FeedBackConnection, ChangeTag, PostAlert, UIGestureRecognizerDelegate {
  
  
  
  @IBOutlet weak var theButton: UIButton!
  @IBAction func theAction(_ sender: UIButton) {
    
    if motionManager.isDeviceMotionAvailable {
        if !motionManager.isDeviceMotionActive {
          postAlert(title: "Alert",message: "Make sure your device is flat")
          motionUpdates()
          theButton.backgroundColor = UIColor.orange
          theButton.setTitle("Wait", for: .normal)
          DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.theButton.backgroundColor = UIColor.red
            self.theButton.setTitle("Stop", for: .normal)
          })
        } else {
          theButton.backgroundColor = UIColor.green
          theButton.setTitle("Go", for: .normal)
          motionManager.stopDeviceMotionUpdates()
          let figure2S = "@:0:0:0"
          yCord = 0
          xCord = 0
          chatRoom.sendMessage(message: figure2S)
        }
      }
  }
  
  @IBOutlet weak var port1: UILabel!
  @IBOutlet weak var port2: UILabel!
  @IBOutlet weak var port3: UILabel!
  @IBOutlet weak var port4: UILabel!
  @IBOutlet weak var portD: UILabel!
  @IBOutlet weak var portC: UILabel!
  @IBOutlet weak var portB: UILabel!
  @IBOutlet weak var portA: UILabel!
  
  @IBOutlet weak var labelSV: UIStackView!
  
  @IBOutlet weak var lowSV: UIStackView!
  @IBOutlet weak var topSV: UIStackView!
  
  @IBOutlet weak var pitchLabel: UILabel!
  @IBOutlet weak var rollLabel: UILabel!
  @IBOutlet weak var yawLabel: UILabel!
  
  var motionManager: CMMotionManager!
  var yCord:Double = 0
  var xCord:Double = 0
  var zCord:Double = 0
  
  var xmoving = false
  var ymoving = false
  var refresh = 0.1
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
      return true
  }
  
  @IBAction func unwindMotionVC(segue: UIStoryboardSegue) {
    print("MotionVC")
  }
  
  func motionUpdates() {
//    if motionManager.isDeviceMotionAvailable {
      motionManager.deviceMotionUpdateInterval = refresh
      motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
        
        self.xCord = (data?.attitude.roll)! * 100
        self.yCord = (data?.attitude.pitch)! * -100
        self.zCord = (data?.attitude.yaw)! * 100
        
        let pitchLabel = String(format: "%.2f", ((self.yCord)))
        let rollLabel = String(format: "%.2f", ((self.xCord)))
        let yawLabel = String(format: "%.2f", ((self.zCord)))
        
        self.rollLabel.text = rollLabel
        self.pitchLabel.text = pitchLabel
        self.yawLabel.text = yawLabel
        
//        if self.xCord > 20 && self.yCord < 20 {
//                    self.theButton.image = UIImage(named: "topRight")
//        }
//        if self.xCord < 20 && self.yCord < 20 {
//                    self.theButton.image = UIImage(named: "topLeft")
//        }
//        if self.xCord < 20 && self.yCord > 20 {
//                    self.theButton.image = UIImage(named: "lowLeft")
//        }
//        if self.xCord > 20 && self.yCord > 20 {
//                    self.theButton.image = UIImage(named: "lowRight")
//        }
        
        let message2D = "@:" + rollLabel + ":" + pitchLabel + ":" + yawLabel
        chatRoom.sendMessage(message: message2D)
        
        
      }
//    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    detectOrientation()
    motionManager = CMMotionManager()
//    motionUpdates()
    theButton.layer.cornerRadius = 48
    
    chatRoom.delegate = self
    chatRoom.connection = self
    chatRoom.rename = self
    chatRoom.warning = self
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
      motionManager.stopDeviceMotionUpdates()
      self.performSegue(withIdentifier: "returnToSegue", sender: self)
    }
  }
  
  @objc func otherEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    if recognizer.state == .recognized {
      motionManager.stopDeviceMotionUpdates()
      self.performSegue(withIdentifier: "returnToSegue", sender: self)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    chatRoom.sendMessage(message: "#:motion")
    motionVC = true
   
//    configTheButton()
    confirmPortNames()
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
      topYaxisSV = topSV.bottomAnchor.constraint(equalTo: theButton.topAnchor, constant: -32)
      topYaxisSV.isActive = true
      topXaxisSV = topSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
      topXaxisSV.isActive = true
      
      //          lowYaxisSV = lowSV.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8)
      lowYaxisSV = lowSV.topAnchor.constraint(equalTo: theButton.bottomAnchor, constant: 32)
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
        chatRoom.sendMessage(message: "#:disconnect")
        chatRoom.stopChat()
        self.performSegue(withIdentifier: "returnToSegue", sender: self)
      }
      alertController.addAction(ignoreAction)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  class MyPortTapGesture: UITapGestureRecognizer {
    var port:String?
  }
  
  class MyPortLong: UILongPressGestureRecognizer {
    var port:String?
  }
  
  @objc func openPortLong(sender : MyPortLong) {
    let tag = sender.port! + "Q"
    if sender.state == .recognized {
    chatRoom.sendMessage(message: tag)
    }
  }
  
  @objc func openPortTap(sender : MyPortTapGesture) {
    let tag = sender.port! + "P"
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
      let portLong = MyPortLong(target: self, action: #selector(self.openPortLong(sender:)))
      portLong.port = portVariable.key
      portVariable.value?.addGestureRecognizer(portLong)
    }
  }
  
  func configTheButton() {
    let hitMe = UITapGestureRecognizer(target: self, action: #selector(toggleMotion))
    let hitMeLong = UILongPressGestureRecognizer(target: self, action: #selector(longMotion))
    hitMe.numberOfTapsRequired = 1
//    hitMeLong.minimumPressDuration = 1.0
    theButton.addGestureRecognizer(hitMe)
    theButton.addGestureRecognizer(hitMeLong)
  }
  
  @objc func toggleMotion(sender: UITapGestureRecognizer) {
//    self.theButton.image = UIImage(named: "center")

    if sender.state == .recognized {
      chatRoom.sendMessage(message: "XS")
    }
  }
  
  @objc func longMotion(sender: UITapGestureRecognizer) {
//    self.theButton.image = UIImage(named: "center")
if sender.state == .began {
    chatRoom.sendMessage(message: "XL")
  }
  }
  
  var timer:Timer!
  var loop:Int = 0
  
  @objc func slowDownAndStop() {
    loop -= 1
    
    if xCord > yCord {
      if xCord < 0 {
        xCord = round(xCord * 2)
      } else {
        xCord = round(xCord / 2)
      }
      
      if yCord < 0 {
        yCord = round(yCord * 2)
      } else {
        yCord = round(yCord / 2)
      }
      
      let string2R = "@:\(xCord):\(yCord):0"
      chatRoom.sendMessage(message: string2R)
      
      if loop == 0 {
        let figure2S = "@:0:0:0"
        yCord = 0
        xCord = 0
        chatRoom.sendMessage(message: figure2S)
        if timer != nil {
          timer.invalidate()
        }
      }
    } else {
      if xCord < 0 {
        xCord = round(xCord * -2)
      } else {
        xCord = round(xCord / 2)
      }
      
      if yCord < 0 {
        yCord = round(yCord * -2)
      } else {
        yCord = round(yCord / 2)
      }
      
      let string2R = "@:\(xCord):\(yCord):0"
      chatRoom.sendMessage(message: string2R)
      
      if loop == 0 {
        let figure2S = "@:0:0:0"
        yCord = 0
        xCord = 0
        chatRoom.sendMessage(message: figure2S)
        if timer != nil {
          timer.invalidate()
        }
      }
    }
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
  
  func newName(_ value: String) {
    let blob = value.components(separatedBy: ":")
    
    
    if blob.count < 2 {
      return
    }
    
    let button2D = ["1":1,"2":2,"3":3,"4":4,"5":5,"6":6,"7":7,"8":8,"9":9]
    
    let color2D = ["black":UIColor.black,"blue":UIColor.blue,"brown":UIColor.brown,"cyan":UIColor.cyan,"green":UIColor.green,"magenta":UIColor.magenta,"orange":UIColor.orange,"purple":UIColor.purple,"red":UIColor.red,"yellow":UIColor.yellow,"white":UIColor.white,"clear":UIColor.clear]
    
    // Change the labels on the buttons
    
    
    if blob[0] == "title" {
      if button2D[blob[1]] != nil {
//        button2D[blob[1]]!?.setTitle(blob[2], for: .normal)
        ButtonNames[blob[1]] = blob[2]
      }
    }
    
   
    
    let portAssign = ["P1":port1,"P2":port2,"P3":port3,"P4":port4,"PA":portA,"PB":portB,"PC":portC,"PD":portD]
    
    // Change the labels of the ports
    if blob[0] == "title" {
      for ports in xPort {
        if blob[1] == ports.key {
          
          if portAssign[ports.key] != nil {
            portAssign[ports.key]!?.text = blob[2]
            portNames[blob[1]] = blob[2]
          }
          xPort[ports.key] = blob[2]
          self.view.setNeedsDisplay()
        }
      }
    }
    // Change the text return when you hit keys + key name
    if blob[0] == "tag" {
      for button in xButton {
        if blob[1] == button.key {
          xButton[button.key] = blob[2]
        }
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
  
  func postAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    self.present(alert, animated: true, completion: nil)

    // delays execution of code to dismiss
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
      alert.dismiss(animated: true, completion: nil)
    })
  }
}
