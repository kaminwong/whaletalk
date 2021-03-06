//
//  ChatCell.swift
//  whaletalk
//
//  Created by WONGKAI MING on 17/3/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    let messageLabel: UILabel = UILabel()
    private let bubbleImageView = UIImageView()
    
    private var outgoingConstraints: [NSLayoutConstraint]!
    private var incomingConstraints: [NSLayoutConstraint]!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
        
        messageLabel.centerXAnchor.constraint(equalTo: bubbleImageView.centerXAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: bubbleImageView.centerYAnchor).isActive = true
        
        bubbleImageView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant:50).isActive = true
        bubbleImageView.heightAnchor.constraint(equalTo: messageLabel.heightAnchor, constant: 20).isActive = true
        
        bubbleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        bubbleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        outgoingConstraints = [bubbleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                               bubbleImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor)]
        incomingConstraints = [bubbleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                               bubbleImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor)]
        
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        /*let image = UIImage(named: "MessageBubble")?.withRenderingMode(.alwaysTemplate)
        bubbleImageView.tintColor = UIColor.blue
        bubbleImageView.image = image*/
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func incoming(incoming:Bool){
        if incoming {
            NSLayoutConstraint.deactivate(outgoingConstraints)
            NSLayoutConstraint.activate(incomingConstraints)
            bubbleImageView.image = bubble.incoming
        }
        else {
            NSLayoutConstraint.deactivate(incomingConstraints)
            NSLayoutConstraint.activate(outgoingConstraints)
            //incomingConstraint.isActive = false
            //outgoingConstraint.isActive = true
            bubbleImageView.image = bubble.outgoing
        }
        }
    }

let bubble = makeBubble()

func makeBubble() -> (incoming: UIImage, outgoing: UIImage){
    let image = UIImage(named: "MessageBubble")!
    
    let insetsIncoming = UIEdgeInsets(top:17, left:26.5, bottom:17.5, right:21)
    let insetsOuting = UIEdgeInsets(top:17, left:21, bottom:17.5, right:26.5)
    
    let outgoing = coloredImage(image: image, red: 0/255, green: 122/255, blue: 255/255, alpha: 1).resizableImage(withCapInsets: insetsOuting)
    let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImageOrientation.upMirrored)
    let incoming = coloredImage(image: flippedImage, red: 229/255, green: 229/255, blue: 229/255, alpha:1).resizableImage(withCapInsets: insetsIncoming)
    return (incoming, outgoing)
    
}

func coloredImage(image: UIImage, red:CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage! {
    
    let rect = CGRect(origin: CGPoint.zero, size: image.size)
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.draw(in: rect)
    
    context?.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
    context?.setBlendMode(CGBlendMode.sourceAtop)
    context?.fill(rect)
    
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return result
    
}

