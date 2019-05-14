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
  
  func port(_ value:String) {
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
    if value.contains("portA") {
      portA.text = value
    }
    if value.contains("portB") {
      portB.text = value
    }
    if value.contains("portC") {
      portC.text = value
    }
    if value.contains("portD") {
      portD.text = value
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
  
  
  @IBAction func up(_ sender: UIButton) {
    chatRoom.sendMessage(message: "north\n")
  }
  @IBAction func down(_ sender: UIButton) {
    chatRoom.sendMessage(message: "south\n")
  }
  @IBAction func right(_ sender: UIButton) {
    chatRoom.sendMessage(message: "east\n")
  }
  @IBAction func left(_ sender: UIButton) {
    chatRoom.sendMessage(message: "west\n")
  }

  @IBAction func northEast(_ sender: UIButton) {
    chatRoom.sendMessage(message: "northEast\n")
  }
  
  @IBAction func northWest(_ sender: UIButton) {
    chatRoom.sendMessage(message: "northWest\n")
  }
  
  @IBAction func southEast(_ sender: UIButton) {
    chatRoom.sendMessage(message: "southEast\n")
  }
  
  @IBAction func southWest(_ sender: UIButton) {
    chatRoom.sendMessage(message: "southWest\n")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    chatRoom.delegate = self
  }

}

