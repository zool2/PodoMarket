//
//  PostingUserProfileViewController.swift
//  PodoMarket
//
//  Created by TJ on 09/09/2019.
//  Copyright © 2019 zool2. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class PostingUserProfileViewController: UIViewController {
    
    @IBOutlet weak var buttonLogOut: UIButton!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelNickname: UILabel!
    @IBOutlet weak var labelLoginID: UILabel!
    @IBOutlet weak var labelTown: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let db = Firestore.firestore()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var imageUser: UIImage = UIImage(named: "user.png")!
    
    var nickname: String = ""
    var loginID: String = ""
    
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width / 2
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setProfileImage()
        getProductData()

    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getProductData() {

        db.collection("Post")
            .whereField("loginID", isEqualTo: loginID)
            .getDocuments{ snapshot, error in
                
            if error != nil {
                print("Error getting documents: \(String(describing: error))")
            } else {
                for document in (snapshot?.documents)! {
                    print("\(document.documentID) => \(document.data())")

                    let dataDic = document.data() as NSDictionary
                    
                    let documentID = document.documentID
                    
                    let title = dataDic["title"] as? String ?? ""
                    let imageUrl1 = dataDic["imageUrl1"] as? String ?? ""
                    let imageUrl2 = dataDic["imageUrl2"] as? String ?? ""
                    let imageUrl3 = dataDic["imageUrl3"] as? String ?? ""
                    let town = dataDic["town"] as? String ?? ""
                    let category = dataDic["category"] as? String ?? ""
                    let price = dataDic["price"] as? String ?? ""
                    let loginID = dataDic["loginID"] as? String ?? ""
                    let explanation = dataDic["explanation"] as? String ?? ""
                    let nickname = dataDic["nickname"] as? String ?? ""
                    let uploadTime = dataDic["uploadTime"] as? String ?? ""
                    
                    let uploadTimeInt: UInt?
                    uploadTimeInt = UInt(uploadTime)
                    
                    var product = Product() // Product  Struct에 넣음.
                    
                    product.imageUrl1 = imageUrl1
                    product.imageUrl2 = imageUrl2
                    product.imageUrl3 = imageUrl3
                    product.title = title
                    product.price = price
                    product.category = category
                    product.explanation = explanation
                    product.nickname = nickname
                    product.loginID = loginID
                    product.documentID = documentID
                    product.uploadTimeInt = uploadTimeInt
                    product.uploadTime = uploadTime
                    
                    self.products.append(product)
                    self.labelNickname.text = nickname
                    self.labelTown.text = town
                    self.setProfileImage()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func setProfileImage() {
        
        let userRef = db.collection("users").document(self.loginID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {

                let usersDic = document.data()! as NSDictionary

                let imageProfileURL = usersDic["profileImageURL"] as? String ?? ""
                
                self.imageViewProfile.sd_setImage(with: URL(string: imageProfileURL))
            } else {
                print("이미지 없음.")
                self.imageViewProfile.image = self.imageUser // 기본 이미지 설정
            }
        }
    }
    
}

extension PostingUserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostingUserCell", for: indexPath) as! HomeTableViewCell
        
        let postdata = self.products[indexPath.row] // postArray에 저장된 하나의 PostData(Struct)를 저장함.
        let postdic = postdata.getDict()
        
        cell.imageProduct.layer.cornerRadius = 5
        cell.imageProduct.sd_setImage(with: URL(string:postdic["imageUrl1"]! as! String))
        cell.labelTitle.text = postdic["title"] as? String
        cell.labelPrice.text = "\(postdic["price"]!)원"
        cell.labelUploadTime.text = postdic["uploadTime"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // PostViewController로 데이타 전달하는 방식.
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController
        
        let postdata = self.products[indexPath.row]
        let postDic = postdata.getDict()
        print("postdic:")

        postVC?.documentID = postDic["documentID"]! as! String
        
        self.navigationController?.pushViewController(postVC!, animated: true)
    }
}
