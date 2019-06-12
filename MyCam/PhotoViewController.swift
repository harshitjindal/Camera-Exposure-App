//
//  PhotoViewController.swift
//  MyCam
//
//  Created by Harshit Jindal on 12/06/19.
//  Copyright © 2019 Harshit Jindal. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    var takenPhoto : UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let availableImage = takenPhoto {
            imageView.image = availableImage
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
