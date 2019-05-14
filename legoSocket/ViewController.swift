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

class ViewController: UIViewController, UpdateDisplayDelegate {
  
  func sensor(_ value:String) {
    if value.contains("port1") {
      port1.text = value
    }
    if value.contains("port2") {
      port2.text = value
    }
    if value.contains("port3") {
      port3.text = value
    }
    if value.contains("port4") {
      port4.text = value
    }
  }
  
  func motor(_ value:String) {
    if value.contains("portA") {
        port1.text = value
      }
      if value.contains("portB") {
        port2.text = value
      }
      if value.contains("portC") {
        port3.text = value
      }
      if value.contains("portD") {
        port4.text = value
      }
  }

  @IBOutlet weak var port1: UILabel!
  @IBOutlet weak var port2: UILabel!
  @IBOutlet weak var port3: UILabel!
  @IBOutlet weak var port4: UILabel!
  
  @IBAction func up(_ sender: UIButton) {
    chatRoom.sendMessage(message: "up\n")
  }
  @IBAction func down(_ sender: UIButton) {
    chatRoom.sendMessage(message: "down\n")
  }
  @IBAction func right(_ sender: UIButton) {
    chatRoom.sendMessage(message: "right\n")
  }
  @IBAction func left(_ sender: UIButton) {
    chatRoom.sendMessage(message: "left\n")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    chatRoom.delegate = self
  }

}

