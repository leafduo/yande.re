//
//  PostModel.swift
//  yande.re
//
//  Created by Zuyang Kou on 6/9/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

import UIKit

class PostModel: NSObject {
    var posts : YANPost[] = []
    var loading = false
    let limit = 20
    var page = 0

    func loadMorePost(completion: () -> ()) {
        assert(!loading)

        loading = true
        let params = ["limit": limit, "page": page + 1]
        YANHTTPSessionManager.sharedManager().GET("/post.json",
            parameters: params,
            success: { (task, response) -> () in
                self.loading = false
                for postDict : AnyObject in (response as NSArray) {
                    let post = MTLJSONAdapter.modelOfClass(YANPost.self, fromJSONDictionary: postDict as NSDictionary, error: nil) as YANPost
                    self.posts.append(post)
                }
                completion()
            },
            failure: nil)
    }
}
