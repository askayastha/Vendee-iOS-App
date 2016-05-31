//
//  PhotosViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/7/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var photoScrubbingScrollView: UIScrollView!
    
//    private(set) var didSetup = false
    
    var pageViewController: UIPageViewController?
    var tinyImageViews: [UIImageView]
    var imageURLs: [String]!
    var tinyImageURLs: [String]!
    var page: Int!
    var selectedPage: Int = 0 {
        didSet {
            tinyImageViews[oldValue].layer.borderColor = UIColor.clearColor().CGColor
            tinyImageViews[oldValue].layer.borderWidth = 0.0
            tinyImageViews[selectedPage].layer.borderColor = UIColor.vendeeColor().CGColor
            tinyImageViews[selectedPage].layer.borderWidth = 1.5
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        tinyImageViews = [UIImageView]()
        super.init(coder: aDecoder)
        print("##### PhotosViewController initialization #####")
        modalTransitionStyle = .CrossDissolve
    }
    
    deinit {
        print("Deallocating PhotosViewController!")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.PhotosDidTapNotification, object: nil)
    }
    
    @IBAction func closeButton() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(togglePhotoScrubberVisibility), name: CustomNotifications.PhotosDidTapNotification, object: nil)
        
        // Setup page view
        pageViewController?.setViewControllers([viewControllerAtIndex(page)!], direction: .Forward, animated: false, completion: nil)
        
        photoScrubbingScrollView.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        positionImagesInPhotoScrubber()
        
        // Log screen views
        GoogleAnalytics.trackScreenForName("Photos View")
        FIRAnalytics.logEventWithName("Photos_View", parameters: nil)
        Answers.logCustomEventWithName("Photos View", customAttributes: nil)
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        
        photoScrubbingScrollView.hidden = true
        setPhotoScrubberVisible(false, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        super.viewDidAppear(animated)
        
        photoScrubbingScrollView.hidden = false
        setPhotoScrubberVisible(true, animated: true)
    }
    
    private func positionImagesInPhotoScrubber() {
        
        let tinyImageWidth: CGFloat = 60.0
        photoScrubbingScrollView.contentSize = CGSize(width: tinyImageWidth * CGFloat(tinyImageURLs.count), height: photoScrubbingScrollView.bounds.size.height)
        
        for page in 0..<imageURLs.count {
            
            let scrubberFrame = CGRect(
                origin: CGPoint(x: tinyImageWidth * CGFloat(page), y: 0),
                size: CGSize(width: tinyImageWidth, height: photoScrubbingScrollView.bounds.size.height)
            )
            
            // Tiny ImageView setup
            let tinyImageView = UIImageView()
            tinyImageView.tag = page
            tinyImageView.contentMode = .ScaleAspectFit
            tinyImageView.userInteractionEnabled = true
            tinyImageView.frame = scrubberFrame
            tinyImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoScrubberTapped(_:))))
            tinyImageView.pin_setImageFromURL(NSURL(string: tinyImageURLs![page])!)
            photoScrubbingScrollView.addSubview(tinyImageView)
            
            tinyImageViews.append(tinyImageView)
        }
        
        selectedPage = page
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func togglePhotoScrubberVisibility() {
        setPhotoScrubberVisible(!isPhotoScrubberVisible(), animated: true)
    }
    
    func photoScrubberTapped(recognizer: UITapGestureRecognizer) {
        let page = recognizer.view!.tag
        let currentPage = selectedPage
        let difference = page - currentPage
        let direction = difference > 0 ? UIPageViewControllerNavigationDirection.Forward : UIPageViewControllerNavigationDirection.Reverse
        
        if difference != 0 {
            pageViewController?.setViewControllers([viewControllerAtIndex(page)!], direction: direction , animated: true, completion: nil)
            selectedPage = page
        }
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Photo Scrubber", label: "Page", value: page)
        FIRAnalytics.logEventWithName("Tapped_Photo_Scrubber", parameters: ["Page": page])
        Answers.logCustomEventWithName("Tapped Photo Scrubber", customAttributes: ["Page": page])
    }
    
    func viewControllerAtIndex(index: Int) -> PhotoViewController? {
        if index >= 0 && index < imageURLs.count {
            let photoVC = PhotoViewController()
            photoVC.imageURL = NSURL(string: imageURLs[index])!
            photoVC.pageIndex = index
            
            return photoVC
        }
        
        return nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedPage" {
            pageViewController = segue.destinationViewController as? UIPageViewController
            pageViewController?.dataSource = self
            pageViewController?.delegate = self
        }
    }
    
    // MARK: - Helper methods
    
    private func setPhotoScrubberVisible(visible: Bool, animated: Bool) {
        if isPhotoScrubberVisible() == visible { return }
        print("Frame: \(photoScrubbingScrollView.frame)")
        let frame = photoScrubbingScrollView.frame
        let height = frame.size.height
        let offsetY = visible ? -height : height
        
//        UIView.animateWithDuration(animated ? 0.3 : 0.0) {
//            self.photoScrubbingScrollView.frame = CGRectOffset(frame, 0, offsetY)
//        }
        UIView.animateWithDuration(animated ? 0.5 : 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            self.photoScrubbingScrollView.frame = CGRectOffset(frame, 0, offsetY)
            }, completion: nil)
        print("Frame: \(photoScrubbingScrollView.frame)")
    }
    
    private func isPhotoScrubberVisible() -> Bool {
        return photoScrubbingScrollView.frame.origin.y < CGRectGetMaxY(view.frame)
    }
}

extension PhotosViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        print("ViewController Before")
        if let photoVC = viewController as? PhotoViewController {
            var index: Int = photoVC.pageIndex
            index -= 1
            
            if index < 0 {
                return nil
            }
            return viewControllerAtIndex(index)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        print("ViewController After")
        if let photoVC = viewController as? PhotoViewController {
            var index: Int = photoVC.pageIndex
            index += 1
            
            if index >= imageURLs.count {
                return nil
            }
            return viewControllerAtIndex(index)
        }
        return nil
    }
}

extension PhotosViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        let photoVC = pendingViewControllers.first as! PhotoViewController
        page = photoVC.pageIndex
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            selectedPage = page
        }
    }
}
