//
//  ProductViewController.swift
//  MauricioRamalhoCustodio
//
//  Created by Usuário Convidado on 23/04/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {
    
    
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var imagePicture: UIImageView!
    @IBOutlet weak var textState: UITextField!
    @IBOutlet weak var textPrice: UITextField!
    @IBOutlet weak var switchCreditCard: UISwitch!
    var product : String?
    var imagePicker : UIImagePickerController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
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
    @IBAction func selectImage(_ sender: UIButton) {
        
    }
    
    @IBAction func updateProduct(_ sender: UIButton) {
        
        if let image = imagePicture.image {
            if image == UIImage(named: "Gift") {
                showAlert(message: "Imagem não definida")
                return
            }
        }
        
        if textName.text!.isEmpty {
            showAlert(message: "Nome não preenchido")
            return
        }
        
        if textState.text!.isEmpty {
            showAlert(message: "Estado não preenchido")
            return
        }
        
        if textPrice.text!.isEmpty {
            showAlert(message: "Preço não preenchido")
            return
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Formulário incompleto", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}


extension ProductViewController : UIImagePickerControllerDelegate {
    // IMPLEMENTAR PICKER CONTROLLER
}
