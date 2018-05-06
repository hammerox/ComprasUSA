//
//  UIViewController+CoreData.swift
//  MauricioRamalhoCustodio
//
//  Created by user140087 on 5/5/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    func saveContext() {
        appDelegate.saveContext()
    }
    
    var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        return nf
    }
    
    func loadProducts() -> NSFetchedResultsController<Product> {
        let request : NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "price", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func loadStates() -> NSFetchedResultsController<State> {
        let request : NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "taxRate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
