//
//  Shared.swift
//  legoSocket
//
//  Created by localadmin on 14.05.19.
//  Copyright © 2019 ch.cqd.legoblue. All rights reserved.
//

import UIKit

var chatRoom:ChatRoom?
var colorService:ColorService?
var colorSearch:ColorSearch?
var primePeer:String?

var uniqueID: String = "R"
var tag:[String:Int] = [:]
var sensitivity: Float = 20

enum team: String {
  case R
  case Y
  case G
  case B
  
  func color() -> String {
    return self.rawValue
  }
}

var lastMessage: String?
struct pod {
  var roll: Float?
  var pitch: Float?
  var yaw: Float?
  var match: Int?
}
var pods:[pod] = []

func sendMessage(message: String) {
    if chatRoom != nil {
      chatRoom?.sendMessage(message: message)
    } else {
      let peas = message.components(separatedBy: ":")
//      print("peas \(peas) \(peas.count)")
      var roll:Float!
      var pitch:Float!
      var yaw:Float!

      var match = 0
      if peas.count == 3 || peas.count == 4 {
        roll = Float(peas[1])
        pitch = Float(peas[2])
        
        
        if Float(pitch!) > 0 {
          match = 1 // forward
        } else {
          match = 4 // back
        }
        if Float(roll!) > 0 {
          match = match + 2 // right
        } else {
          match = match + 8 // left
        }
//        let newP = pod(roll: roll, pitch: pitch, yaw: yaw, match: match)
//        pods.append(newP)
      }
      if roll != nil && pitch != nil {
        let message2D = "*:" + uniqueID + ":" + String(match) + ":" + message + "\n"
        colorSearch!.sendStream(colorName: message2D)
//        colorSearch.send(colorName: "*:" + uniqueID + ":" + String(match) + ":" + message + "\n")
      } else {
        colorSearch!.send(colorName: "*:" + uniqueID + ":" + String(match) + ":" + message)
      }
    }
  }

  var previousMessage:String?

  func returnPod() -> String? {
    defer {
      pods.removeAll()
    }
 
    var aPitch: Float? = 0
    var aRoll: Float? = 0
    var aYaw: Float? = 0
    for peas in pods {
//      print("peas \(peas)")
      if (peas.pitch! < Float(-10) || peas.pitch! > Float(10)) || (peas.roll! < Float(-10) || peas.roll! > Float(10)) {
      // capture an average everything below 10, above 10
      aPitch = aPitch! + peas.pitch!
      aRoll = aRoll! + peas.roll!
      aYaw = aYaw! + peas.yaw!
  } else {
      // drop everything return zero this should happen if pitch is between -10 and 10.
      if previousMessage != "@:0:0:0:255" {
        previousMessage = "@:0:0:0:255"
        return(previousMessage!)
      } else {
        return nil
        }
    
  }
    }
    var rPitch = aPitch! / Float(pods.count)
    var rRoll = aRoll! / Float(pods.count)
    let rYaw = aYaw! / Float(pods.count)
    if rPitch > 20 {
      rPitch = rPitch - sensitivity
    }
    if rPitch < -20 {
      rPitch = rPitch + sensitivity
    }
    if rRoll > 20 {
      rRoll = rRoll - sensitivity
    }
    if rRoll < -20 {
      rRoll = rRoll + sensitivity
    }
    
    let newMessage = "@:\(String(describing: rRoll)):\(String(describing: rPitch)):\(String(describing: rYaw))"
    return(newMessage)
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


