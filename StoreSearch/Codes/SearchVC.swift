//
//  ViewController.swift
//  StoreSearch
//
//  Created by IssacCZ on 11/23/15.
//  Copyright © 2015 Issac. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var landscapeVC: LandscapeVC?
    let search = Search()
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
        
        searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from the iTunes Store. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performSearch()
    }
    
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearchForText(searchBar.text!, category: category, complete: {
                success in
                if !success {
                    self.showNetworkError()
                }
                
                self.tableView.reloadData()
            })
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if case .Results(let list) = search.state {
                let detailVC = segue.destinationViewController as! DetailVC
                let indexPath = sender as! NSIndexPath
                let searchResult = list[indexPath.row]
                detailVC.searchResult = searchResult
            }
        }
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        switch newCollection.verticalSizeClass {
        case .Compact:
            showwLandscapeVCWithCoordinator(coordinator)
        case .Regular, .Unspecified:
            hideLandspaceVCWithCoordinator(coordinator)
        }
    }
    
    func showwLandscapeVCWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        precondition(landscapeVC == nil)
        landscapeVC = storyboard!.instantiateViewControllerWithIdentifier("LandscapeVC") as? LandscapeVC
        if let controller = landscapeVC {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animateAlongsideTransition({ (_) -> Void in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                }, completion: { (_) -> Void in
                    controller.didMoveToParentViewController(self)
            })
        }
    }
    
    func hideLandspaceVCWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMoveToParentViewController(nil)
            
            coordinator.animateAlongsideTransition({ (_) -> Void in
                controller.view.alpha = 0
                }, completion: { (_) -> Void in
                    controller.view.removeFromSuperview()
                    controller.removeFromParentViewController()
                    self.landscapeVC = nil
            })
        }
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .NotSearchedYet:
            return 0
        case .Loading, .NoResults:
            return 1
        case .Results(let list):
            return list.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch search.state {
        case .NotSearchedYet:
            fatalError("Should never get here")
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .NoResults:
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            
        case .Results(let list):
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configureForSearchResult(searchResult)
            return cell
        }
    }
}

extension SearchVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch search.state {
        case .NoResults, .NotSearchedYet, .Loading:
            return nil
        case .Results:
            return indexPath
        }
    }
}