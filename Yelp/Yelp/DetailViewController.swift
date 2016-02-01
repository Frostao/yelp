//
//  DetailViewController.swift
//  Yelp
//
//  Created by Carl Chen on 1/31/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantTitle: UILabel!
    @IBOutlet weak var restaurantDistance: UILabel!
    @IBOutlet weak var restaurantRating: UIImageView!
    @IBOutlet weak var restaurantReviews: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    @IBOutlet weak var restaurantType: UILabel!
    
    var business: Business?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let business = business {
            if let imageURL = business.imageURL {
                restaurantImage.setImageWithURL(imageURL)
            }
            
            restaurantTitle.text = business.name
            
            restaurantRating.setImageWithURL(business.ratingImageURL!)
            restaurantReviews.text = "\(business.reviewCount!.stringValue) reviews"
            restaurantDistance.text = business.distance
            restaurantAddress.text = business.address!
            restaurantType.text = business.categories
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
