//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/25/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            //contentSize must be set on a scrollview so set it to size of the imageView
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            
            //optimally these would be based on the the image size
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //use just imageURL and aspectRatio to make it more reusable
    var imageURL: NSURL? {
        didSet {
            //when url changes, set existing image to nothing
            image = nil
            
            //ensure view is on screen before fetching image to conserve data
            if view.window != nil {
                fetchImage()
            }
        }
    }
    var aspectRatio: Double?
    
    //frame will start at 0,0
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            
            //this will cause the imageView will expand to fit the size of it's image
            imageView.sizeToFit()
            
            //ensure scrollView contentSize is updated whenever image (and as a result imageView) changes. Add ? just in case image set when scrollView isn't set yet
            scrollView?.contentSize = imageView.frame.size
            
            //stop animating spinner whenever an image is set
            activityIndicator?.stopAnimating()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.addSubview(imageView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //just in case someone updates imageUrl when off screen, call fetchImage here
        if image == nil {
            fetchImage()
        }
        
    }
    
    private func fetchImage() {
        if let url = imageURL {
            activityIndicator?.startAnimating()
            
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                
                //load image on another queue
                if let imageData = NSData(contentsOfURL: url) {
                    
                    //now we have imageData, update image on main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        if url == self.imageURL {
                            self.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
