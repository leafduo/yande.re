//
//  PostListTableViewController.swift
//  yande.re
//
//  Created by Zuyang Kou on 6/9/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    let postModel = PostModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "reloadData", forControlEvents: .ValueChanged)

        postModel.loadMorePost {
            self.tableView.reloadData()
        }
    }

    func reloadData() {
        refreshControl.beginRefreshing()
        postModel.reloadData {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return postModel.posts.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostListTableViewCell", forIndexPath: indexPath) as PostListTableViewCell
        cell.post = postModel.posts[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let post = postModel.posts[indexPath.row]
        return post.jpegSize.height * 320 / post.jpegSize.width
    }

    override func scrollViewDidScroll(scrollView: UIScrollView!) {
        if postModel.loading {
            return
        }

        if scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height - 640 {
            self.postModel.loadMorePost {
                self.tableView.reloadData()
            }
        }
    }

}
