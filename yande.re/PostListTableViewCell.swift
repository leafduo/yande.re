//
//  PostListTableViewCell.swift
//  yande.re
//
//  Created by Zuyang Kou on 6/12/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

import UIKit

class PostListTableViewCell: UITableViewCell, UIActionSheetDelegate {
    @IBOutlet var postImageView: UIImageView
    var post: YANPost? {
    didSet {
        postImageView.setImageWithURL(post!.sampleURL, placeholderImage: nil, options: .RetryFailed | .ProgressiveDownload)
    }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        postImageView.contentMode = .ScaleAspectFit

        let longPressGestureRecognizer = UILongPressGestureRecognizer()
        self.addGestureRecognizer(longPressGestureRecognizer)
        longPressGestureRecognizer.addTarget(self, action: "didLongPress:")
    }

    @IBAction func didLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            let actionSheet = UIActionSheet()
            actionSheet.addButtonWithTitle("Save Photo")
            actionSheet.addButtonWithTitle("Cancel")
            actionSheet.cancelButtonIndex = 1
            actionSheet.delegate = self
            actionSheet.showInView(UIApplication.sharedApplication().keyWindow)
        }
    }

    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            let image = postImageView.image
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        default:
            break
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
