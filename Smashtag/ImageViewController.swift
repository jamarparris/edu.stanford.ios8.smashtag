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
    
    private var userDidZoom = false
    private func setScrollViewZoomScaleProperties() {
        
        if scrollView != nil {
            
            //if user has explicitly zoomed, do not update properties            
            if userDidZoom {
                return
            }
            
            //ensure there is actually a frame size on the imageView
            if imageView.frame.width == 0 || imageView.frame.height == 0 {
                return
            }
            
            //println("scrollView bounds: \(scrollView.bounds.size), frame: \(scrollView.frame.size)")
            //println("imageView bounds: \(imageView.bounds.size), frame: \(imageView.frame.size)")
            //println()
            
            //use bounds as we care about the sizes within their own co-ordinate system
            let widthRatio = scrollView.bounds.width/imageView.bounds.width
            let heightRatio = scrollView.bounds.height/imageView.bounds.height
            
            //use the larger of the ratios as the zoomScale we want so that image fills the screen
            let zoomScale = widthRatio > heightRatio ? widthRatio : heightRatio
            
            if zoomScale > 1 {
                //if bigger than 1, need to increase maximum from default of 1
                scrollView.maximumZoomScale = zoomScale
                scrollView.minimumZoomScale = 1
            } else {
                //if less than 1, need to decrease minimum from default of 1
                scrollView.minimumZoomScale = zoomScale
                scrollView.maximumZoomScale = 1
            }
            
            //update actual value to the zoomScale just calculated
            scrollView.zoomScale = zoomScale
            
            //println("Aspect Ratio: \(aspectRatio!), Calculated: \(imageView.bounds.size.width/imageView.bounds.size.height), Current Zoom Scale: \(scrollView.zoomScale), Min: \(scrollView.minimumZoomScale), Max: \(scrollView.maximumZoomScale)")
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //println("view will layout subviews")
        
        //whenever relayout happens (e.g. rotation) update the scrollViewZoomScale
        setScrollViewZoomScaleProperties()
    }
    
    private func fetchImage() {
        if let url = imageURL {
            activityIndicator?.startAnimating()
            
            DataFetcher().getAsyncNSDataForURL(url) {
                if url == self.imageURL {
                    let imageData = $0
                    self.image = UIImage(data:imageData)
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        //update userDidZoom property so that auto zoom to fit  no longer happens in setScrollViewZoomScaleProperties function
        userDidZoom = true
    }
}
