//
//  PhotoViewController.swift
//  FlickShop
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
        
        // Double TapGestureRecognizer setup
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        
        zoomingScrollView.addGestureRecognizer(doubleTapRecognizer)
        zoomableImageSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func zoomableImageSetup() {
        
        // Spinner setup
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.hidesWhenStopped = true
        spinner.center = CGPoint(x: view.center.x, y: view.center.y)
        spinner.startAnimating()
        view.addSubview(spinner)
        
        // Large ImageView setup
        imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.pin_setImageFromURL(imageURL) { [unowned self] _ in
            spinner.stopAnimating()
            
            print("Large Image Size: \(self.imageView.image!.size)")
            self.imageView.frame = CGRect(origin: CGPointMake(0, 0), size: self.imageView.image!.size)
//            self.imageView.frame = self.centerFrameFromImage(self.imageView.image)
            
            // Zooming ScrollView scale setup
            self.zoomingScrollView.addSubview(self.imageView)
            self.zoomingScrollView.contentSize = self.imageView.image!.size
            
            let scaleWidth = self.zoomingScrollView.bounds.size.width / self.zoomingScrollView.contentSize.width
            let scaleHeight = self.zoomingScrollView.bounds.size.height / self.zoomingScrollView.contentSize.height
            let minScale = min(scaleWidth, scaleHeight)
            self.zoomingScrollView.minimumZoomScale = minScale  ; print("Min Zoom Scale: \(self.zoomingScrollView.minimumZoomScale)")
            self.zoomingScrollView.maximumZoomScale = 1.5
            self.zoomingScrollView.zoomScale = minScale         ; print("Zoom Scale: \(self.zoomingScrollView.zoomScale)")            
            self.centerScrollViewContents()
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
        print("scrollViewDidZoom")
        centerScrollViewContents()
    }
}
