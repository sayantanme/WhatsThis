//
//  TrainedImagesVC.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 21/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import UIKit
import CoreData

class TrainedImagesVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblTrainedItems: UITableView!
    var trainedItems : [NSManagedObject] = []
    var trainName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("Pull To Refresh", comment: "Pull to Refresh")
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self, action: #selector(TrainedImagesVC.fetchData), for: .valueChanged)
        tblTrainedItems.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func askWatson(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "AskWatson", sender: self)
    }
    @IBAction func trainWatsonTapped(_ sender: UIButton) {
        print("trainWatson")
        let alertC = UIAlertController(title: "What do you want to train?", message: "Enter Name", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) { (alert) in
            let txtField = alertC.textFields![0] as UITextField
            self.trainName = txtField.text
            self.performSegue(withIdentifier: "ChooseImagesSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertC.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Name"
        }
        
        alertC.addAction(doneAction)
        alertC.addAction(cancelAction)
        present(alertC, animated: true, completion: nil)
    }
    
    func fetchData(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Training_Data")
        
        do {
            trainedItems = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        tblTrainedItems.reloadData()
        tblTrainedItems.refreshControl?.endRefreshing()
    }
    // MARK: - Table View Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainedItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainedItemsCell", for: indexPath) as? TrainedImagesCell
        let product = trainedItems[indexPath.row]
        cell?.txtTrainedName.text = product.value(forKeyPath: "name") as? String
        cell?.btnTrain.tag = indexPath.row
        cell?.btnTrain.addTarget(self, action: #selector(trainWatson(_:)), for: .touchUpInside)
//        if product.get {
//            <#code#>
//        }
        
        cell?.btnCheckStatus.layer.cornerRadius = 10.0
        cell?.btnCheckStatus.layer.masksToBounds = true
        cell?.btnCheckStatus.layer.borderWidth = 1.0
        cell?.btnCheckStatus.tag = indexPath.row
        cell?.btnCheckStatus.layer.borderColor = UIColor.red.cgColor
        cell?.btnCheckStatus.addTarget(self, action: #selector(checkStatus(_:)), for: .touchUpInside)
        
        if product.value(forKey: "isTrained") as! Bool {
            cell?.btnTrain.layer.cornerRadius = 10.0
            cell?.btnTrain.layer.masksToBounds = true
            cell?.btnTrain.layer.borderWidth = 1.0
            cell?.btnTrain.layer.borderColor = UIColor.red.cgColor
        }else{
            cell?.btnTrain.layer.cornerRadius = 10.0
            cell?.btnTrain.layer.masksToBounds = true
            cell?.btnTrain.layer.borderWidth = 1.0
            cell?.btnTrain.layer.borderColor = UIColor(red: 36/255, green: 169/255, blue: 246/255, alpha: 1).cgColor
            //24A9F6
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete hit")
        }
    }
    
    
    //MARK: - Watson actions

    func trainWatson(_ sender: UIButton){
        let trainedItem = trainedItems[sender.tag]
        let visReg = VisualRecog()
        let posUrl = URL(string: trainedItem.value(forKey: "positivePath") as! String)
        let negUrl = URL(string: trainedItem.value(forKey: "negativePath") as! String)
        let classifierName = trainedItem.value(forKey: "name") as! String
        
        visReg.doVisualRecog(positiveUrl: posUrl, negativeUrl: negUrl, classifierName: classifierName)
        print("\(sender.tag) - \(trainedItem.value(forKey: "positivePath")!):\(trainedItem.value(forKey: "negativePath")!)")
        //print(sender.tag)
    }
    
    
    func checkStatus(_ sender: UIButton){
        let trainedItem = trainedItems[sender.tag]
        let visReg = VisualRecog()
        let classifierName = trainedItem.value(forKey: "name") as! String
        visReg.getClassifierStatus(classifierName: classifierName)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhotosViewCVC {
            let dest = segue.destination as! PhotosViewCVC
            dest.trainingName = trainName
        }
    }
    

}
