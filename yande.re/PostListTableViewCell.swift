//
//  PostListTableViewCell.swift
//  yande.re
//
//  Created by Zuyang Kou on 6/12/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

import UIKit

class PostListTableViewCell: UITableViewCell {
    @IBOutlet var postImageView: UIImageView
    var post: YANPost? {
    didSet {
        postImageView.setImageWithURL(post!.sampleURL, placeholderImage: nil, options: .RetryFailed | .ProgressiveDownload)
    }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        postImageView.contentMode = .ScaleAspectFit
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
