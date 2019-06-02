//
//  Shared.swift
//  legoSocket
//
//  Created by localadmin on 14.05.19.
//  Copyright © 2019 ch.cqd.legoblue. All rights reserved.
//

import UIKit

var chatRoom:ChatRoom!

//  var xPort:Dictionary = ["P1":"P1","P2":"P2","P3":"P3","P4":"P4","PA":"PA","PB":"PB","PC":"PC","PD":"PD"]
  var xPort:Dictionary = ["1P":"1P","2P":"2P","3P":"3P","4P":"4P","AP":"AP","BP":"BP","CP":"CP","DP":"DP"]

  var xButton:Dictionary = ["1S":"1S","1L":"1L","2S":"2S","2L":"2L","3S":"3S","3L":"3L","4S":"4S","4L":"4L","5S":"5S","5L":"5L","6S":"6S","6L":"6L","7S":"7S","7L":"7L","8S":"8S","8L":"8L","9S":"9S","9L":"9L"]
  var appStart = true
  var digitalVC = false
  var analogVC = false
  var motionVC = false

  var portNames:[String:String] = [:]
  var buttonNames:[String:String] = [:]
  var buttonColors:[String:UIColor] = [:]
  var fontColors:[String:UIColor] = [:]
  var hidden:[String:Bool] = [:]

func listViewControllers() {
  print("other")
}


