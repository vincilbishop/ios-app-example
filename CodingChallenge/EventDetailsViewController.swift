//
//  ViewController.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import UIKit
import FontAwesome_swift
import SDWebImage
import SugarRecord

class EventDetailsViewController: UIViewController {
    
    weak var event: Event?
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var performerImageView: UIImageView?
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var dateTimeLabel: UILabel?
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.titleLabel?.text = self.event?.title
        self.locationLabel?.text = self.event?.venue_name
        self.dateTimeLabel?.text = self.event?.datetime_local
        
        let transformer = SDImageRoundCornerTransformer.init(radius: 12.0, corners: SDRectCorner.allCorners, borderWidth: 0.5, borderColor: UIColor.black)
        self.performerImageView?.sd_setImage(with: self.event?.imageUrl(), placeholderImage: UIImage(named: "placeholder"), context: [.imageTransformer: transformer])
        
        
        
        self.configureFavoritesButton(self.event!.favorite)
        
    }
    
    func configureFavoritesButton(_ isFavorite:Bool) {
        
        var favortiesButtonColor = UIColor.gray
        
        if (isFavorite) {
            favortiesButtonColor = UIColor.redFavorite()
        }
        
        let image = UIImage.fontAwesomeIcon(name: .heart, style: .solid, textColor: favortiesButtonColor, size: CGSize(width: 40, height: 40), backgroundColor: UIColor.clear, borderWidth: 0, borderColor: UIColor.clear).withRenderingMode(.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(favoritePressed(sender:)))
    }

    @objc func favoritePressed(sender: UIBarButtonItem) {
        
        try! AppData.shared.db.operation { [unowned self] (context, save) throws -> Void in
         
            let identifier = self.event!.identifier
            let events: [Event] = try! context.fetch(FetchRequest<Event>().filtered(with: NSPredicate(format: "identifier == %@", NSNumber(value: identifier))))
            
            let contextEvent = events.first!
            
            contextEvent.favorite = !self.event!.favorite

            save()
            
            self.configureFavoritesButton(contextEvent.favorite)
            
            self.event = contextEvent
            
        }
        
    }
    

}

