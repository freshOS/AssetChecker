//
//  ViewController.swift
//  AssetChecker
//
//  Created by joeboyscout04 on 11/22/2017.
//  Copyright (c) 2017 joeboyscout04. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageViewOne.image = UIImage(named: "icon_orange")
        imageViewTwo.image = UIImage(named: "icon_vermillion")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

