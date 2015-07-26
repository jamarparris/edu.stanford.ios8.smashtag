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
            
            setScrollViewZoomScaleProperties()
        
            //stop animating spinner whenever an image is set
            activityIndicator?.stopAnimating()
        }
    }
    
    private func setScrollViewZoomScaleProperties() {
        
        if scrollView != nil {
            
            let widthRatio = scrollView.frame.width/imageView.frame.width
            let heightRatio = scrollView.frame.height/imageView.frame.height
            
            //use the larger of the ratios as the zoomScale we want so that image fills the screen
            let zoomScale = widthRatio > heightRatio ? widthRatio : heightRatio
            
            if zoomScale > 1 {
                //if bigger than 1, need to increase maximum from default of 1
                scrollView.maximumZoomScale = zoomScale
            } else {
                //if less than 1, need to decrease minimum from default of 1
                scrollView.minimumZoomScale = zoomScale
            }
            
            //update actual value to the zoomScale just calculated
            scrollView.zoomScale = zoomScale
            
            println("Aspect Ratio: \(aspectRatio!), Current Zoom Scale: \(scrollView.zoomScale), Min: \(scrollView.minimumZoomScale), Max: \(scrollView.maximumZoomScale)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Image"
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
    
    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
