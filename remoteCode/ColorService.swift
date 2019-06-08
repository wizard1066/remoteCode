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
    private let ColorServiceType = "example-color"

    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)

    private let serviceAdvertiser : MCNearbyServiceAdvertiser
//    private let serviceBrowser : MCNearbyServiceBrowser

    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
//        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)

        super.init()

        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()

//        self.serviceBrowser.delegate = self
//        self.serviceBrowser.startBrowsingForPeers()
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
//        self.serviceBrowser.stopBrowsingForPeers()
    }
  
    func send(colorName : String) {
        NSLog("%@", "sendColor: \(colorName) to \(session.connectedPeers.count) peers")
      
      
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
//                  try self.session.send(colorName.data(using: .utf8)!, toPeers: peers2Connect, with: .reliable)
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
//        if peers[peerID.displayName] == nil {
          invitationHandler(true, self.session)
//          peers[peerID.displayName] = true
//        }
    }
  
}


//extension ColorService : MCNearbyServiceBrowserDelegate {
//
//    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
//        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
//    }
//
//    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        NSLog("%@", "foundPeer: \(peerID)")
//        NSLog("%@", "invitePeer: \(peerID)")
//        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
//    }
//
//    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        NSLog("%@", "lostPeer: \(peerID)")
//    }
//}

extension ColorService : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
        session.connectedPeers.map{$0.displayName})
    }
  
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//      NSLog("%@", "didReceiveData: \(data.count) bytes")
        let str = String(data: data, encoding: .utf8)!
//        chatRoom?.sendMessage(message: str)
        var parts = str.components(separatedBy: ":")
      
      
        // this is needed cause the stupid system connects to itself...
//        print("parts \(parts)")
        if tag[parts[1]] == nil {
          return
        }
      
          if parts.count > 5 {
            let tagX = tag[parts[1]]
            let bon = tagX! & Int(parts[2])!
            if bon > 0 {
//              print("parts BEFORE \(parts) ")
//              let binary = Int(parts[2])!
              let binary = tagX!
              let forward = binary & 0b00000001 // header = +:
              let backward = binary & 0b00000100 // header = -:
              let left = binary & 00001000 // header = <:
              let right = binary & 00000010 // header = >:
              
              print("\(parts) \(forward) \(backward) \(left) \(right)")
              
//              if left != 0 || right != 0 {
//                parts[5] = "0"
//              }
//              if forward != 0 || backward != 0 {
//                parts[4] = "0"
//              }
              
              var header:String!
              if forward != 0 {
                header = "+:"
              } else {
                if backward != 0 {
                  header = "+:"
                } else {
                  if left != 0 {
                    header = "-:"
                  } else {
                    if right != 0 {
                      header = "-:"
                    }
                  }
                }
              }
              
              let transmit = parts.dropFirst(3).joined(separator: ":")
              let newTransmit = transmit.replacingOccurrences(of: "@:", with: header)
              print("newTransmit \(newTransmit)")
              chatRoom?.sendMessage(message: newTransmit)
            }
          }
      
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
  
  

}
