//
//  ViewController.swift
//  Client
//
//  Created by Cheng Sun on 4/16/19.
//  Copyright © 2019 EF. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


private let BASE_URL = "http://127.0.0.1:8080/api"

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var token: String?
    var sections = [UserModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func Login(_ sender: UIButton) {
        let pwd = "123456"
        let username = "Genie"
        let url = BASE_URL + "/login"
        let params = ["username": username, "pwd": pwd]
        
        AF.request(url, method: .post, parameters: params).responseJSON { (DataResponse) in
            print(DataResponse)
            
            let value = DataResponse.value
            let json = JSON(value as Any)
            print(json["data"]["token"])
            self.token = json["data"]["token"].string
            
            // download profile
            self.profile((Any).self)
        }
    }
    
    @IBAction func profile(_ sender: Any) {

        let url = BASE_URL + "/profile"
        let params = ["token": self.token]
        
        AF.request(url, method: .post, parameters: params).responseJSON { (DataResponse) in
            print(DataResponse)
            
            let value = DataResponse.value
            let json = JSON(value as Any)
 
            let data = json["data"]
            self.sections = (data.arrayObject?.compactMap({
                UserModel.deserialize(from: $0 as? Dictionary)
            }))!
            
            self.tableView.reloadData()
        }
    }
    
    private func downloadPhoto(_ path: String , comBlock: @escaping (UIImage) -> Void) {
        let url = BASE_URL + "/photo"
        let params = ["path": path]
        
        AF.request(url, method: .get, parameters: params).responseData { (DataResponse) in
            print(DataResponse)
            
            guard let imageData = DataResponse.value as? Data else {
                return
            }
            

            if let im = UIImage(data: imageData) {
                comBlock(im)
            }
        }
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let userDto = sections[indexPath.row]
        cell.textLabel?.text = userDto.name
        cell.detailTextLabel?.text = userDto.sex
        cell.imageView?.layer.cornerRadius = 15
        cell.imageView?.layer.masksToBounds = true
        
        let path = Bundle.main.path(forAuxiliaryExecutable: "/Users/admin/Desktop/swift server/PerfectHttp_DB/Server/home1.jpg")
        cell.imageView?.image = UIImage(contentsOfFile: path!) //占位图

        self.downloadPhoto(userDto.portrait, comBlock: { (image) in
            cell.imageView?.image = image
         })
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections.count
    }
}

