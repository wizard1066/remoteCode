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
  
  
  
  @IBOutlet weak var color: UILabel!
  @IBOutlet weak var sensitivitySlider: UISlider!
  
  @IBOutlet weak var theValue: UILabel!
  @IBOutlet weak var thewindow: UIView!
  @IBAction func sensitivitySliderChanged(_ sender: UISlider) {
    sensitivity = sender.value
    theValue.text = String(Int(sender.value))
    print("\(sensitivity)")
  }
  
//  @IBOutlet weak var theButton: UIButton!
//  @IBAction func theAction(_ sender: UIButton) {
//
//    if motionManager.isDeviceMotionAvailable {
//        if !motionManager.isDeviceMotionActive {
//          postAlert(title: "Alert",message: "Make sure your device is flat")
//
//          theButton.backgroundColor = UIColor.orange
//          theButton.setTitle("Wait", for: .normal)
//          DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
//            self.theButton.backgroundColor = UIColor.red
//            self.theButton.setTitle("Stop", for: .normal)
//            self.motionUpdates()
//          })
//        } else {
//          theButton.backgroundColor = UIColor.green
//          theButton.setTitle("Go", for: .normal)
//          motionManager.stopDeviceMotionUpdates()
//          let figure2S = "@:0:0:0"
//          yCord = 0
//          xCord = 0
////          chatRoom?.sendMessage(message: figure2S)
//          sendMessage(message: figure2S)
//        }
//      }
//  }
  
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
  
  var warning: PostAlert?
  
//  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
//                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
//    -> Bool {
//      return true
//  }
  
  @IBAction func unwindMotionVC(segue: UIStoryboardSegue) {
    print("MotionVC")
  }
  
  var previousMessage:String?
  
  func motionUpdates() {
    if motionManager.isDeviceMotionAvailable {
      motionManager.deviceMotionUpdateInterval = refresh
      motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
        
        self.xCord = ((data?.attitude.roll)! * 100).rounded(.toNearestOrEven)
//        self.yCord = ((data?.attitude.pitch)! * -100).rounded(.toNearestOrEven)
        self.yCord = ((data?.attitude.pitch)! * -100).rounded(.toNearestOrEven)
        self.zCord = ((data?.attitude.yaw)! * 100).rounded(.toNearestOrEven)

        let pitchLabel = String(format: "%.2f", ((self.yCord)))
        let rollLabel = String(format: "%.2f", ((self.xCord)))
        let yawLabel = String(format: "%.2f", ((self.zCord)))
        
          self.rollLabel.alpha = 0.5
          self.pitchLabel.alpha = 0.5
          self.yawLabel.alpha = 0.5
        
        
        
        if Float(self.xCord) > (self.sensitivitySlider.value)  {
          self.rollLabel.alpha = 1
//          self.pitchLabel.alpha = 1
          self.yawLabel.alpha = 1
        }
        if Float(self.xCord) < -(self.sensitivitySlider.value) {
          self.rollLabel.alpha = 1
//          self.pitchLabel.alpha = 1
          self.yawLabel.alpha = 1
        }
        
        if Float(self.yCord) > self.sensitivitySlider.value  {
//          self.rollLabel.alpha = 1
          self.pitchLabel.alpha = 1
          self.yawLabel.alpha = 1
          
        }
        if Float(self.yCord) < -self.sensitivitySlider.value {
//          self.rollLabel.alpha = 1
          self.pitchLabel.alpha = 1
          self.yawLabel.alpha = 1
      
        }
        
          self.rollLabel.text = rollLabel
          self.pitchLabel.text = pitchLabel
          self.yawLabel.text = yawLabel
        
        let message2D = "@:" + String(self.xCord) + ":" + String(self.yCord) + ":" + yawLabel
        if message2D != self.previousMessage {
          sendMessage(message: message2D)
          
          self.previousMessage = message2D
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    detectOrientation()
    motionManager = CMMotionManager()
    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
        self.motionUpdates()
    })
    color.text = uniqueID
    
    chatRoom?.delegate = self
    chatRoom?.connection = self
    chatRoom?.rename = self
    chatRoom?.warning = self
    
    configurePorts()
    
 
    colorService?.delegate = self
    colorSearch?.delegate = self
    
    let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
    edgePan.edges = .left
    edgePan.delegate = self
    let otherPan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(otherEdgeSwiped))
    otherPan.edges = .right
    otherPan.delegate = self
    view.addGestureRecognizer(edgePan)
    view.addGestureRecognizer(otherPan)
//    chatRoom?.sendMessage(message: "#:begin")
    sendMessage(message: "#:begin")
  }
  
  @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    if recognizer.state == .recognized {
      motionManager.stopDeviceMotionUpdates()
//      colorSearch?.closeStream()
//      colorSearch?.disconnect()
      self.performSegue(withIdentifier: "returnToSegue", sender: self)
    }
  }
  
  @objc func otherEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    if recognizer.state == .recognized {
      motionManager.stopDeviceMotionUpdates()
//      colorSearch?.closeStream()
//      colorSearch?.disconnect()
      self.performSegue(withIdentifier: "returnToSegue", sender: self)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
//    chatRoom?.sendMessage(message: "#:motion")
    sendMessage(message: "#:motion")
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
    
      topYaxisSV = topSV.bottomAnchor.constraint(equalTo: thewindow.topAnchor, constant: -32)
      topYaxisSV.isActive = true
      topXaxisSV = topSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
      topXaxisSV.isActive = true
      
    
      lowYaxisSV = lowSV.topAnchor.constraint(equalTo: thewindow.bottomAnchor, constant: 32)
      lowYaxisSV.isActive = true
      lowXaxisSV = lowSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
      lowXaxisSV.isActive = true
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
//    chatRoom?.sendMessage(message: "#:end")
    sendMessage(message: "#:end")
}
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    detectOrientation()
  }
  
//  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//    if motion == .motionShake {
//      let alertController = UIAlertController(title: "Disconnect?", message: "Do you want to disconnect", preferredStyle: .alert)
//      let ignoreAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//      let okAction = UIAlertAction(title: "Disconnect", style: .default) { (action2T) in
//
//        sendMessage(message: "#:disconnect")
//        chatRoom?.stopChat()
//        self.performSegue(withIdentifier: "returnToSegue", sender: self)
//      }
//      alertController.addAction(ignoreAction)
//      alertController.addAction(okAction)
//      self.present(alertController, animated: true, completion: nil)
//    }
//  }
  
  class MyPortTapGesture: UITapGestureRecognizer {
    var port:String?
  }
  
  class MyPortLong: UILongPressGestureRecognizer {
    var port:String?
  }
  
  @objc func openPortLong(sender : MyPortLong) {
    let tag = sender.port! + "Q"
    if sender.state == .recognized {
//    chatRoom?.sendMessage(message: tag)
    sendMessage(message: tag)
    }
  }
  
  @objc func openPortTap(sender : MyPortTapGesture) {
    let tag = sender.port! + "P"
//    chatRoom?.sendMessage(message: tag)
    sendMessage(message: tag)
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
  
 
  
  

  func port(_ value: String) {
    let blob = value.components(separatedBy: ":")
    if blob.count < 2 {
      return
    }
    
    

    let portAssign = ["1P":port1,"2P":port2,"3P":port3,"4P":port4,"AP":portA,"BP":portB,"CP":portC,"DP":portD]

    let port2A = blob[0]
    let port2B = portAssign[blob[0]]
//    let port2C = portTrans[blob[0]]!
    if iPort[port2A] != nil {
      let replaced = value.replacingOccurrences(of: port2A, with: iPort[port2A]!)
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
    let port2D = ["1P":port1,"2P":port2,"3P":port3,"4P":port4,"AP":portA,"BP":portB,"CP":portC,"DP":portD]
    if portNames.count != 0 {
      for ports in portAssign {
        if portNames[ports.key] != nil {
          portAssign[ports.key]!?.text = portNames[ports.key]
        }
      }
    }
    
    if hidden.count != 0 {
      
      for ports in port2D {
        if hidden[ports.key] != nil {
          port2D[ports.key]!?.isHidden = hidden[ports.key]!
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
        buttonNames[blob[1]] = blob[2]
      }
    }
    
   let port2D = ["1P":port1,"2P":port2,"3P":port3,"4P":port4,"AP":portA,"BP":portB,"CP":portC,"DP":portD]
   
   if blob[0] == "hide" {

      if port2D[blob[1]] != nil {
        port2D[blob[1]]!?.isHidden = true
        self.view.setNeedsDisplay()
        hidden[blob[1]] = true
      }
    }
    
    if blob[0] == "show" {

      if port2D[blob[1]] != nil {
        port2D[blob[1]]!?.isHidden = false
        self.view.setNeedsDisplay()
        hidden[blob[1]] = false
      }
    }
    
//    let portAssign = ["P1":port1,"P2":port2,"P3":port3,"P4":port4,"PA":portA,"PB":portB,"PC":portC,"PD":portD]
    
    // Change the labels of the ports
    if blob[0] == "title" {
      for ports in iPort {
        if blob[1] == ports.key {
          
          if port2D[ports.key] != nil {
            port2D[ports.key]!?.text = blob[2]
            portNames[blob[1]] = blob[2]
          }
          iPort[ports.key] = blob[2]
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
        chatRoom?.stopChat()
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

extension MotionVC: ColorServiceDelegate {
  func connectedDevicesChanged(manager: ColorService, connectedDevices: [String]) {
    ok("Connection Changed")
  }
  
  func colorChanged(manager: ColorService, colorString: String) {
    print("colorChanged")
  }
  

}

extension MotionVC: ColorSearchDelegate {
  func connectedDevicesChanged(manager: ColorSearch, connectedDevices: [String]) {
    ok("Connection Changed")
  }
  
  func colorChanged(manager: ColorSearch, colorString: String) {
    print("colorChanged")
  }
  

}
