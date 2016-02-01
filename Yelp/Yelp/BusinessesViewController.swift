//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import SVPullToRefresh

class BusinessesViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    @IBOutlet var tableview: UITableView!

    var businesses: [Business]!
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var isList:Bool = true
    var isMoreDataLoading = false
    var mapView:MKMapView?
    var searchText:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView(frame: tableview.frame)
        mapView?.delegate = self
        
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        tableview.addInfiniteScrollingWithActionHandler({
            () -> Void in
            Business.searchWithTerm(self.searchText, sort: nil, categories: nil, deals: nil, completion: {
                (businesses: [Business]!, error: NSError!) -> Void in
                
                for business in businesses {
                    self.businesses.append(business)
                    
                }
                self.tableview.reloadData()
                self.tableview.infiniteScrollingView.stopAnimating()
                }, offset: self.businesses.count)
            
        })
        
        

        Business.searchWithTerm("", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableview.reloadData()

        })

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }
    @IBAction func mapSelected(sender: AnyObject) {
        let switchButton = sender as! UIBarButtonItem
        if(isList) {
            UIView.transitionFromView(tableview, toView: mapView!, duration: 0.5, options: .TransitionFlipFromLeft, completion: {
                (complete) -> Void in
                switchButton.title = "List"
            })

            isList = false
            let centerLocation = CLLocation(latitude: 37.785771, longitude: -122.406165)
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegionMake(centerLocation.coordinate, span)
            mapView!.setRegion(region, animated: false)

        } else {
            UIView.transitionFromView(mapView!, toView: tableview, duration: 0.5, options: .TransitionFlipFromRight, completion: {
                (complete) -> Void in
                switchButton.title = "Map"
            })
            isList = true
        }
    }
    
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        var i = 0
        for business in businesses {
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = business.locationCoordinate!.coordinate
            annotation.title = business.name
            
            
            mapView.addAnnotation(annotation)
            i = i+1
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        
        if pinView == nil {
            //println("Pinview was nil")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        let button = UIButton(type: .DetailDisclosure)// button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if control == view.rightCalloutAccessoryView{
//            performSegueWithIdentifier("showDetail", sender: nil)
//        }
    }
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RestaurantTableViewCell
        let business = businesses[indexPath.row]
        
        if let imageURL = business.imageURL {
            cell.restaurantImage.setImageWithURL(imageURL)
        }

        cell.restaurantTitle.text = business.name

        cell.restaurantRating.setImageWithURL(business.ratingImageURL!)
        cell.restaurantReviews.text = "\(business.reviewCount!.stringValue) reviews"
        cell.restaurantDistance.text = business.distance
        cell.restaurantAddress.text = business.address!
        cell.restaurantType.text = business.categories
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = businesses {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: businesses[indexPath.row])
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        Business.searchWithTerm(searchText, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableview.reloadData()
        })

    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableview.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableview.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableview.dragging) {
                isMoreDataLoading = true
                
                // ... Code to load more results ...
            }
        }
    }
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let desController = segue.destinationViewController as! DetailViewController
        let business = sender as! Business
        desController.business = business
        
    }

}
