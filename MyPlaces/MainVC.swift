//
//  MainVC.swift
//  MyPlaces
//
//  Created by cherepanov92 on 25.10.2022.
//

import UIKit
import RealmSwift

class MainVC: UITableViewController {
    
    var places: Results<Place>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place = places[indexPath.row]
        
        cell.imageOfPlace?.image = UIImage(data: place.imageData!)
        
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.width / 2
        cell.imageOfPlace?.clipsToBounds = true
        
        cell.nameLabel?.text = place.name
        
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type

        return cell
    }
    
    // MARK: - Table view deligate
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//        let place = places[indexPath.row]
//        
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
//            StorageManager.deleteObject(place)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//        
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceVC else { return }
        newPlaceVC.saveNewPlace()
        tableView.reloadData()
    }

}
