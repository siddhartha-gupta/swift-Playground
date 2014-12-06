//
//  ViewController.swift
//  playground
//
//  Created by Siddhartha Gupta on 06/12/14.
//  Copyright (c) 2014 Siddhartha Gupta. All rights reserved.
//

import UIKit

let kCellIdentifier: String = "SearchResultCell"

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {

@IBOutlet var appsTableView : UITableView?
var tableData = []
var api = APIController()
var imageCache = [String : UIImage]()
    
    override func viewDidLoad() {
        api.searchItunesFor("Software")
        self.api.delegate = self
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary

        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        // Add a check to make sure this exists
        let cellText: String? = rowData["trackName"] as? String
        // Get the formatted price string for display in the subtitle
        let formattedPrice: NSString = rowData["formattedPrice"] as NSString
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString = rowData["artworkUrl60"] as String

        cell.textLabel?.text = cellText
        cell.imageView?.image = UIImage(named: "Blank52")
        
        // Check our image cache for the existing key. This is just a dictionary of UIImages
        var image = self.imageCache[urlString]

        if( image == nil ) {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: urlString)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if (error == nil) {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    cellToUpdate.imageView?.image = image
                }
            })
        }
        cell.detailTextLabel?.text = formattedPrice
        return cell
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tableData = resultsArr
            self.appsTableView!.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the row data for the selected row
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        var name: String = rowData["trackName"] as String
        var formattedPrice: String = rowData["formattedPrice"] as String
        
        var alert: UIAlertView = UIAlertView()
        alert.title = name
        alert.message = formattedPrice
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
}

