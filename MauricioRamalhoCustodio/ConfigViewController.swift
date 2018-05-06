//
//  ConfigViewController.swift
//  MauricioRamalhoCustodio
//
//  Created by Usuário Convidado on 05/05/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class ConfigViewController: UIViewController {
    

    @IBOutlet weak var stateTableView: UITableView!
    @IBOutlet weak var dolarText: UITextField!
    @IBOutlet weak var iofText: UITextField!
    var states : NSFetchedResultsController<State>!
    lazy var numberFormatter : NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        return nf
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        stateTableView.delegate = self
        stateTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let request : NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "taxRate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        states = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        states.delegate = self
        do {
            try states.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    // MARK: - Table view data source
    
    @objc func defaultsChanged() {
        if let dolarValue = UserDefaults.standard.string(forKey: "dolar_value") {
            dolarText.text = dolarValue
        }
        
        if let iofValue = UserDefaults.standard.string(forKey: "iof_value") {
            iofText.text = iofValue
        }
    }
    
    @IBAction func dolarValueChanged(_ sender: Any) {
        UserDefaults.standard.set(dolarText.text, forKey: "dolar_value")
    }
    
    @IBAction func iofValueChanged(_ sender: UITextField) {
        UserDefaults.standard.set(iofText.text, forKey: "iof_value")
    }
    
    @IBAction func addState(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Adicionar Estado", message: "", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you
        alert.addTextField { (textField) in
            textField.placeholder = "Nome do estado"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Imposto"
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let stateName = alert!.textFields![0].text!
            let taxValue = alert!.textFields![1].text!
            
            if stateName.isEmpty {
                self.showAlert(message: "Preencha o nome do estado")
                return
            }
            
            guard let taxRate = Decimal(string: taxValue) else {
                self.showAlert(message: "Valor do imposto invalido")
                return
            }
            
            let newState = State(context: self.context)
            newState.name = stateName
            newState.taxRate = taxRate as NSDecimalNumber
            self.saveContext()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


class StateTableViewCell : UITableViewCell {
    @IBOutlet weak var stateName: UILabel!
    @IBOutlet weak var taxRate: UILabel!
    
}



extension ConfigViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        guard let data = states.fetchedObjects else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "Sua lista está vazia!"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            return 0
        }
        
        if data.count > 0 {
            self.stateTableView.separatorStyle = .singleLine
            self.stateTableView.backgroundView = nil
            return 1
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "Sua lista está vazia!"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let data = states.fetchedObjects {
            return data.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath) as! StateTableViewCell
        
        // Configure the cell...
        let selectedState = states.object(at: indexPath)
        
        cell.stateName.text = selectedState.name!
        cell.taxRate.text = numberFormatter.string(from: selectedState.taxRate!)
        
        return cell
    }
    
    
    //    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 100
    //    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        //let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        //let destination = storyboard.instantiateViewController(withIdentifier: "ProductView") as! ProductViewController
        //navigationController?.pushViewController(destination, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let selectedState = states.object(at: indexPath)
            context.delete(selectedState)
            tableView.reloadData()
        }
        
    }
}

extension ConfigViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        stateTableView.reloadData()
    }
}
