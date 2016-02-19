//
//  ViewController.swift
//  AnodeExample
//
//  Created by James Jacoby on 2/18/16.
//  Copyright © 2016 Moby, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet var usernameInput: UITextField!
  @IBOutlet var passwordInput: UITextField!
  @IBOutlet var signupButton: UIButton!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var logoutButton: UIButton!
  @IBOutlet var message: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let clientToken = "1d029eaedb78d62f91dc115ab6e1c1c1"; // replace with your anonymous client token
    let apiBaseUrl = "http://localhost:3000/api/"; // replace with your API base URL
    
    Anode.initializeWithBaseUrl(apiBaseUrl, clientToken: clientToken)
    
    checkLoginStatus()
  }
  
  func checkLoginStatus() {
    if ANUser.currentUser() != nil {
      message.text = "refreshing login"
      
      ANUser.refreshLoginWithBlock({ (user, err) -> Void in
        self.setLoggedIn()
      })
    } else {
      setLoggedOut("please login")
    }
  }
  
  func doSomething() {
    let widget = ANObject(type: "widget")
    widget.setObject("ABC Widget", forKey: "name")
    
    widget.saveWithBlock({ (obj: AnyObject!, err: NSError!) -> Void in
      print("something!")
    })
  }
  
  func getWidgets() {
    
  }
  
  func setLoggedIn() {
    signupButton.enabled = false
    loginButton.enabled = false
    logoutButton.enabled = true
    
    message.text = "logged in"
  }
  
  func setLoggedOut(msg: String = "logged out") {
    signupButton.enabled = true
    loginButton.enabled = true
    logoutButton.enabled = false
    
    message.text = msg
  }

  @IBAction func signUp(sender: AnyObject) {
    let user = ANUser(username: usernameInput.text, password: passwordInput.text)
    user.saveWithBlock { (user, err) -> Void in
      if err == nil {
        self.message.text = "signed up!"
      } else {
        self.message.text = err.localizedDescription
      }
    }
  }
  
  @IBAction func login(sender: AnyObject) {
    ANUser.loginWithUsername(usernameInput.text, password: passwordInput.text) { (user, err) -> Void in
      if err == nil {
        self.message.text = "logged in!"
        self.setLoggedIn()
      } else {
        self.message.text = err.localizedDescription
      }
    }
  }
  
  @IBAction func logout(sender: AnyObject) {
    ANUser.logout()
    setLoggedOut()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

