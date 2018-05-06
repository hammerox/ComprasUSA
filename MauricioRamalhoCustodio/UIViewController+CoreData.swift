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
}
