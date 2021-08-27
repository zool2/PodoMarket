//
//  MySalesCompletedViewController.swift
//  PodoMarket
//
//  Created by 정주리 on 2020/07/07.
//  Copyright © 2020 zool2. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class MySalesCompletedViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    
    let db = Firestore.firestore()
    
    var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        getSalesCompletedPost()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getSalesCompletedPost() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let currentLoginID = appDelegate.userInfo.loginID
        
        // Post의 loginID가 자신의 것이고 salesStatus가 "판매완료"인 것만 가져옴.
        db.collection("Post").whereField("loginID", isEqualTo: currentLoginID).whereField("salesStatus", isEqualTo: "판매완료").getDocuments{ snapshot, error in
            
            if error != nil {
                print("Error getting documents: \(String(describing: error))")
            } else {
                for document in (snapshot?.documents)! {
                    print("판매완료데이타\(document.documentID) => \(document.data())")
                    let documentID = document.documentID
                    
                    let dataDic = document.data() as NSDictionary

                    let title = dataDic["title"] as? String ?? ""

                    let imageUrl1 = dataDic["imageUrl1"] as? String ?? "" // 저장된 image 세 개중에 첫번째만 가져옴.
                    let imageUrl2 = dataDic["imageUrl2"] as? String ?? ""
                    let imageUrl3 = dataDic["imageUrl3"] as? String ?? ""

                    let town = dataDic["town"] as? String ?? ""

                    let category = dataDic["category"] as? String ?? ""

                    let price = dataDic["price"] as? String ?? ""
                    
                    let uploadTime = dataDic["uploadTime"] as? String ?? ""

                    let loginID = dataDic["loginID"] as? String ?? ""

                    let explanation = dataDic["explanation"] as? String ?? ""

                    let nickname = dataDic["nickname"] as? String ?? ""

                    let uploadTimeInt: UInt?
                    uploadTimeInt = UInt(uploadTime)
                    
                    var product = Product()
                    
                    product.documentID = documentID
                    product.imageUrl1 = imageUrl1
                    product.imageUrl2 = imageUrl2
                    product.imageUrl3 = imageUrl3
                    product.town = town
                    product.title = title
                    product.price = price
                    product.category = category
                    product.explanation = explanation
                    product.nickname = nickname
                    product.loginID = loginID
                    product.uploadTimeInt = uploadTimeInt
                    product.uploadTime = uploadTime

                    self.products.append(product)
                }
                self.checkingPostCount()
                self.tableView.reloadData()
            }
        }
        
    }
    
    func checkingPostCount() {
        if self.products.count == 0 {
            self.backgroundView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
}

extension MySalesCompletedViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "salesCompletedCell", for: indexPath) as! HomeTableViewCell

        let product = self.products[indexPath.row]
        
        let productDic = product.getDict()

        cell.imageProduct.layer.cornerRadius = 5
        cell.imageProduct.sd_setImage(with: URL(string: productDic["imageUrl1"]! as! String))
        cell.labelTitle.text = "\(productDic["title"]!)"
        cell.labelPrice.text = "\(productDic["price"]!)원"
        cell.labelUploadTime.text = productDic["uploadTime"] as? String
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController

        let salesCompletedData = self.products[indexPath.row]

        postVC?.documentID = salesCompletedData.documentID!

        self.navigationController?.pushViewController(postVC!, animated: true)
    }
}
