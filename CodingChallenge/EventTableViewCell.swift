//
//  EventTableViewCell.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextLabel: UILabel?
    @IBOutlet weak var performerImageView: UIImageView?
    @IBOutlet weak var favoriteImageView: UIImageView?
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var dateTimeLabel: UILabel?
    
    weak var event: Event?
    
    public func configureWithEvent(_ event: Event){
        self.event = event
        self.titleTextLabel?.text = self.event?.title
        self.locationLabel?.text = self.event?.venue_name
        self.dateTimeLabel?.text = self.event?.datetime_local?.toPrettyDateString()
        
        let transformer = SDImageRoundCornerTransformer.init(radius: 12.0, corners: SDRectCorner.allCorners, borderWidth: 1.0, borderColor: UIColor.black)
        self.performerImageView?.sd_setImage(with: self.event?.imageUrl(), placeholderImage: UIImage(named: "placeholder"), context: [.imageTransformer: transformer])
        
        self.configureFavoritesImage(self.event!.favorite)
    }
    
    func configureFavoritesImage(_ isFavorite:Bool) {
        
        if (isFavorite) {
            let image = UIImage.fontAwesomeIcon(name: .heart, style: .solid, textColor: UIColor.redFavorite(), size: CGSize(width: 30, height: 30), backgroundColor: UIColor.clear, borderWidth: 2, borderColor: UIColor.white).withRenderingMode(.alwaysOriginal)
            
            self.favoriteImageView?.image = image
            self.favoriteImageView?.isHidden = false
        } else {
            self.favoriteImageView?.isHidden = true
        }
        
        
    }
    
}
