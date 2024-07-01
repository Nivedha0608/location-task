//
//  CustomInfoWindow.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import UIKit

class CustomInfoWindow: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    //    @IBOutlet weak var snippetLabel: UILabel!

    static func instanceFromNib() -> CustomInfoWindow {
        return UINib(nibName: "CustomInfoWindow", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CustomInfoWindow
        
    }
}
