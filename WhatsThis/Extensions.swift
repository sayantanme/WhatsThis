//
//  Extensions.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 19/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func addBlur(){
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
    func loadImageFromImageUrlFromCache(url:String){
        
        self.image = nil
        HUD.flash(.progress)
        if let cachedImage = imageCache.object(forKey: url as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else{
                print(error?.localizedDescription ?? "error from loadImageFromImageUrlFromCache")
                return
            }
            DispatchQueue.main.async {
                if let downloadImage = UIImage(data: data!){
                    imageCache.setObject(downloadImage, forKey: url as AnyObject)
                    self.image = downloadImage
                }
                HUD.hide()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()
    }
}
