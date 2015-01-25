//
//  ViewController.swift
//  Example
//
//  Created by Ryan Fitzgerald on 1/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import UIKit
import CinchKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let f = FooBar()
        f.hello()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

