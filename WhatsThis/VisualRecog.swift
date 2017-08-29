//
//  VisualRecog.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 24/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import Foundation
import VisualRecognitionV3
import CoreData

class VisualRecog {
    func doVisualRecog(positiveUrl:URL?, negativeUrl:URL?, classifierName:String?) {
        print("in visual recog")
        
        let apiKey = "fa1080e2f88c514b7684cadbdc21b8fca9d494a5"
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let version = formatter.string(from: date)
        let visualRecog = VisualRecognition(apiKey: apiKey, version: version)
        let postiveExample = PositiveExample(name: classifierName!, examples: positiveUrl!)
        
        visualRecog.createClassifier(withName: classifierName!, positiveExamples: [postiveExample], negativeExamples: negativeUrl, failure: { (error) in
            print(error.localizedDescription)
        }) { (posClass) in
            print(posClass)
            var model = self.fetchRecord(name: classifierName!)
            let t_Data = model[0] as! Training_Data
            t_Data.setValue(posClass.classifierID, forKey: "classifierID")
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
    }
    
    func getClassifierStatus(classifierName: String?) {
        
        var model = fetchRecord(name: classifierName!)
        
        if let trainData = model[0] as? Training_Data {
            let apiKey = "fa1080e2f88c514b7684cadbdc21b8fca9d494a5"
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let version = formatter.string(from: date)
            let visualRecog = VisualRecognition(apiKey: apiKey, version: version)
            
            //        visualRecog.getClassifier(withID: classifierName!) { (classifier) in
            //            print(classifier)
            //        }
            
//            deleteAllClaffiers()
            
            if trainData.classifierID != nil {
                visualRecog.getClassifier(withID: trainData.classifierID!, failure: { (error) in
                    print(error.localizedDescription)
                }) { (classifier) in
                    print(classifier)
                }
            }
        }
    }
    
    func deleteAllClaffiers(){
        let apiKey = "fa1080e2f88c514b7684cadbdc21b8fca9d494a5"
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let version = formatter.string(from: date)
        let visualRecog = VisualRecognition(apiKey: apiKey, version: version)
        visualRecog.getClassifiers(success: { (classifiers) in
            print(classifiers.count)
            for classifier in classifiers {
                visualRecog.deleteClassifier(withID: classifier.classifierID)
            }
        })
    }
    
    func getImageDetailsbyClassifiers(url:String,image:UIImage, onComplete: @escaping ([ClassifierResults]) -> ()){
        let apiKey = "fa1080e2f88c514b7684cadbdc21b8fca9d494a5"
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let version = formatter.string(from: date)
        let visualRecog = VisualRecognition(apiKey: apiKey, version: version)
//        visualRecog.classify(image: url, owners: ["me"], classifierIDs:["watsson_2036985945"], threshold: 0.0, language: "en", failure: { (error) in
//            print(error.localizedDescription)
//        }) { (classifiedImages) in
//            print(classifiedImages.images)
//        }
        
        visualRecog.classify(image: url) { (classifiedImages) in
            onComplete((classifiedImages.images.first?.classifiers)!)
        }
    }
    
    fileprivate func fetchRecord(name:String) -> [NSManagedObject]{
        var trainedItems : [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return trainedItems
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Training_Data")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do{
            trainedItems = try managedContext.fetch(fetchRequest)
        }catch{
            print(error)
        }
        return trainedItems
    }
}
