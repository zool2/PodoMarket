
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class HomeViewController: UIViewController,UIScrollViewDelegate {
 
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lableNickname: UILabel!
    @IBOutlet weak var lableTown1: UILabel!
    @IBOutlet weak var homeScrollView: UIScrollView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var lableTown2: UILabel!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var buttonLogIn: UIButton!
    
    let db = Firestore.firestore()

    var documentID: String = ""
    var loginID: String = ""
    var nickname: String = ""
    var imageProfileURL: String = ""
    var imgUser: UIImage = UIImage(named: "user.png")! // 비회원 이미지
    var townName: String = "" // 동네 변경시 여기에 저장하고 파이어베이스에서 일치하는 동네이름 가져옴.
    
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Commit Test")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        loginStatus() // login 상태에 따라 popupView 상태 달라짐
        settingHomeview()
        getProductsData()
    }
    
    @IBAction func popUpBackTapped(_ sender: Any) {
        backgroundView.isHidden = true
        popUpView.isHidden = true
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        backgroundView.isHidden = true
        popUpView.isHidden = true
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        self.navigationController?.pushViewController(signUpVC!, animated: true)
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        backgroundView.isHidden = true
        popUpView.isHidden = true
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController
        self.navigationController?.pushViewController(loginVC!, animated: true)
    }
    
    func settingHomeview() {
        self.navigationController?.isNavigationBarHidden = true
        
        homeScrollView.delegate = self
        homeTableView.dataSource = self
        homeTableView.delegate = self
        topView.layer.addBorder([.bottom], color: UIColor.lightGray, width: 0.5)
    }
    //MARK:- 포트폴리오 코드 로그인 상태에 따라 뷰 설정 설명.
    func loginStatus() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        loginID = appDelegate.userInfo.loginID
        
        if loginID == "" {
            presentPopupView()
            
            let townName = appDelegate.townSetting.town
            self.townName = townName
            lableTown1.text = townName
            lableTown2.text = townName
            
            self.lableNickname.text = "로그인"
            imageView.image = self.imgUser
        } else {
            noPopupView()
            
            let myTownName = appDelegate.userInfo.town
            self.townName = myTownName
            lableTown1.text = myTownName
            lableTown2.text = myTownName
            
            let nickname = appDelegate.userInfo.nickName
            let imageProfileURL = appDelegate.userInfo.imageProfileURL
            self.lableNickname.text = "\(nickname)"
            imageView.sd_setImage(with: URL(string:imageProfileURL))
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
        }
    }
    
    func presentPopupView() {
        popUpView.isHidden = false
        backgroundView.isHidden = false

        popUpView.layer.cornerRadius = 10
        popUpView.layer.borderColor = UIColor.lightGray.cgColor
        popUpView.layer.borderWidth = 1
        lableTown2.text = townName
        buttonSignUp.layer.cornerRadius = 10
        buttonLogIn.layer.cornerRadius = 10
    }
    
    func noPopupView() {
        popUpView.isHidden = true
        backgroundView.isHidden = true
    }
    
    func getProductsData() {
        
        products.removeAll()
        
        db.collection("Post")
            .whereField("town", isEqualTo: townName)
            .whereField("salesStatus", isEqualTo: "")
            .getDocuments{ (snapshot, error) in
                if error != nil {
                    print("문서를 가져오는 중 오류 발생: \(String(describing: error))")
                } else {
                    for document in snapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let documentID = document.documentID
                        let dataDic = document.data() as NSDictionary
                        
                        let imageUrl1 = dataDic["imageUrl1"] as? String ?? ""
                        let title = dataDic["title"] as? String ?? ""
                        let price = dataDic["price"] as? String ?? ""
                        let town = dataDic["town"] as? String ?? ""
                        let uploadTime = dataDic["uploadTime"] as? String ?? ""
                        let uploadTimeInt = self.convertUploadTime(uploadTime: uploadTime)
                        
                        var product = Product() // PostData  Struct에 집어넣음.
                        
                        product.imageUrl1 = imageUrl1
                        product.title = title
                        product.price = price
                        product.documentID = documentID
                        product.town = town
                        product.uploadTime = uploadTime
                        product.uploadTimeInt = uploadTimeInt
                        
                        self.products.append(product) // product Struct에 저장된 데이타를 products에 넣기.
                    }
                    
                    self.products.sort { $0.uploadTimeInt! > $1.uploadTimeInt! } // 최신순 정렬
                    self.homeTableView.reloadData()
                }
            }
        }
    // 최신순 정렬을 위해 Int로 변경함.
    func convertUploadTime(uploadTime: String) -> UInt {
        let stringUploadTime = uploadTime
        let uploadTimeInt: UInt = UInt(stringUploadTime)! // string에서 UInt로 다시 변환
        
        return uploadTimeInt
    }
        
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! HomeTableViewCell
        
        let product = self.products[indexPath.row] // postArray에 저장된 하나의 PostData(Struct)를 저장함.
        let productDic = product.getDict()
        
        cell.imageProduct.layer.cornerRadius = 5
        cell.imageProduct.sd_setImage(with: URL(string: productDic["imageUrl1"]! as! String))
        cell.labelTitle.text = productDic["title"] as? String
        cell.labelPrice.text = "\(productDic["price"]!)원"
        cell.labelUploadTime.text = "\(productDic["town"]!) · \(productDic["uploadTime"]!)"
        
        return cell
    }
    //MARK:- 포트폴리오 코드 상품 셀 클릭시 데이터 처리하는 방법 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController
        
        let product = self.products[indexPath.row]
        let productDic = product.getDict()

        postVC?.documentID = productDic["documentID"]! as! String

        self.navigationController?.pushViewController(postVC!, animated: true)
    }
}

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}
//출처: https://devsc.tistory.com/62 [You Know Programing?]
