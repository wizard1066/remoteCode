//
//  ViewController.swift
//  legoSocket
//
//  Created by localadmin on 07.05.19.
//  Copyright © 2019 ch.cqd.legoblue. All rights reserved.
//


//#!/usr/bin/env python3
//"""
//A simple Python script to receive messages from a client over
//Bluetooth using Python sockets (with Python 3.3 or above).
//"""
//
//import socket
//
//hostMACAddress = '40:BD:32:3E:56:97' # The MAC address of a Bluetooth adapter on the server. The server might have multiple Bluetooth adapters.
//hostAddress = '10.182.81.102'
//port = 50003 # 3 is an arbitrary choice. However, it must match the port used by the client.
//backlog = 1
//size = 1024
//s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
//s.bind((hostAddress,port))
//s.listen(backlog)
//try:
//    client, address = s.accept()
//    while 1:
//        data = client.recv(size)
//        if data:
//            debug = data.decode('utf-8')
//            print(debug)
//            client.send(data)
//except:
//    print("Closing socket")
//    client.close()
//    s.close()

import UIKit

class MyTapGesture: UITapGestureRecognizer {
  var tag:String?
}

class MyLongGesture: UILongPressGestureRecognizer {
  var tag:String?
}

class DigitalVC: UIViewController, UpdateDisplayDelegate, FeedBackConnection, ChangeTag, PostAlert, UIGestureRecognizerDelegate {
  
  // format label:oldLabel:newLabel
  @IBOutlet weak var vctype: UILabel!
  
  @IBOutlet weak var topSV: UIStackView!
  @IBOutlet weak var lowSV: UIStackView!
  @IBOutlet weak var nineButtonGroupSV: UIStackView!
  
  func newName(_ value: String) {
    let blob = value.components(separatedBy: ":")
    
    
    if blob.count < 2 {
      return
    }
    
    let button2D = ["1S":northWestButton,"2S":northButton,"3S":northEastButton,"4S":westButton,"5S":centralButton,"6S":eastButton,"7S":southWestButton,"8S":southButton,"9S":southEastButton]
    
    let button3D = ["1L":northWestButton,"2L":northButton,"3L":northEastButton,"4L":westButton,"5L":centralButton,"6L":eastButton,"7L":southWestButton,"8L":southButton,"9L":southEastButton]
    
    let color2D = ["black":UIColor.black,"blue":UIColor.blue,"brown":UIColor.brown,"cyan":UIColor.cyan,"green":UIColor.green,"magenta":UIColor.magenta,"orange":UIColor.orange,"purple":UIColor.purple,"red":UIColor.red,"yellow":UIColor.yellow,"white":UIColor.white,"clear":UIColor.clear]
    
    let port2D = ["1P":port1,"2P":port2,"3P":port3,"4P":port4,"AP":portA,"BP":portB,"CP":portC,"DP":portD]
    let port3D = ["1Q":port1,"2Q":port2,"3Q":port3,"4Q":port4,"AQ":portA,"BQ":portB,"CQ":portC,"DQ":portD]
    
    // Change the labels on the buttons
    
    
    if blob[0] == "hide" {
      if button2D[blob[1]] != nil {
        button2D[blob[1]]!?.isHidden = true
        self.view.setNeedsDisplay()
        hidden[blob[1]] = true
      }
      if port2D[blob[1]] != nil {
        port2D[blob[1]]!?.isHidden = true
        self.view.setNeedsDisplay()
        hidden[blob[1]] = true
      }
    }
    
    if blob[0] == "show" {
      if button2D[blob[1]] != nil {
        button2D[blob[1]]!?.isHidden = false
        self.view.setNeedsDisplay()
        hidden[blob[1]] = false
      }
      if port2D[blob[1]] != nil {
        port2D[blob[1]]!?.isHidden = false
        self.view.setNeedsDisplay()
        hidden[blob[1]] = false
      }
    }
    
    
    if blob[0] == "title" {
      if button2D[blob[1]] != nil {
        button2D[blob[1]]!?.setTitle(blob[2], for: .normal)
        buttonNames[blob[1]] = blob[2]
        self.view.setNeedsDisplay()
      }
    }
    
    if blob[0] == "bcolor" || blob[0] == "bcolour" {
      if button2D[blob[1]] != nil {
        button2D[blob[1]]!?.backgroundColor = color2D[blob[2]]
        buttonColors[blob[1]] = color2D[blob[2]]
        self.view.setNeedsDisplay()
      }
    }
    
    if blob[0] == "fcolor" || blob[0] == "fcolour" {
      if button2D[blob[1]] != nil {
        button2D[blob[1]]!?.setTitleColor(color2D[blob[2]], for: .normal)
        fontColors[blob[1]] = color2D[blob[2]]
        self.view.setNeedsDisplay()
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
  
  func ok(_ value: String) {
    let alertController = UIAlertController(title: value, message: value, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(defaultAction)
    self.present(alertController, animated: true, completion: nil)
  }
  

  
  func port(_ value: String) {
    let blob = value.components(separatedBy: ":")
    if blob.count < 2 {
      return
    }
    
    
//    let portAssign = ["P1":port1,"P2":port2,"P3":port3,"P4":port4,"PA":portA,"PB":portB,"PC":portC,"PD":portD]
    let portAssign = ["1P":port1,"2P":port2,"3P":port3,"4P":port4,"AP":portA,"BP":portB,"CP":portC,"DP":portD]
//    let portTrans = ["P1":"1P","P2":"2P","P3":"3P","P4":"4P","PA":"AP","PB":"BP","PC":"CP","PD":"DP"]
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
  
  func confirmCustomization() {
  
  let button2D = ["1S":northWestButton,"2S":northButton,"3S":northEastButton,"4S":westButton,"5S":centralButton,"6S":eastButton,"7S":southWestButton,"8S":southButton,"9S":southEastButton]
  
    let port2D = ["1P":port1,"2P":port2,"3P":port3,"4P":port4,"AP":portA,"BP":portB,"CP":portC,"DP":portD]
//    let portAssign = ["1":port1,"2":port2,"3":port3,"4":port4,"A":portA,"B":portB,"C":portC,"D":portD]
//    let buttonAssign = ["1":northWestButton,"2":northButton,"3":northEastButton,"4":westButton,"5":centralButton,"6":eastButton,"7":southWestButton,"8":southButton,"9":southEastButton]


    if portNames.count != 0 {
      for ports in port2D {
        if portNames[ports.key] != nil {
          port2D[ports.key]!?.text = portNames[ports.key]
        }
      }
    }
    if buttonNames.count != 0 {
      for buttons in button2D {
        if buttonNames[buttons.key] != nil {
          button2D[buttons.key]!?.setTitle(buttonNames[buttons.key], for: .normal)
        }
      }
    }
    
    if fontColors.count != 0 {
      for buttons in button2D {
        if fontColors[buttons.key] != nil {
          button2D[buttons.key]!?.setTitleColor(fontColors[buttons.key], for: .normal)
        }
      }
    }
    
    if buttonColors.count != 0 {
      for buttons in button2D {
        if buttonColors[buttons.key] != nil {
          button2D[buttons.key]!?.backgroundColor = buttonColors[buttons.key]
        }
      }
    }
    
    if hidden.count != 0 {
      for buttons in button2D {
        if hidden[buttons.key] != nil {
          button2D[buttons.key]!?.isHidden = hidden[buttons.key]!
        }
      }
      for ports in port2D {
        if hidden[ports.key] != nil {
          port2D[ports.key]!?.isHidden = hidden[ports.key]!
        }
      }
    }
    
    
    self.view.setNeedsDisplay()
  }
  
  @IBOutlet weak var port1: UILabel!
  @IBOutlet weak var port2: UILabel!
  @IBOutlet weak var port3: UILabel!
  @IBOutlet weak var port4: UILabel!
  
  @IBOutlet weak var portD: UILabel!
  @IBOutlet weak var portC: UILabel!
  @IBOutlet weak var portB: UILabel!
  @IBOutlet weak var portA: UILabel!
  
  @IBOutlet weak var northButton: UIButton!
  @IBOutlet weak var northEastButton: UIButton!
  @IBOutlet weak var eastButton: UIButton!
  @IBOutlet weak var southEastButton: UIButton!
  @IBOutlet weak var southButton: UIButton!
  @IBOutlet weak var southWestButton: UIButton!
  @IBOutlet weak var westButton: UIButton!
  @IBOutlet weak var northWestButton: UIButton!
  @IBOutlet weak var centralButton: UIButton!
  
  
  
  @objc func openShortCall(sender : MyTapGesture) {
    let tag = String(sender.tag!)
    if sender.state == .recognized {
      chatRoom.sendMessage(message: xButton[tag]!)
    }
  }
  
  @objc func openLongCall(sender : MyLongGesture) {
    if(sender.state == UIGestureRecognizer.State.began) {
      let tag = String(sender.tag!)
      if (xButton[tag] != nil) {
      if sender.state == .began {
        chatRoom.sendMessage(message: xButton[tag]!)
      }
      }
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
    if sender.state == .recognized {
    chatRoom.sendMessage(message: tag)
    }
  }
  
  func configButtons() {
    let buttonCorner:CGFloat = 32
    
    let button2D = ["1":northWestButton,"2":northButton,"3":northEastButton,"4":westButton,"5":centralButton,"6":eastButton,"7":southWestButton,"8":southButton,"9":southEastButton]
    
    for buttonVariables in button2D {
      let digitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
      let digitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
      digitShort.tag = buttonVariables.key + "S"
      digitLong.tag = buttonVariables.key + "L"
      digitShort.numberOfTapsRequired = 1
      buttonVariables.value?.layer.cornerRadius = buttonCorner
      buttonVariables.value?.addGestureRecognizer(digitShort)
      buttonVariables.value?.addGestureRecognizer(digitLong)
    }
    
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
  
  
  
  
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
      return true
  }
  
  @IBAction func unwindDigitalVC(segue: UIStoryboardSegue) {
    print("Digital")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    detectOrientation()
    chatRoom.delegate = self
    chatRoom.connection = self
    chatRoom.rename = self
    chatRoom.warning = self
    configButtons()
    
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
  
  override func viewWillDisappear(_ animated: Bool) {
    chatRoom.sendMessage(message: "#:end")
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
  }
  
  @IBAction func debug(_ sender: Any) {
    chatRoom.stopChat()
    self.performSegue(withIdentifier: "go2motion", sender: self)
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
      
      
      topYaxisSV = topSV.bottomAnchor.constraint(equalTo: nineButtonGroupSV.topAnchor, constant: -32)
      topYaxisSV.isActive = true
      topXaxisSV = topSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
      topXaxisSV.isActive = true
      
      
      lowYaxisSV = lowSV.topAnchor.constraint(equalTo: nineButtonGroupSV.bottomAnchor, constant: 32)
      lowYaxisSV.isActive = true
      lowXaxisSV = lowSV.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 1)
      lowXaxisSV.isActive = true
    }
  }
  
  
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    detectOrientation()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    chatRoom.sendMessage(message: "#:digital")
    digitalVC = true
    
    confirmCustomization()
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
  
  func postAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    self.present(alert, animated: true, completion: nil)

    // delays execution of code to dismiss
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
      alert.dismiss(animated: true, completion: nil)
    })
  }
}

