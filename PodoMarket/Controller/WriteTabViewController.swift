//
//  WriteTabViewController.swift
//  PodoMarket
//
//  Created by 주리 on 9/2/19.
//  Copyright © 2019 zool2. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class WriteTabViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var buttonGoWrite: UIButton!
    
    var documentID: String = ""
    var nickname: String = ""
    var loginID: String = ""
    var imageURL: String = ""
    
    let db = Firestore.firestore()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingViewLayout()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkingLoginStatus() // 안에 getPost 있음.
    }
    
    func checkingLoginStatus() {
        let myLoginID = appDelegate.userInfo.loginID
        if myLoginID == "" {
            backgroundView.isHidden = false
        } else {
            backgroundView.isHidden = true
            self.getPost()
        }
    }
        
    func getPost() {
        products.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let currentLoginID = appDelegate.userInfo.loginID
        
        // currentLoginID와 일치하는 loginID만 가져옴
        db.collection("Post")
            .whereField("loginID", isEqualTo: currentLoginID).whereField("salesStatus", isEqualTo: "")
            .getDocuments{ snapshot, error in
            
            if error != nil {
                print("Error getting documents: \(String(describing: error))")
            } else {
                for document in (snapshot?.documents)! {
                    print("\(document.documentID) => \(document.data())")
                    let documentID = document.documentID
                    
                    let dataDic = document.data() as NSDictionary

                    let title = dataDic["title"] as? String ?? ""

                    let imageUrl1 = dataDic["imageUrl1"] as? String ?? "" // 저장된 image 세 개중에 첫번째만 가져옴.
                    let imageUrl2 = dataDic["imageUrl2"] as? String ?? ""
                    let imageUrl3 = dataDic["imageUrl3"] as? String ?? ""

                    let town = dataDic["town"] as? String ?? ""

                    let category = dataDic["category"] as? String ?? ""

                    let price = dataDic["price"] as? String ?? ""

                    let loginID = dataDic["loginID"] as? String ?? ""

                    let explanation = dataDic["explanation"] as? String ?? ""

                    let nickname = dataDic["nickname"] as? String ?? ""
                    
                    let uploadTime = dataDic["uploadTime"] as? String ?? ""
                    
                    // 업로드시간 string에서 int로 변환하고 구조체 저장
                    // ConvertUploadTimeInt()
                    let uploadTimeInt: UInt?
                    uploadTimeInt = UInt(uploadTime)!
                    print(uploadTimeInt!)
                    
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
                // uploadTimeInt
                // uploadTime의 숫자가 클수록 상단에 위치하게 정렬.
                self.products.sort { $0.uploadTime! > $1.uploadTime! }
                self.tableView.reloadData()
            }
        }
    }
    
    func settingViewLayout() {
        topView.layer.addBorder([.bottom], color: UIColor.lightGray, width: 0.5)
    }
    
}

extension WriteTabViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WriteTabViewCell", for: indexPath) as! HomeTableViewCell
        
        let product = self.products[indexPath.row] // postArray에 저장된 하나의 PostData(Struct)를 저장함.
        let productDic = product.getDict()
        
        cell.imageProduct.sd_setImage(with: URL(string:productDic["imageUrl1"]! as! String))
        cell.imageProduct.layer.cornerRadius = 5
        cell.labelTitle.text = productDic["title"] as? String
        cell.labelUploadTime.text = "\(productDic["uploadTime"]!)"
        cell.labelPrice.text = "\(productDic["price"]!)원"
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController
        
        let postdata = self.products[indexPath.row]
        let postdic = postdata.getDict()
        
        postVC?.documentID = postdic["documentID"]! as! String

        self.navigationController?.pushViewController(postVC!, animated: true)
    }
}
