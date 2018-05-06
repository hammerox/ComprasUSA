//
//  ConfigViewController.swift
//  MauricioRamalhoCustodio
//
//  Created by Usuário Convidado on 05/05/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    

    @IBOutlet weak var stateTableView: UITableView!
    @IBOutlet weak var dolarText: UITextField!
    @IBOutlet weak var iofText: UITextField!
    
    lazy var states : [State] = {
        var array: [State] = []
        let state1 = State(context: context)
        state1.name = "Sao Paulo"
        state1.taxRate = 7.01
        array.append(state1)
        
        let state2 = State(context: context)
        state2.name = "Rio de Janeiro"
        state2.taxRate = 12.01
        array.append(state2)
        return array
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        stateTableView.delegate = self
        stateTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        // Do any additional setup after loading the view.
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
            let taxField = alert!.textFields![1].text!
            let tuple: (String, Decimal) = (stateName, Decimal(string: taxField)!)
            
            let newState = State(context: self.context)
            newState.name = stateName
            newState.taxRate = Decimal(string: taxField)! as? NSDecimalNumber
            self.states.append(newState)
            self.stateTableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        // 4. Present the alert.
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
        if states.count > 0 {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
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
        return states.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath) as! StateTableViewCell
        
        // Configure the cell...
        
        cell.stateName.text = states[indexPath.row].name!
        cell.taxRate.text = String(describing: states[indexPath.row].taxRate!)
        
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
            states.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
    }
}
