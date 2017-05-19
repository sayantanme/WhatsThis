//
//  ViewController.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 11/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import UIKit
import VisualRecognitionV3

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        doVisualRecog()
    }
    
    func doVisualRecog(){
        let apiKey = "fa1080e2f88c514b7684cadbdc21b8fca9d494a5"
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let version = formatter.string(from: date)
        let visualRecog = VisualRecognition(apiKey: apiKey, version: version)
        
        let url = "https://firebasestorage.googleapis.com/v0/b/blahblah-eb407.appspot.com/o/message-Images%2FWDkOZ3N1ObTyPvizp4vGSanjpgY2%2F512554310.482522?alt=media&token=6c685d53-b0d1-4331-a9ef-dd691a2f143d"
        _ = {(error:Error) in print(error)}
        visualRecog.classify(image: url) { (classifiedImages) in
            print(classifiedImages)
        }
        visualRecog.detectFaces(inImage: url) { (imageFaces) in
            print(imageFaces)
        }
        //visualRecog.createClassifier(withName: <#T##String#>, positiveExamples: <#T##[PositiveExample]#>, negativeExamples: <#T##URL?#>, failure: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>, success: <#T##(Classifier) -> Void#>)
        
        //visualRecog.get
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

