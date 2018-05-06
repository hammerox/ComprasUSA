//
//  ResultViewController.swift
//  MauricioRamalhoCustodio
//
//  Created by user140087 on 5/5/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var dolarValue: UILabel!
    @IBOutlet weak var realValue: UILabel!
    var products : NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        products = loadProducts()
//        products.delegate = self
        do {
            try products.performFetch()
            calculateCost()
        } catch {
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func calculateCost() {
        guard let prods = products.fetchedObjects else {
            dolarValue.text = "???"
            realValue.text = "???"
            return
        }
        
        let dolarSum = prods.map { (p) -> Decimal in
            p.price! as Decimal
        }.reduce(0, +)
        
        dolarValue.text = numberFormatter.string(from: NSDecimalNumber(decimal: dolarSum))
        
        let dolarRate = Decimal(string: UserDefaults.standard.string(forKey: "dolar_value")!)!
        let iofRate = Decimal(string: UserDefaults.standard.string(forKey: "iof_value")!)!
        
        let realSum = prods.map { (p) -> Decimal in
            let price = (p.price! as Decimal)
            let taxValue = price * ((p.state!.taxRate! as Decimal) / 100)
            let iofValue = (price + taxValue) * iofRate / 100
            if p.creditCard {
                return (price + taxValue + iofValue) * dolarRate
            } else {
                return (price + taxValue) * dolarRate
            }
        }.reduce(0, +)
        
        realValue.text = numberFormatter.string(from: NSDecimalNumber(decimal: realSum))
    }
    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        calculateCost()
//    }

}
