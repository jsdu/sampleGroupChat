//
//  ChatViewController.swift
//  sampleGroupChat
//
//  Created by Jason Du on 2016-04-06.
//  Copyright © 2016 Jason Du. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!   // Messages to the right
    var incomingBubbleImageView: JSQMessagesBubbleImage!   // Messages to the left
    
    let rootRef = Firebase(url: "https://samplegroupchat.firebaseio.com/")
    var messageRef: Firebase!

    
    // Sets up the messages colour
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message: JSQMessage = messages[indexPath.item]
        /**
         *  iOS7-style sender name labels
         */
        if (message.senderId == self.senderId) {
            return nil
        }
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = messages[indexPath.item - 1]
            if (previousMessage.senderId == message.senderId) {
                return nil
            }
        }
        /**
         *  Don't specify attributes to use the defaults.
         */
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        /**
         *  iOS7-style sender name labels
         */
        let currentMessage: JSQMessage = messages[indexPath.item]
        if (currentMessage.senderId == self.senderId) {
            return 0.0
        }
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = messages[indexPath.item - 1]
            if (previousMessage.senderId == currentMessage.senderId) {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Group Chat"
        setupBubbles()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero

        messageRef = rootRef.childByAppendingPath("messages")
    }
    
    func addMessage(id: String, displayName:String, text: String) {
        let message = JSQMessage(senderId: id, displayName: displayName, text: text)
        messages.append(message)
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
            
            print(message.senderDisplayName)
            cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0, 45.0, 0.0, 0.0)
        }
        return cell
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "text": text,
            "senderId": senderId,
            "displayName": senderDisplayName
        ]
        itemRef.setValue(messageItem) // 3
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
    }
    
    // Listens and displays messages 
    private func observeMessages() {
        // 1
        let messagesQuery = messageRef.queryLimitedToLast(25)
        // 2
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            // 3
            let id = snapshot.value["senderId"] as! String
            let text = snapshot.value["text"] as! String
            let displayName = snapshot.value["displayName"] as! String
            // 4
            self.addMessage(id, displayName:displayName, text: text)
            
            // 5
            self.finishReceivingMessage()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

}
