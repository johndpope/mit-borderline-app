//
//  ViewController.swift
//  mit-borderline-app
//
//  Created by Elaine Xiao on 6/1/20.
//  Copyright © 2020 Elaine Xiao. All rights reserved.
//

import UIKit
import SwiftyGif

class ViewController: UIViewController {
    
    let logoAnimationView = LogoAnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoAnimationView)
        logoAnimationView.pinEdgesToSuperView()
        logoAnimationView.logoGifImageView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logoAnimationView.logoGifImageView.startAnimatingGif()
    }
}

extension ViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}

