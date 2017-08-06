//
//  PopVC.swift
//  PixelCity
//
//  Created by Kyle on 8/5/17.
//  Copyright © 2017 Kyle Aquino. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    var passedImage: UIImage!
    
    func initData(forImage image: UIImage) {
        
        self.passedImage = image
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = passedImage
        addSwipe()
    }
    
    func addSwipe() {
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipe.direction = .down
        swipe.delegate = self
        view.addGestureRecognizer(swipe)
        
    }

    @objc func dismissView() {
        
        dismiss(animated: true, completion: nil)
        
    }

}
