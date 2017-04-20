//
//  UIViewController+FillWithView.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 20/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func fillViewWith(subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        
        let viewConstraints: [NSLayoutConstraint] = [
            subview.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
}
