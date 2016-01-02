//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by IssacCZ on 1/2/16.
//  Copyright © 2016 Issac. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL(url) { [weak self]
            (url, response, error) -> Void in
            if error == nil, let url = url, data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let strongSelf = self {
                        strongSelf.image = image
                    }
                })
            }
        }
        
        downloadTask.resume()
        return downloadTask
    }
}