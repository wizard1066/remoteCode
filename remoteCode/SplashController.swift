//
//  SplashController.swift
//  legoSocket
//
//  Created by localadmin on 14.05.19.
//  Copyright © 2019 ch.cqd.legoblue. All rights reserved.
//

import UIKit

class SplashController: UIViewController, FeedBackConnection, UITextFieldDelegate, PostAlert, ColorSearchDelegate {

  func connectedDevicesChanged(manager: ColorSearch, connectedDevices: [String]) {
    print("connected \(connectedDevices)")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
      self.digitalOut.isEnabled = true
      self.analogOut.isEnabled = true
      self.motionOut.isEnabled = true
      peerConnection = true
      })
    
  }
  
  func colorChanged(manager: ColorSearch, colorString: String) {
    print("color \(colorString)")
  }
  

  
  
  @IBAction func digitalButton(_ sender: Any) {
    if ok2Connect || peerConnection {
      self.performSegue(withIdentifier: "digital", sender: nil)
    }
  }
  
  @IBOutlet weak var digitalOut: UIButton!
  @IBAction func analogButton(_ sender: Any) {
    if ok2Connect || peerConnection {
      self.performSegue(withIdentifier: "analog", sender: nil)
    }
  }
  
  @IBOutlet weak var analogOut: UIButton!
  
  
  @IBOutlet weak var motionOut: UIButton!
  
  @IBAction func motionButton(_ sender: Any) {
    if ok2Connect || peerConnection {
      colorService = ColorService()
      self.performSegue(withIdentifier: "motion", sender: nil)
    }
  }
  
  
  @IBOutlet weak var gameOut: UIButton!
  @IBAction func gameButton(_ sender: Any) {
  if ok2Connect {
    colorSearch.stopSearch()
    self.performSegue(withIdentifier: "game", sender: nil)
    }
  }
  
  
  @IBOutlet weak var imgView: UIImageView!
  
  func animate_images(based:String) {
    print("animate \(based)")
    imgView.stopAnimating()
    var myimgArr:[String] = []
    uniqueID = based
    switch based {
      case "R":
        myimgArr = ["ricon1.png","ricon2.png","ricon3.png","ricon4.png","ricon5.png","ricon6.png"]
        loadImages(images: myimgArr)
      case "Y":
        myimgArr = ["yicon1.png","yicon2.png","yicon3.png","yicon4.png","yicon5.png","yicon6.png"]
        loadImages(images: myimgArr)
      case "B":
        myimgArr = ["bicon1.png","bicon2.png","bicon3.png","bicon4.png","bicon5.png","bicon6.png"]
        loadImages(images: myimgArr)
      case "G":
        myimgArr = ["gicon1.png","gicon2.png","gicon3.png","gicon4.png","gicon5.png","gicon6.png"]
        loadImages(images: myimgArr)
      default:
        print("stupid switch statements")
    }
    
  }
  
  func loadImages(images:[String]) {
    var frames = [UIImage]()
    
    for i in 0..<images.count {
      frames.append(UIImage(named: images[i])!)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
      self.imgView.animationImages = frames
      self.imgView.animationDuration = 4
      self.imgView.animationRepeatCount = 24
      self.imgView.startAnimating()
    })
  }
  
  
  func bad(_ value: String) {
    let alertController = UIAlertController(title: value, message: value, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (alertAction) in
      self.connectLabel.setTitle("Connect", for: .normal)
    }
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func ok(_ value: String) {
    let alertController = UIAlertController(title: value, message: value, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(defaultAction)
    self.present(alertController, animated: true, completion: nil)
    
  }
  
  var nextVC:String?
  
  @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {
    if chatRoom?.returnOutStatus() == InputStream.Status.closed {
      connectLabel.setTitle("Connect", for: .normal)
      
      self.digitalOut.isEnabled = false
      self.analogOut.isEnabled = false
      self.motionOut.isEnabled = false
      self.gameOut.isEnabled = false
      ipaddress.isEnabled = true
      portNumber.isEnabled = true
      connectLabel.isEnabled = true
    } else {
      connectLabel.setTitle("Connected", for: .normal)
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
        self.connectLabel.setTitle("Shake to Disconnect", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
          self.connectLabel.setTitle("Connected", for: .normal)
        })
      })
      connectLabel.isEnabled = false
      ipaddress.isEnabled = false
      portNumber.isEnabled = false
    }
  }
  
  @IBOutlet weak var ipaddress: UITextField!
  @IBOutlet weak var portNumber: UITextField!
  
  var ok2Connect = false
  
  @IBAction func connect(_ sender: UIButton) {
    //ipaddress.text = "10.182.81.102"
    connectLabel.setTitle("Connecting ...", for: .normal)
    //    ipaddress.text = "10.182.81.130"
    //    portNumber.text = "50011"
    if ipaddress.text != "" && portNumber.text != "" {
      let port2G = Int(portNumber.text!)
      let connect2G = ipaddress.text!
//      let connect2G = "10.182.81.130"
      chatRoom = ChatRoom(host: connect2G, port: UInt32(port2G!))
      //      chatRoom.delegate = self
      chatRoom?.connection = self
      
      chatRoom?.setupNetworkCommunication()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
        if chatRoom?.returnOutStatus() == InputStream.Status.open {
          self.connectLabel.setTitle("Connected", for: .normal)
          self.connectLabel.isEnabled = false
          self.ipaddress.isEnabled = false
          self.portNumber.isEnabled = false
          self.ok2Connect = true
          self.digitalOut.isEnabled = true
          self.analogOut.isEnabled = true
          self.motionOut.isEnabled = true
          self.gameOut.isEnabled = true
          
//          chatRoom.confirmConnected()
        }
      })
    }
  }
  
  @IBOutlet weak var connectLabel: UIButton!
  
  func configImgView() {
    let hitMe = UITapGestureRecognizer(target: self, action: #selector(toggleMotion))
    let hitMeLong = UILongPressGestureRecognizer(target: self, action: #selector(longMotion))
    hitMe.numberOfTapsRequired = 1
    imgView.isUserInteractionEnabled = true
    imgView.addGestureRecognizer(hitMe)
    imgView.addGestureRecognizer(hitMeLong)
  }
  
  var colors = ["R","G","B","Y"]
  var indexOf = 0
  
  func flip() -> String {
    if indexOf > 2 {
      indexOf = 0
    } else {
      indexOf = indexOf + 1
    }
    return(colors[indexOf])
  }
  
  @objc func toggleMotion(sender: UITapGestureRecognizer) {
    print("uniqueID \(uniqueID)")
    uniqueID = flip()
    print("uniqueID \(uniqueID)")
    animate_images(based: uniqueID)

  }
  
  @objc func longMotion(sender: UITapGestureRecognizer) {
    // do something else
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ipaddress.delegate = self
    portNumber.delegate = self
    connectLabel.isEnabled = false
    doDefault()
    colorSearch = ColorSearch()
    colorSearch.delegate = self
    configImgView() 
  }
  
  override func viewDidAppear(_ animated: Bool) {
//    animate_images()
    if chatRoom != nil {
      chatRoom?.warning = self
    }
    animate_images(based: "R")
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == ipaddress {
      guard CharacterSet(charactersIn: "0123456789.").isSuperset(of: CharacterSet(charactersIn: string)) else {
        return false
      }
      
      return true
    }
    if textField == portNumber {
      guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
        return false
      }
      if (textField.text!.count > 5) {
        let quote = (textField.text?.dropLast(1))!
        let newString = String(quote)
        textField.text? = newString
        return false
      }
      return true
    }
    return true
  }
  
  func isValidIP(s: String) -> Bool {
    let parts = s.components(separatedBy: ".")
    let nums = parts.compactMap { Int($0) }
    return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
  }
  
  
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == portNumber {
      if textField.text!.isEmpty {
        redo("You MUST enter a port number")
        connectLabel.isEnabled = false
        return
      } else {
        if Int(textField.text!)! < 1025 {
          redo("Port numbers MUST be greater than 1024")
          connectLabel.isEnabled = false
          return
        }
      }
    }
    if textField == ipaddress {
      if textField.text!.isEmpty {
        redo("You MUST enter an IP address")
        connectLabel.isEnabled = false
        return
      } else {
        if !isValidIP(s: textField.text!) {
          redo("Sorry, that ISN'T a valid IP address")
          connectLabel.isEnabled = false
          return
        }
      }
    }
    
    if !ipaddress.text!.isEmpty && !portNumber.text!.isEmpty {
      connectLabel.isEnabled = true
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  func redo(_ value: String) {
    let alertController = UIAlertController(title: "Unable to Connect", message: value, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(defaultAction)
    self.present(alertController, animated: true, completion: nil)
    
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      let alertController = UIAlertController(title: "Disconnect?", message: "Do you want to disconnect", preferredStyle: .alert)
      let ignoreAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      let okAction = UIAlertAction(title: "Disconnect", style: .default) { (action2T) in
        chatRoom?.sendMessage(message: "#:disconnect")
        chatRoom?.stopChat()
        colorSearch.closeStream()
        colorService.closeSessions()
        colorService.stopAdvertising()
        
        self.connectLabel.setTitle("Connect", for: .normal)
        self.connectLabel.isEnabled = true
        self.ipaddress.isEnabled = true
        self.portNumber.isEnabled = true
        self.ok2Connect = false
        self.digitalOut.isEnabled = false
        self.analogOut.isEnabled = false
        self.motionOut.isEnabled = false
        self.gameOut.isEnabled = false
        
        //        self.performSegue(withIdentifier: "returnToSegue", sender: self)
      }
      alertController.addAction(ignoreAction)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func doDefault() {
  
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
  
        UserDefaults.standard.set(version, forKey: "version_preference")
        UserDefaults.standard.set(build, forKey: "build_preference")
  
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
