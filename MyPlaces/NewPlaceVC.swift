//
//  NewPlaceVC.swift
//  MyPlaces
//
//  Created by cherepanov92 on 26.10.2022.
//

import UIKit

class NewPlaceVC: UITableViewController {
    
    var currentPlace: Place?
    var imageIsChanged = false
    
    @IBOutlet var testTableView: UITableView!
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        saveBtn.isEnabled = false
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        setupEditScreen()
        
        testTableView.delegate = self
        testTableView.dataSource = self
    }
    
    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = UIImage(named:"cameraIcon")
            let photoIcon = UIImage(named:"photoIcon")
            
            let actionSheet = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Камера", style: .default) { _ in
                self.chooseImagePiker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Фото", style: .default) { _ in
                self.chooseImagePiker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    func savePlace() {
        var image: UIImage?
        
        if imageIsChanged {
            image = imageOfPlace.image
        } else {
            image = UIImage(named: "imagePlaceholder")
        }
        
        let imageData = image?.pngData()
              
        let newPlace = Place(
            name: nameTextField.text!,
            location: locationTextField.text,
            type: typeTextField.text,
            imageData: imageData
        )
        if currentPlace != nil {
            try! realm.write({
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
            })
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            imageOfPlace.image = image
            imageOfPlace.contentMode = .scaleAspectFill
            
            nameTextField.text = currentPlace?.name
            typeTextField.text = currentPlace?.type
            locationTextField.text = currentPlace?.location
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveBtn.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        //dismiss(animated: <#T##Bool#>)
    }
}

// MARK: Text field delegate

extension NewPlaceVC: UITextFieldDelegate {
    // Скрываю клавиатуру по нажатию на Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldDidChange () {
        if nameTextField.text?.isEmpty == false {
            saveBtn.isEnabled = true
        } else {
            saveBtn.isEnabled = false
        }
    }
}

// MARK: work with image
extension NewPlaceVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePiker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePiker = UIImagePickerController()
            imagePiker.delegate = self
            imagePiker.allowsEditing = true
            imagePiker.sourceType = source
            present(imagePiker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}
