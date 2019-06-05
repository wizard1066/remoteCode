//
//  Shared.swift
//  legoSocket
//
//  Created by localadmin on 14.05.19.
//  Copyright © 2019 ch.cqd.legoblue. All rights reserved.
//

import UIKit

var chatRoom:ChatRoom?
var colorService:ColorService!
var colorSearch:ColorSearch!
var uniqueID: String = "R"
var tag:[String:Int] = [:]

enum team: String {
  case R
  case Y
  case G
  case B
  
  func color() -> String {
    return self.rawValue
  }
}

func sendMessage(message: String) {
    if chatRoom != nil {
      chatRoom?.sendMessage(message: message)
    } else {
      let peas = message.components(separatedBy: ":")
      print("peas \(peas) \(peas.count)")
      var match = 0
      if peas.count == 3 {
        let xCord = peas[1]
        let yCord = peas[2]
        if Float(xCord)! > 0 {
          match = 1
        } else {
          match = 4
        }
        if Float(yCord)! < 0 {
          match = match + 2
        } else {
          match = match + 8
        }
      }
      colorSearch.send(colorName: "*:" + uniqueID + ":" + String(match) + ":" + message)
    }
  }

//  var xPort:Dictionary = ["P1":"P1","P2":"P2","P3":"P3","P4":"P4","PA":"PA","PB":"PB","PC":"PC","PD":"PD"]
  var iPort:Dictionary = ["1P":"1P","2P":"2P","3P":"3P","4P":"4P","AP":"AP","BP":"BP","CP":"CP","DP":"DP"]
  var oPort:Dictionary = ["P1":"P1","P2":"P2","P3":"P4","P4":"P4","PA":"PA","PB":"PB","PC":"PC","PD":"PD"]

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

  var peerConnection = false

func listViewControllers() {
  print("other")
}


