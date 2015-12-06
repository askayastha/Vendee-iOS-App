//
//  PriceViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/25/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import NMRangeSlider

class PriceFilterViewController: UITableViewController {
    
    private let minValue = 0
    private let maxValue = 29
    
    let prices = [
        "0", "10", "25", "50", "75", "100", "125", "150", "200", "250",
        "300", "350", "400", "500", "600", "700", "800", "900", "1000", "1250",
        "1500", "1750", "2000", "2250", "2500", "3000", "3500", "4000", "4500", "5000+"
    ]
    
    var priceRangeCode: String?
    var selectedPrices: [String: String]!
    
    @IBOutlet weak var minPriceLabel: UILabel!
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var priceRangeSlider: NMRangeSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Prices setup
        priceRangeSlider.minimumValue = Float(minValue)
        priceRangeSlider.maximumValue = Float(maxValue)
        priceRangeSlider.minimumRange = 1
        priceRangeSlider.stepValue = 1
        priceRangeSlider.stepValueContinuously = true
        
        selectedPrices = appDelegate.filterParams["price"] as! [String: String]
        
        // Setup previous values
        if let priceKey = selectedPrices.keys.first {
            let lowerIndex = priceKey.componentsSeparatedByString(":").first!   ;print("LOWER INDEX: \(lowerIndex)")
            let upperIndex = priceKey.componentsSeparatedByString(":").last!    ;print("UPPER INDEX: \(upperIndex)")
            
            priceRangeSlider.lowerValue = Float(lowerIndex)!
            priceRangeSlider.upperValue = Float(upperIndex)!
            
            // Update UI
            priceRangeSlider.setLowerValue(Float(lowerIndex)!, upperValue: Float(upperIndex)!, animated: false)
            updateUIForLowerValue(Int(lowerIndex)!, andUpperValue: Int(upperIndex)!)
            
        } else {
            priceRangeSlider.lowerValue = Float(minValue)
            priceRangeSlider.upperValue = Float(maxValue)
        }
    }
    
    @IBAction func sliderValueChanged(sender: NMRangeSlider) {
        let minIndex = Int(sender.lowerValue)
        let maxIndex = Int(sender.upperValue)
        
        if minIndex == minValue && maxIndex == maxValue {
            priceRangeCode = nil
        } else {
            priceRangeCode = "p\(minIndex + 20):\(maxIndex + 20)"
        }
        updateUIForLowerValue(minIndex, andUpperValue: maxIndex)
        
        print("PRICE RANGE CODE: \(priceRangeCode)")
        
        // Filter Stuff
        if let priceRangeCode = priceRangeCode {
            let lowerIndex = Int(sender.lowerValue)
            let upperIndex = Int(sender.upperValue)
            let priceKey = "\(lowerIndex):\(upperIndex)"
            
            selectedPrices.removeAll()
            selectedPrices[priceKey] = priceRangeCode
            
        } else {
            selectedPrices.removeAll()
        }
        
        print(selectedPrices)
        
        appDelegate.filterParams["price"] = selectedPrices
        
        // Refresh Side Tab
        filterDidChangeNotification()
    }
    
    deinit {
        print("PriceFilterViewController Deallocating !!!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    private func updateUIForLowerValue(lowerValue: Int, andUpperValue upperValue: Int) {
        minPriceLabel.text = "$\(prices[lowerValue])"
        maxPriceLabel.text = "$\(prices[upperValue])"
    }

}
