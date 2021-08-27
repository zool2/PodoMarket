
import UIKit
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import Toast_Swift

class MyWishListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var labelNotification: UILabel!
    
    let db = Firestore.firestore()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        getWishPost()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btnBackTapped(_ sender: Any) { self.navigationController?.popViewController(animated: true)
    }

    func getWishPost() { // WishPost에 저장된 loginID 불러옴
        
        products.removeAll()
        
        let myLoginID = appDelegate.userInfo.loginID
        
        // userLoginID와 일치하는 loginID만 가져옴
        db.collection("WishPost")
            .whereField("myLoginID", isEqualTo: myLoginID)
            .getDocuments { snapshot, error in
                
                if error != nil {
                    print("Error getting documents: \(String(describing: error))")
                } else {
                    for document in (snapshot?.documents)! {
                        print("\(document.documentID) => \(document.data())")
                        
                        let wishDocumentID = document.documentID
                        
                        let dataDic = document.data() as NSDictionary

                        let documentID = dataDic["documentID"] as? String ?? ""
                        let title = dataDic["title"] as? String ?? ""
                        let imageUrl1 = dataDic["imageUrl1"] as? String ?? ""
                        let category = dataDic["category"] as? String ?? ""
                        let uploadTime = dataDic["uploadTime"] as? String ?? ""
                        let price = dataDic["price"] as? String ?? ""

                        let uploadTimeInt: UInt?
                        uploadTimeInt = UInt(uploadTime)!
                        
                        var product = Product()
                        
                        product.wishDocumentID = wishDocumentID
                        product.documentID = documentID
                        product.imageUrl1 = imageUrl1
                        product.title = title
                        product.price = price
                        product.category = category
                        product.uploadTimeInt = uploadTimeInt
                        product.uploadTime = uploadTime

                        self.products.append(product)
                    }
                    self.checkingPostCount() // 상품개수확인 0개면 테이블뷰 숨김
                    self.products.sort { $0.uploadTime! > $1.uploadTime! }
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

extension MyWishListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishListCell", for: indexPath) as! HomeTableViewCell
        
        let product = self.products[indexPath.row]
        
        let productDic = product.getDict()
        
        cell.imageProduct.layer.cornerRadius = 5
        cell.imageProduct.sd_setImage(with: URL(string: productDic["imageUrl1"]! as! String))
        cell.labelTitle.text = productDic["title"] as? String
        cell.labelPrice.text = "\(productDic["price"]!)원"
        cell.labelUploadTime.text = productDic["uploadTime"] as? String
        cell.wishDocumentID = productDic["wishDocumentID"] as? String
        
        return cell
    }
    
    // 테이블뷰 행 스와이프 삭제
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let product = self.products[indexPath.row]
            // products에 저장된 해당 행의 product 구조체 가져옴.
            // getDic할 필요 없이 바로 "product.wishDocumentID"가져와서 해당 문서 삭제하면 됨.
            db.collection("WishPost").document( product.wishDocumentID!).delete() { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    self.view.makeToast("관심목록에서 삭제되었습니다!",
                    duration: 2,
                    point: CGPoint(x: 207, y: 300),
                    title: nil,
                    image: nil,
                    style: .init(),
                    completion: nil)
                    self.getWishPost()
                }
            }
        }
    }
    
    // 행 터치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController
        
        let product = self.products[indexPath.row]
        let productDic = product.getDict()

        postVC?.documentID = productDic["documentID"]! as! String

        self.navigationController?.pushViewController(postVC!, animated: true)
    }
    
    
}
