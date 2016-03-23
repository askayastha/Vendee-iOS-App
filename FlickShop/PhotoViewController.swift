//
//  PhotoViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/10/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var zoomingScrollView: UIScrollView!
    var imageView: UIImageView!
    var imageURL: NSURL!
    var pageIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Frame: \(view.frame)")
        zoomingScrollView = UIScrollView(frame: view.frame)
        zoomingScrollView.delegate = self
        
        // Setup gestures
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(_:)))
        zoomingScrollView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        zoomingScrollView.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        zoomableImageSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func zoomableImageSetup() {
        
        // Spinner setup
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.center = CGPoint(x: view.center.x, y: view.center.y)
        spinner.startAnimating()
        view.addSubview(spinner)
        
        // Large ImageView setup
        imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.pin_setImageFromURL(imageURL) { [weak self] _ in
            spinner.stopAnimating()
            
            if let strongSelf = self {
                print("Image Size: \(strongSelf.imageView.image!.size)")
                
                strongSelf.imageView.frame = CGRect(origin: CGPointMake(0, 0), size: strongSelf.imageView.image!.size)
                // strongSelf.imageView.frame = strongSelf.centerFrameFromImage(strongSelf.imageView.image)
                
                // Zooming ScrollView scale setup
                strongSelf.zoomingScrollView.addSubview(strongSelf.imageView)
                strongSelf.zoomingScrollView.contentSize = strongSelf.imageView.image!.size
                
                let scaleWidth = strongSelf.zoomingScrollView.bounds.size.width / strongSelf.zoomingScrollView.contentSize.width
                let scaleHeight = strongSelf.zoomingScrollView.bounds.size.height / strongSelf.zoomingScrollView.contentSize.height
                let minScale = min(scaleWidth, scaleHeight)
                strongSelf.zoomingScrollView.minimumZoomScale = minScale  ; print("Min Zoom Scale: \(strongSelf.zoomingScrollView.minimumZoomScale)")
                strongSelf.zoomingScrollView.maximumZoomScale = 1.5
                strongSelf.zoomingScrollView.zoomScale = minScale         ; print("Zoom Scale: \(strongSelf.zoomingScrollView.zoomScale)")
                strongSelf.centerScrollViewContents()
            }
        }
        
        view.addSubview(zoomingScrollView)
    }
    
    private func centerFrameFromImage(image: UIImage?) -> CGRect {
        if image == nil {
            return CGRectZero
        }
        
        let scaleFactor = zoomingScrollView.frame.size.width / image!.size.width
        let newHeight = image!.size.height * scaleFactor
        
        var newImageSize = CGSize(width: zoomingScrollView.frame.size.width, height: newHeight)
        
        newImageSize.height = min(zoomingScrollView.frame.size.height, newImageSize.height)
        
        let centerFrame = CGRect(x: 0.0, y: (zoomingScrollView.frame.size.height - newImageSize.height)/2, width: newImageSize.width, height: newImageSize.height)
        
        return centerFrame
    }
    
    func scrollViewTapped(recognizer: UITapGestureRecognizer) {
        CustomNotifications.photosDidTapNotification()
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        
        func zoomInZoomOut(point: CGPoint) {
            var newZoomScale = zoomingScrollView.zoomScale * 1.5
            newZoomScale = min(newZoomScale, zoomingScrollView.maximumZoomScale)    ;print("New zoom scale: \(newZoomScale)")
            newZoomScale = (zoomingScrollView.zoomScale == zoomingScrollView.maximumZoomScale) ? zoomingScrollView.minimumZoomScale : newZoomScale
            
            let scrollViewSize = zoomingScrollView.bounds.size
            
            let width = scrollViewSize.width / newZoomScale
            let height = scrollViewSize.height / newZoomScale
            let x = point.x - (width / 2.0)
            let y = point.y - (height / 2.0)
            
            let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
            
            zoomingScrollView.zoomToRect(rectToZoom, animated: true)
        }
        
        let pointInView = recognizer.locationInView(imageView)
        zoomInZoomOut(pointInView)
    }

}

// MARK: - ScrollView delegate

extension PhotoViewController: UIScrollViewDelegate {
    
    private func centerScrollViewContents() {
        let boundsSize = zoomingScrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(zoomingScrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(zoomingScrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
