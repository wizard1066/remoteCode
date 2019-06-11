//
//  ColorService.swift
//  remoteCode
//
//  Created by localadmin on 03.06.19.
//  Copyright © 2019 ch.cqd.remoteCode. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ColorServiceDelegate {
  
    func connectedDevicesChanged(manager : ColorService, connectedDevices: [String])
    func colorChanged(manager : ColorService, colorString: String)
  
}

class ColorService : NSObject {

    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
  
     var delegate : ColorServiceDelegate?

    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
//    private let ColorServiceType = "example-color"
    
  
    private let ColorServiceType = UserDefaults.standard.string(forKey: "PeerNodeName")!
//    private let ColorServiceType = "remote-code"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser

    override init() {
      let discover:[String:String] = ["prime":myPeerId.displayName]
      self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: discover, serviceType: ColorServiceType)

        super.init()

        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()

    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
  
    func stopAdvertising() {
      self.serviceAdvertiser.stopAdvertisingPeer()
  }
  
    func send(colorName : String) {
        NSLog("%@", "sendColor: \(colorName) to \(session.connectedPeers.count) peers")

        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .unreliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }

    }

}

var peers:[String:Bool] = [:]

extension ColorService : MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)

    }
  
}



extension ColorService : MCSessionDelegate, StreamDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
        session.connectedPeers.map{$0.displayName})
    }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    let str = String(data: data, encoding: .utf8)!
    // keyboard message
    if str.first == "%" {
      chatRoom?.sendMessage(message: str)
      return
    }
    
    var parts = str.components(separatedBy: ":")
    var header:String!
    
    header = "&:\(tag[parts[1]]):"
    
    let transmit = parts.dropFirst(3).joined(separator: ":")
    let newTransmit = transmit.replacingOccurrences(of: "@:", with: header)
    chatRoom?.sendMessage(message: newTransmit)
    
  }
  
  func closeSessions() {
    for peer in session.connectedPeers {
      session.cancelConnectPeer(peer)
    }
  }
  
  func showSessions() {
    for peer in session.connectedPeers {
      print("peer \(peer.displayName)")
    }
  }
  

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
        stream.delegate = self
        stream.schedule(in: RunLoop.main, forMode: RunLoop.Mode.default)
        stream.open()
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
  
  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode){
    case Stream.Event.hasBytesAvailable:
      let input = aStream as! InputStream
      
      let dataMutablePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
      //Copies the bytes to the Mutable Pointer
      dataMutablePointer.initialize(to: 0)
      let byteCount = input.read(dataMutablePointer, maxLength: 1024)
      let data = Data(bytes: dataMutablePointer, count: byteCount)
      let str = String(bytes: data, encoding: String.Encoding.utf8)
      if str!.count < 4 || str!.count > 80 {
        print("corrupted data")
        return
      }
//      chatRoom?.sendMessage(message: str!)
//      if tag.count == 0 {
//      // wrong peer
//        return
//      }
      var parts = str!.components(separatedBy: ":")
      let tagX = tag[parts[1]]
      let bon = tagX! & Int(parts[2])!
      if bon > 0 {
        var header:String!
        let binary = tagX!
//        let forward = binary & 0b00000001 // header = +:
//        let backward = binary & 0b00000100 // header = -:
//        let left = binary & 00001000 // header = <:
//        let right = binary & 00000010 // header = >:
//        print("binary \(binary) forward \(forward) backward \(backward) left \(left) right \(right)")
//        if forward == 1 {
//          header = "+:\(binary):"
//        } else {
//          if left == 8 {
//            header = "&:\(binary):"
//          } else {
//            if right == 2 {
//              header = "&:\(binary):"
//            } else {
//              if backward == 4 {
//                header = "+:\(binary):"
//              }
//            }
//          }
//        }
        header = "&:\(binary):"
        let transmit = parts.dropFirst(3).joined(separator: ":")
        let newTransmit = transmit.replacingOccurrences(of: "@:", with: header)
        chatRoom?.sendMessage(message: newTransmit)
      }
      
    case Stream.Event.hasSpaceAvailable:
      break
    //output
    default:
      break
    }
}
  
  

}
