import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import SDWebImage

class CategorySelectedNSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lableSelectedCategory: UILabel!
    
    let db = Firestore.firestore()
    
    var selectedCategory: String = "" // categoryTab에서 넘어온것
    
    var products = [Product]() // 해당 카테고리에 있는 상품만 넣음
    var currentProducts: [Product] = [] // update table

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        settingHomeView()
        getCategoryPost()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    
    func settingHomeView() {
        print("선택된 카테고리: \(selectedCategory)")
        
        lableSelectedCategory.text = selectedCategory
        
        self.navigationController?.isNavigationBarHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.placeholder = "검색어를 입력해주세용"
    }
    
    @IBAction func goBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getCategoryPost() {
        
        db.collection("Post")
            .whereField("category", isEqualTo: selectedCategory)
            .whereField("salesStatus", isEqualTo: "")
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
                    let price = dataDic["price"] as? String ?? ""
                    let uploadTime = dataDic["uploadTime"] as? String ?? ""
                    
                    let uploadTimeInt = self.convertUploadTime(uploadTime: uploadTime)

                    // PostData  Struct에 집어넣음.
                    var product = Product()
                    
                    product.imageUrl1 = imageUrl1
                    product.title = title
                    product.price = price
                    product.documentID = documentID
                    product.uploadTime = uploadTime
                    product.uploadTimeInt = uploadTimeInt
                    
                    self.products.append(product)

                    self.currentProducts = self.products
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func convertUploadTime(uploadTime: String) -> UInt {
        let stringUploadTime = uploadTime
        let uploadTimeInt: UInt = UInt(stringUploadTime)! // string에서 UInt로 다시 변환
        
        return uploadTimeInt
    }
    
}

extension CategorySelectedNSearchViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // 셀 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    // 셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return currentProducts.count
    }
    
    // 셀 정보
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! HomeTableViewCell
            
            cell.imageProduct.layer.cornerRadius = 5
        cell.imageProduct.sd_setImage(with: URL(string:currentProducts[indexPath.row].imageUrl1!))
            cell.labelTitle.text = currentProducts[indexPath.row].title
            cell.labelPrice.text = "\(String(describing: currentProducts[indexPath.row].price!))원"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController
        
        postVC?.documentID = products[indexPath.row].documentID!
        //        postVC?.documentID = currentProducts[indexPath.row].documentID
        
        self.navigationController?.pushViewController(postVC!, animated: true)
    }
    
    // 서치바에 텍스트를 치면 테이블 뷰가 업데이트 될거니까
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        guard !searchText.isEmpty else {
            currentProducts = products // searchText가 isEmpty면 다시 전체 products를 currentProduct에 넣음
            tableView.reloadData()
            return
        }
    
        currentProducts = products.filter({ products -> Bool in // 서치바 검색
            
            guard let text = searchBar.text else {
                return false
            }
            
            let searchText = products.title!.contains(text)
            
            return searchText
        })
        
        tableView.reloadData()
    }
}
// title 뒤에 ! 붙일 수 있는 이유 -> products.title이 nil일 경우가 없고, 확실하게 데이터가 있을 경우엔 !붙일 수 있다.

// 서치바 필터기능 https://www.youtube.com/watch?v=4RyhnwIRjpA
// guard 구문 https://brunch.co.kr/@robinkangwgmv/4

//override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        시그
//        if segue.identifier == "segueToFilterVC" {
//            let filterVC = segue.destination as! FilterViewController
//
//            //접근할 데이터 //넘겨줄 데이터
//            filterVC.categorySearchVC = self // 자식(filterview) 에게 부모(searchview)인스턴스등록한것.-> 필터뷰에 searchVC변수있음.
//        }
//    }

//class Product {
//    let title: String
//    let uploadTime: String
//    let price: String
//    let imageUrl1: String
//    let documentID: String
//
//    init(title: String, uploadTime: String, price: String, imageUrl: String, documentID: String) {
//        self.title = title
//        self.uploadTime = uploadTime
//        self.price = price
//        self.imageUrl1 = imageUrl
//        self.documentID = documentID
//    }
//}

/*
 @ guard let 구문
 
 * guard 뒤에 조건이 true일 때 코드가 계속 실행되며
 반드시 뒤에 else 구문이 필요하다.

 * guard 뒤 조건이 false라면 else 블럭이 실행되며, 자신보다 상위 코드 블록을 종료하는 코드가 반드시 들어가야한다. (return, break, continue, throw)

 * 옵셔널 바인딩으로 사용할 경우 guard 구문 실행 코드 아래부터 함수 블럭 내의 지역상수처럼 사용 가능하다.(전역으로 사용 가능?)
 
 */
