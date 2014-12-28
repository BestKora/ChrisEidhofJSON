//
//  ViewController.swift
//  CrisEidnof
//
//  Created by Tatiana Kornilova on 8/17/14.
//  Copyright (c) 2014 Tatiana Kornilova. All rights reserved.
//

import UIKit


class ViewController: UITableViewController {
    
    var places :[Place]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()

    }

// MARK: - GetData
    
        func getData() {
            
        let urlPlaces  = FlickrFetcher.URLforTopPlaces()
        Get.jsonRequest(urlPlaces) {d in
//----   С использованием дополнительных pipe операторов извлечения словаря и массива ----- 
             self.places = d |> "places" ||> "place" >>> {join($0.map(Place.parsePlace))}
            
 /* 
//----   Как в статье -----
            self.places = d >>> {dictionary($0,"places")
                >>> { array($0, "place")
                    >>> { join($0.map(Place.parsePlace))
                    }
                }
            }
*/
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                
                switch self.places {
                case .Some (let a):
                    println(a.reduce("", {$0 + $1.content + " " + $1.photoCount + "\n"} ))
                default: return ()
                }

            }
        }
        
    }
    
// MARK: - TableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "PlaceCell"
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = self.places.map{$0[indexPath.row]}?.content
        cell.detailTextLabel?.text = self.places.map{$0[indexPath.row]}?.photoCount


        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places?.count ?? 0
        }
    }
    


