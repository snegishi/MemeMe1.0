//
//  ViewController.swift
//  MemeMe
//
//  Created by Shin Negishi on 12/1/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var count = 0
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func incrementCount() {
        self.count += 1
        self.label.text = "\(self.count)"
    }

}

