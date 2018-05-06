//
//  ProductViewController.swift
//  MauricioRamalhoCustodio
//
//  Created by Usuário Convidado on 23/04/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {
    
    
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var imagePicture: UIImageView!
    @IBOutlet weak var textState: UITextField!
    @IBOutlet weak var textPrice: UITextField!
    @IBOutlet weak var switchCreditCard: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    var product : Product?
    var states : NSFetchedResultsController<State>!
    
    var smallImage: UIImage!
    var pickerView : UIPickerView!
    var pickerSelectedRow: Int? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchStates()
        if let product = product {
            textName.text = product.name
            imagePicture.image = product.image as! UIImage
            textState.text = product.state?.name
            textPrice.text = String(describing: product.price!)
            switchCreditCard.setOn(product.creditCard, animated: false)
            saveButton.setTitle("Atualizar", for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchStates() {
        states = loadStates()
        states.delegate = self
        do {
            try states.performFetch()
        } catch {
            print(error.localizedDescription)
        }
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
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func updateProduct(_ sender: UIButton) {
        if inputsAreValid() {
            if product == nil {
                product = Product(context: context)
            }
            
            product!.name = textName.text
            product!.image = imagePicture.image
            let priceValue = Decimal(string: textPrice.text!)!
            product!.price = priceValue as NSDecimalNumber
            product!.state = states.object(at: IndexPath(row: pickerSelectedRow!, section: 0))
            product!.creditCard = switchCreditCard.isOn
            saveContext()
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func setState(_ sender: UITextField) {
        pickUp(textState)
    }
    
    
    func inputsAreValid() -> Bool {
        if let image = imagePicture.image {
            if image == UIImage(named: "Gift") {
                showAlert(message: "Imagem não definida")
                return false
            }
        }
        
        if textName.text!.isEmpty {
            showAlert(message: "Nome não preenchido")
            return false
        }
        
        findCurrentStateIndex()
        guard let selectedState = pickerSelectedRow else {
            showAlert(message: "O estado escolhido nao existe mais")
            return false
        }
        
        if textState.text!.isEmpty {
            showAlert(message: "Estado não preenchido")
            return false
        }
        
        if textPrice.text!.isEmpty {
            showAlert(message: "Preço não preenchido")
            return false
        }
        
        guard let priceValue = Decimal(string: textPrice.text!) else {
            self.showAlert(message: "Preco invalido")
            return false
        }
        
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        //Criando o objeto UIImagePickerController
        let imagePicker = UIImagePickerController()
        
        //Definimos seu sourceType através do parâmetro passado
        imagePicker.sourceType = sourceType
        
        //Definimos a MovieRegisterViewController como sendo a delegate do imagePicker
        imagePicker.delegate = self
        
        //Apresentamos a imagePicker ao usuário
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func pickUp(_ textField : UITextField){
        guard let data = states.fetchedObjects else {
            showAlert(message: "Não há estados")
            return
        }
        
        if (data.count > 0) {
            showPickerView(textField)
        } else {
            showAlert(message: "Não há estados")
        }
        
        
    }
    
    func showPickerView(_ textField : UITextField) {
        // UIPickerView
        self.pickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.backgroundColor = UIColor.white
        textField.inputView = self.pickerView
        
        findCurrentStateIndex()
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ProductViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ProductViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    func findCurrentStateIndex() {
        let currentIndex = states.fetchedObjects!.index { (state) -> Bool in
            state.name == textState.text!
            }?.hashValue
        
        if currentIndex != nil {
            pickerSelectedRow = currentIndex!
            self.pickerView?.selectRow(pickerSelectedRow!, inComponent: 0, animated: false)
        } else {
            pickerSelectedRow = nil
            self.pickerView?.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @objc func doneClick() {
        if pickerSelectedRow == nil { pickerSelectedRow = 0 }
        let selectedState = states.object(at: IndexPath(row: pickerSelectedRow!, section: 0))
        textState.text = selectedState.name
        textState.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        textState.resignFirstResponder()
    }
    
}


extension ProductViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imagePicture.image = smallImage
        dismiss(animated: true, completion: nil)
    }
}

extension ProductViewController : UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK:- PickerView Delegate & DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let count = states.fetchedObjects?.count else {
            return 0
        }
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let selectedState = states.object(at: IndexPath(row: row, section: 0))
        return selectedState.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelectedRow = row
    }
    
}

extension ProductViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pickerView?.reloadAllComponents()
    }
}
