//
//  ViewController.swift
//  sampleGroupChat
//
//  Created by Jason Du on 2016-04-06.
//  Copyright © 2016 Jason Du. All rights reserved.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {

    var ref: Firebase!

    @IBOutlet var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url: "https://samplegroupchat.firebaseio.com")
        
    }
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil { print(error.description); return }
            self.performSegueWithIdentifier("LoginToChat", sender: nil)
            print(self.ref.authData!)

        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navVc = segue.destinationViewController as! UINavigationController
        let chatVc = navVc.viewControllers.first as! ChatViewController
        chatVc.senderId = ref.authData.uid
        chatVc.senderDisplayName = username.text
    }

}

