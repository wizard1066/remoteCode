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

class ViewController: UIViewController, UpdateDisplayDelegate, FeedBackConnection, ChangeTag {

  // format label:oldLabel:newLabel

  func newName(_ value: String) {
    let blob = value.components(separatedBy: ":")
    // Change the labels on the buttons
    print("blob.count",blob.count)
    if blob.count < 2 {
      return // corrupted data
    }
    switch blob[1] {
      case "2":
        northButton.setTitle(blob[2], for: .normal)
        break
      case "8":
        southButton.setTitle(blob[2], for: .normal)
        break
      case "4":
        eastButton.setTitle(blob[2], for: .normal)
        break
      case "6":
        westButton.setTitle(blob[2], for: .normal)
        break
      case "5":
        centralButton.setTitle(blob[2], for: .normal)
        break
      case "3":
        northEastButton.setTitle(blob[2], for: .normal)
        break
      case "1":
        northWestButton.setTitle(blob[2], for: .normal)
        break
      case "7":
        southEastButton.setTitle(blob[2], for: .normal)
        break
      case "9":
        southWestButton.setTitle(blob[2], for: .normal)
        break
      default:
//        ok("label syntax label:oldName:newName")
        print("no")
    }
    // Change the labels of the ports
    for ports in xPort {
      if blob[1] == ports.key {
        xPort[ports.key] = blob[2]
      }
    }
    print("xPort \(xPort)")
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

  func ok(_ value: String) {
    let alertController = UIAlertController(title: value, message: value, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  var xPort:Dictionary = ["port1":"port1","port2":"port2","port3":"port3","port4":"port4","portA":"portA","portB":"portB","portC":"portC","portD":"portD"]
  
  func port(_ value:String) {
    let blob = value.components(separatedBy: ":")
//    print("value",value,"blob",blob)
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
  
  class MyTapGesture: UITapGestureRecognizer {
    var tag:String?
  }
  
  class MyLongGesture: UILongPressGestureRecognizer {
    var tag:String?
  }
  
  @objc func openShortCall(sender : MyTapGesture) {
    let tag = sender.tag
    print("short:",tag!)
    chatRoom.sendMessage(message: tag!)
  }
  
  @objc func openLongCall(sender : MyLongGesture) {
    let tag = sender.tag
    if(sender.state == UIGestureRecognizer.State.began) {
      print("long:",tag!)
      chatRoom.sendMessage(message: tag!)
    }
  }
  
  func configButtons() {
    let buttonCorner:CGFloat = 32
    
    let oneDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let oneDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    oneDigitShort.tag = "1S"
    oneDigitLong.tag = "1L"
    oneDigitShort.numberOfTapsRequired = 1
    northWestButton.layer.cornerRadius = buttonCorner
    northWestButton.addGestureRecognizer(oneDigitShort)
    northWestButton.addGestureRecognizer(oneDigitLong)
    
    let twoDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let twoDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    twoDigitShort.tag = "2S"
    twoDigitLong.tag = "2L"
    twoDigitShort.numberOfTapsRequired = 1
    northButton.layer.cornerRadius = buttonCorner
    northButton.addGestureRecognizer(twoDigitShort)
    northButton.addGestureRecognizer(twoDigitLong)
    
    let threeDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let threeDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    threeDigitShort.tag = "3S"
    threeDigitLong.tag = "3L"
    threeDigitShort.numberOfTapsRequired = 1
    northEastButton.layer.cornerRadius = buttonCorner
    northEastButton.addGestureRecognizer(threeDigitShort)
    northEastButton.addGestureRecognizer(threeDigitLong)
    
    
    let fourDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let fourDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    fourDigitShort.tag = "4S"
    fourDigitLong.tag = "4L"
    fourDigitShort.numberOfTapsRequired = 1
    westButton.layer.cornerRadius = buttonCorner
    westButton.addGestureRecognizer(fourDigitShort)
    westButton.addGestureRecognizer(fourDigitLong)
    
    let fiveDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let fiveDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    fiveDigitShort.tag = "5S"
    fiveDigitLong.tag = "5L"
    fiveDigitShort.numberOfTapsRequired = 1
    centralButton.layer.cornerRadius = buttonCorner
    centralButton.addGestureRecognizer(fiveDigitShort)
    centralButton.addGestureRecognizer(fiveDigitLong)

    let sixDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let sixDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    sixDigitShort.tag = "6S"
    sixDigitLong.tag = "6L"
    sixDigitShort.numberOfTapsRequired = 1
    eastButton.layer.cornerRadius = buttonCorner
    eastButton.addGestureRecognizer(sixDigitShort)
    eastButton.addGestureRecognizer(sixDigitLong)
    
    
    let sevenDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let sevenDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    sevenDigitShort.tag = "7S"
    sevenDigitLong.tag = "7L"
    sevenDigitShort.numberOfTapsRequired = 1
    southWestButton.layer.cornerRadius = buttonCorner
    southWestButton.addGestureRecognizer(sevenDigitShort)
    southWestButton.addGestureRecognizer(sevenDigitLong)
    
    
    let eightDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let eightDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    eightDigitShort.tag = "8S"
    eightDigitLong.tag = "8L"
    eightDigitShort.numberOfTapsRequired = 1
    southButton.layer.cornerRadius = buttonCorner
    southButton.addGestureRecognizer(eightDigitShort)
    southButton.addGestureRecognizer(eightDigitLong)
    
    
    let nineDigitShort = MyTapGesture(target: self, action: #selector(self.openShortCall))
    let nineDigitLong = MyLongGesture(target: self, action: #selector(self.openLongCall))
    nineDigitShort.tag = "9S"
    nineDigitLong.tag = "9L"
    nineDigitShort.numberOfTapsRequired = 1
    southEastButton.layer.cornerRadius = buttonCorner
    southEastButton.addGestureRecognizer(nineDigitShort)
    southEastButton.addGestureRecognizer(nineDigitLong)
  }
  
  override func viewDidLoad() {

    super.viewDidLoad()
    chatRoom.delegate = self
    chatRoom.connection = self
    chatRoom.rename = self
    configButtons()
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      print("shake")
      let alertController = UIAlertController(title: "Disconnect?", message: "Do you want to disconnect", preferredStyle: .alert)
      let ignoreAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      let okAction = UIAlertAction(title: "Disconnect", style: .default) { (action2T) in
        chatRoom.stopChat()
        self.performSegue(withIdentifier: "returnToConnect", sender: self)
      }
      alertController.addAction(ignoreAction)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
}

