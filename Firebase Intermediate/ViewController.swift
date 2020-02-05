//
//  ViewController.swift
//  Firebase Intermediate
//
//  Created by Rasyid Respati Wiriaatmaja on 05/02/20.
//  Copyright © 2020 rasyidrw. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tfNama: UITextField!
    @IBOutlet weak var tfAsal: UITextField!
    @IBOutlet weak var tableSiswa: UITableView!
    @IBOutlet weak var adBanner: GADBannerView!
    
    var ref = DatabaseReference()
    var siswa = [Siswa]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableSiswa.delegate = self
        tableSiswa.dataSource = self
        
        ref = Database.database().reference().child("dataSiswa")
        reloadDataSiswa()
        
        adBanner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        adBanner.rootViewController = self
        adBanner.load(GADRequest())
        
    }
    
    func reloadDataSiswa() {
        
        ref.observe(DataEventType.value) { (DataSnapshot) in
            
            if DataSnapshot.childrenCount > 0 {
                
                self.siswa.removeAll()
                
                for data in DataSnapshot.children.allObjects as! [DataSnapshot] {
                    
                    let dataSiswa = data.value as! [String : String]
                    let id = dataSiswa["id"]
                    let nama = dataSiswa["nama"]
                    let asal = dataSiswa["asal"]
                    
                    let sws = Siswa(id: id!, nama: nama!, asal: asal!)
                    self.siswa.append(sws)
                    self.tableSiswa.reloadData()
                    
                }
            }
        }
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        
        if tfNama.text == "" || tfAsal.text == "" {
            print("Jangan kosong")
        } else {
            
            let key = ref.childByAutoId().key
            
            let param = ["id" : key,
                         "nama" : tfNama.text,
                         "asal" : tfAsal.text]
            
            ref.child(key!).ref.setValue(param)
            
            tfNama.text = ""
            tfAsal.text = ""
            tfNama.becomeFirstResponder()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return siswa.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSiswa")
        
        cell?.textLabel?.text = siswa[indexPath.row].nama
        cell?.detailTextLabel?.text = siswa[indexPath.row].asal
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataSiswa = siswa[indexPath.row]
        let alert = UIAlertController(title: "Action", message: "Update / Delete", preferredStyle: .alert)
        let update = UIAlertAction(title: "Update", style: .default) { (UIAlertAction) in
            
            let id = dataSiswa.id
            let nama = alert.textFields![0].text
            let asal = alert.textFields![1].text
            
            let param = ["id" : id,
                         "nama" : nama,
                         "asal" : asal]
            
            self.ref.child(id!).setValue(param)
            
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            
            self.ref.child(dataSiswa.id!).removeValue()
            self.siswa.remove(at: indexPath.row)
            self.tableSiswa.reloadData()
        }
        
        alert.addTextField { (tfNama) in
            tfNama.text = dataSiswa.nama
        }
        
        alert.addTextField { (tfAsal) in
            tfAsal.text = dataSiswa.asal
        }
        
        alert.addAction(update)
        alert.addAction(delete)
        
        present(alert, animated: true, completion: nil)
    }
    
    
}

