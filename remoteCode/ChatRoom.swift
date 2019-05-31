//
//  ChatRoom.swift
//  legoSocket
//
//  Created by localadmin on 07.05.19.
//  Copyright © 2019 ch.cqd.legoblue. All rights reserved.
//

import UIKit
import Foundation

protocol UpdateDisplayDelegate {
  func port(_ value:String)
}

protocol FeedBackConnection {
  func ok(_ value:String)
  func bad(_ value: String)
}

protocol ChangeTag {
  func newName(_ value: String)
}

protocol PostAlert {
  func postAlert(title: String, message: String)
}

class ChatRoom: NSObject, StreamDelegate {
  
  var delegate: UpdateDisplayDelegate?
  var connection: FeedBackConnection?
  var rename: ChangeTag?
  var warning: PostAlert?
  
  var inputStream: InputStream!
  var outputStream: OutputStream!
  
  var host:CFString?
  var port:UInt32?
  var status = false;
  var output = "message"
  var bufferSize = 1024;
  init(host: String, port:UInt32){
    self.host = host as CFString
    self.port = port
    self.status = false
    output = ""
    super.init()
  }
  
  var username = ""
  
  let maxReadLength = 1024
  
  func returnInStatus() -> InputStream.Status {
    return inputStream!.streamStatus
  }
  
  func returnOutStatus() -> OutputStream.Status {
    return outputStream!.streamStatus
  }
  
  func setupNetworkCommunication() {
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host!, port!, &readStream, &writeStream)
    
    inputStream = readStream!.takeRetainedValue()
    outputStream = writeStream!.takeRetainedValue()
    
    inputStream!.delegate = self
    outputStream!.delegate = self
    
    inputStream.schedule(in: .current, forMode: .common)
    outputStream.schedule(in: .current, forMode: .common)
    
    inputStream.open()
    outputStream.open()
    
  }
  
  func stopChat() {
    inputStream.close()
    outputStream.close()
  }
  
  func sendMessage(message: String) {
    //Your stream
    outputStream.write(message, maxLength: message.utf8.count)
  }
  
  func sendMessageV1(message: String) {
    
    let data = message.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    let dataMutablePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
    //Copies the bytes to the Mutable Pointer
    dataMutablePointer.initialize(to: 0)
    data.copyBytes(to: dataMutablePointer, count: data.count)
    
    //Cast to regular UnsafePointer
    let dataPointer = UnsafePointer<UInt8>(dataMutablePointer)
    
    //Your stream
    outputStream.write(dataPointer, maxLength: data.count)
    defer {
      dataMutablePointer.deinitialize(count: data.count)
      dataMutablePointer.deallocate()
    }
  }
  
  let alignment = MemoryLayout<Int>.alignment
  
  func readMessage() {
    let info = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
    inputStream.read(info, maxLength: maxReadLength)
    
    var str = String(cString: info)
    
    let values = str.components(separatedBy: "\n")
    for v2 in values {
      if v2.first == "P" { // port
        delegate?.port(v2)
      } else {
        if v2.first == "p" || v2.first == "t" || v2.first == "f" || v2.first == "b" || v2.first == "h" || v2.first == "s" { // label or tag foreground or background
          rename?.newName(v2)
        }
      }
    }
    defer {
      info.deinitialize(count: str.count)
      info.deallocate()
    }
  }
  
//  var timer:Timer!
//  var pongd:Int = 0
//  var pingd:Int = 0
//
//  func confirmConnected() {
//    DispatchQueue.main.async {
//      self.timer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(self.pingPong), userInfo: nil, repeats: true)
//    }
//  }
//
//  var ppingd: Int!
//  var ppongd: Int!
//
//  @objc func pingPong() {
//    print("pingPong pingd \(pingd) pongd \(pongd)")
//    if pingd == ppingd {
//      print("ping missed")
//      warning?.postAlert(title: "Network", message: "Network Busy")
//      pingd = 0
//      pongd = 0
//      ping(0)
//    }
//    ppingd = pingd
//    ppongd = pongd
//  }
//
//  func ping(_ sender:Int) {
//    pingd = Int(sender) + 1
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//      let message2S = "#:ping:" + String(self.pingd) + ":"
//        self.sendMessage(message: message2S)
//    })
//  }
  
  var sendConnected = true
  
  func stream(_ aStream: Stream, handle aStreamEvent: Stream.Event) {
    switch aStreamEvent {
      
    case Stream.Event.openCompleted:
      //        print("ConnectionOpen")
      if sendConnected {
        self.sendConnected = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
          self.sendMessage(message: "#:connected")
//          self.ping(0)
//          self.confirmConnected()
          })
        }
        break
      
    case Stream.Event.hasBytesAvailable:
      //        print("HasBytesAvailable")
      readMessage()
      break
      
    case Stream.Event.hasSpaceAvailable:
      //        print("HasSpaceAvailable")
      break
      
    case Stream.Event.endEncountered:
      //        print("ConnectionClosed")
      aStream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
//      if timer != nil {
//        timer.invalidate()
//      }
      connection?.bad("ConnectionClosed")
      break
      
    case Stream.Event.errorOccurred:
      //      print("ConnectionFailed")
//      if timer != nil {
//        timer.invalidate()
//      }
      connection?.bad("ConnectionFailed")
      break
      
    default:
      //        print("ConnectionError")
//      if timer != nil {
//        timer.invalidate()
//      }
      connection?.bad("ConnectionError")
      break
    }
  }
  
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
