
import UIKit
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import Toast_Swift

class PostViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var buttonSettings: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelNickname: UILabel!
    @IBOutlet weak var labelTown: UILabel!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelUploadTime: UILabel!
    @IBOutlet weak var labelExplanation: UILabel!
    
    @IBOutlet weak var buttonCommetMore: UIButton!
    @IBOutlet weak var labelCommentCount: UILabel!
    
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var labelAnotherProduct: UILabel!
    
    
    @IBOutlet weak var buttonHeart: UIButton!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var buttonGoComment: UIButton!
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var commentViewHeight: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var imageUrls = [String]()
    var imageUrl1: String = ""
    var imageUrl2: String = ""
    var imageUrl3: String = ""
    
    var documentID: String = "" // 다른 view에서 넘어온 documentID
    
    var loginID: String = "" // documentID로 db받아온 필드의 loginID 넣기.
    var nickname: String = "" // dataDic에서 받아온 nickname 저장.
    var imageProfileURL: String = ""
    var uploadTime: String = ""
    var salesStatus: String = ""
    
    var comments: [Comment] = []
    var products: [Product] = [] // 판매자의 다른 상품들
    
    var imageUser: UIImage = UIImage(named: "user.png")!
    var heartempty = UIImage(named: "heartempty")
    var heartfilled = UIImage(named: "heartfilled")

    var wishDocumentID: String = ""
    
    var coverView:UIView = {
        let view = UIView()
        view.frame = CGRect(x:0, y:0, width:414, height:896)
        view.backgroundColor = UIColor.white
        view.alpha = 0.5
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingCollectionViewLayOut()
        getDocumentData()  // documentID로 데이터 받아옴.
        viewSetting()
        checkMyWishPost()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        getCommentFromList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btnSettingTapped(_ sender: Any) {
        // 액션시트
        let actionSheet = UIAlertController(title: "내 게시물 설정",
                                            message: nil ,
                                            preferredStyle: UIAlertController.Style.actionSheet)
        
        let salesCompletedAction = UIAlertAction(title: "판매완료",
                                                 style: .default,
                                                 handler : {(action: UIAlertAction) in
                                                    self.db.collection("Post")
                                                        .document(self.documentID)
                                                        .updateData(["salesStatus": "판매완료"])
                                                    self.view.addSubview(self.coverView)
                                                    self.makeToast(message: "판매 완료 되었습니다!")
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                 })
        
        let deletePostAction = UIAlertAction(title: "글삭제",
                                             style: .default,
                                             handler: {(action: UIAlertAction) in
                                                self.db.collection("Post")
                                                    .document(self.documentID)
                                                    .delete() { error in
                                                        if error != nil {
                                                            print("삭제 중 에러 발생: \(String(describing: error))")
                                                        } else {
                                                            self.view.addSubview(self.coverView)
                                                            self.makeToast(message: "글 삭제 완료!")
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                                self.navigationController?.popViewController(animated: true)
                                                            }
                                                        }
                                                    }
                                            })
        
        let modifyingPost = UIAlertAction(title: "글수정",
                                          style: .default,
                                          handler: {(action: UIAlertAction) in
                                            let writingModifyVC = self.storyboard?.instantiateViewController(withIdentifier: "WritingModifyVC") as! WritingModifyViewController
                                            writingModifyVC.documentID = self.documentID
                                            writingModifyVC.countOfUrls = self.imageUrls.count
                                            writingModifyVC.imageUrls = self.imageUrls
                                            writingModifyVC.townName = self.labelTown.text!
                                            writingModifyVC.postTitle = self.labelTitle.text!
                                            writingModifyVC.explanation = self.labelExplanation.text!
                                            writingModifyVC.price = self.labelPrice.text!
                                            writingModifyVC.category = self.labelCategory.text!
                                            
                                            self.navigationController?.pushViewController(writingModifyVC, animated: true)
                                        })
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil )
        
        actionSheet.addAction(modifyingPost)
        actionSheet.addAction(salesCompletedAction)
        actionSheet.addAction(deletePostAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: false, completion: nil)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSellerProfileTapped(_ sender: Any) {
        goSellerProfileVC()
    }
    
    @IBAction func commentMoreTapped(_ sender: Any) {
        let myLoginID = appDelegate.userInfo.loginID
        
        if myLoginID == "" {
            myAlert("이용할 수 없음!", message: "회원가입 또는 로그인을 해주세요!")
            return
        }
        
        let commentVC = storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as? CommentViewController
        
        commentVC?.documentID = self.documentID
        
        self.navigationController?.pushViewController(commentVC!, animated: true)
    }
    
    @IBAction func btnPostMoreTapped(_ sender: Any) {
        goSellerProfileVC()
    }
    
    @IBAction func writeCommentTapped(_ sender: Any) {

        let myLoginID = appDelegate.userInfo.loginID
        
        if myLoginID == "" {
            myAlert("이용할 수 없음!", message: "회원가입 또는 로그인을 해주세요!")
            return
        }
        
        let commentVC = storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as? CommentViewController
        
        commentVC?.documentID = self.documentID
        
        self.navigationController?.pushViewController(commentVC!, animated: true)
    }

    @IBAction func btnHeartTapped(_ sender: Any) {
        
        let myLoginID = appDelegate.userInfo.loginID

        if myLoginID == "" {
            myAlert("이용할 수 없음!", message: "회원가입 또는 로그인을 해주세요!")
            return
        } else if myLoginID == loginID {
            myAlert("이용할 수 없음!", message: "자신의 상품은 관심목록에 추가할 수 없어요!")
            return
        }
        
        if buttonHeart.currentBackgroundImage == heartempty { // 꽉 찬 하트로 바뀔때 - WishPost에 추가
            
            let loginID = appDelegate.userInfo.loginID

            var ref: DocumentReference? = nil // db WishPost에 추가. documentID만 던짐.
            
            ref = self.db.collection("WishPost")
                .addDocument(data: [
                "myLoginID": loginID, // wishlistView에서 필요
                "documentID": self.documentID,
                "category": labelCategory.text!,
                "title": labelTitle.text!,
                "price": labelPrice.text!,
                "uploadTime": self.uploadTime,
                "imageUrl1": self.imageUrl1,
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.wishDocumentID = ref!.documentID
                    self.buttonHeart.setBackgroundImage(self.heartfilled, for: .normal)
                    self.makeToast(message: "관심목록에 추가되었습니다!")
                }
            }
        } else { // 관심목록에서 빼기. db 삭제.
            db.collection("WishPost")
                .document("\(wishDocumentID)")
                .delete() { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    self.buttonHeart.setBackgroundImage(self.heartempty, for: .normal)
                    self.makeToast(message: "관심목록에 삭제되었습니다!")
                }
            }
        }
    }
    
    func viewSetting() {
        imageScrollView.delegate = self
        scrollView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width / 2
        buttonGoComment.layer.cornerRadius = 5
        
        labelAnotherProduct.text = nickname + "님의 다른 판매상품"
//        settingCollectionViewLayOut()
        
        self.navigationController?.isNavigationBarHidden = true
    }
        
    func getDocumentData() {
        
        let docRef = db.collection("Post").document(self.documentID)  // 다른 view에서 받아온 documentID
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {

                let dataDic = document.data()! as NSDictionary
                
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
                let salesStatus = dataDic["salesStatus"] as? String ?? ""
                
                self.imageUrl1 = imageUrl1
                self.imageUrls.append(imageUrl1)
                
                if imageUrl2 != "" {
                    self.imageUrl2 = imageUrl1
                    self.imageUrls.append(imageUrl2)
                }
                
                if imageUrl3 != "" {
                    self.imageUrl3 = imageUrl3
                    self.imageUrls.append(imageUrl3)
                }
                
                self.setProductImage()
                
                self.loginID = loginID // 다른 뷰로 넘기기 위해
                self.setSellerProducts()
                self.salesStatus = salesStatus
                self.nickname = nickname
                self.uploadTime = uploadTime
                
                self.labelNickname.text = nickname // 현재 뷰에 표시
                self.labelTown.text = town
                self.labelTitle.text = title
                self.labelCategory.text = category
                self.labelUploadTime.text = uploadTime
                self.labelExplanation.text = explanation
                
                self.labelAnotherProduct.text = nickname + "님의 다른 판매상품"
                self.labelPrice.text = "\(price)원"
                
                self.setSellerProfileImage()

                // buttonSetting: loginID가 같을 경우만 isHidden = false로 변경
                // loginID가 같고 salesStatus의 text가 판매완료일 경우 viewbottom,buttonSetting비활성화
                let currentLoginID = self.appDelegate.userInfo.loginID
                if self.loginID == currentLoginID && salesStatus == "판매완료" {
                    self.buttonSettings.isHidden = true
                    self.viewBottom.isHidden = true
                } else if self.loginID == currentLoginID && salesStatus == "" {
                    self.buttonSettings.isHidden = false
                }
            } else {
                print("문서 없음.")
            }
        }
    }
        
    func setSellerProfileImage() {

        let sellerRef = db.collection("users")
                            .document(self.loginID) //homeView에서 넘어온 document.loginID
        
        sellerRef.getDocument { document, error in
            if let document = document, document.exists {
                let usersDic = document.data()! as NSDictionary
                
                let imageProfileURL = usersDic["profileImageURL"] as? String ?? ""
                self.imageViewProfile.sd_setImage(with: URL(string: imageProfileURL))
            } else {
                self.imageViewProfile.image = self.imageUser // 기본 이미지 설정
            }
        }
    }
    
    func setProductImage() {
        
        for i in 0..<imageUrls.count { // 코드로 imageview 생성, 이미지 넣기
            
            let imageView = UIImageView()
            
            imageView.sd_setImage(with: URL(string:imageUrls[i]))

            imageView.contentMode = .scaleToFill
            
            let xPosition = self.view.frame.width * CGFloat(i)
            
            imageView.frame = CGRect(x: xPosition, y: 0,
                                   width: self.view.frame.width,
                                   height: 334)
            //여기까지가 img Scroll View위에서 보여줄 코드로 만든 UIImageView에 대한 설정.
            
            // Scroll View의 사이즈
            imageScrollView.contentSize.width = self.view.frame.width * CGFloat(1+i)
            imageScrollView.addSubview(imageView) //  Scroll View의 크기가 결정되면 이미지를 Scroll View에 올려줌.
        }
    }
    
    // 스크롤을 하게 되면 이미지가 획획 넘어가는 것을 방지하기 위해 스토리보드로 가서
    // Scroll View를 선택- Attributes Inspector에서 Paging Enabled를 체크하기. 또는 imageScrollView.isPageingEnabled = true
    
    func setSellerProducts() {
        products.removeAll()
       
        db.collection("Post")
            .whereField("loginID", isEqualTo: self.loginID)
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

                var product = Product()

                product.imageUrl1 = imageUrl1
                product.title = title
                product.price = price
                product.documentID = documentID

                self.products.append(product)
           }
           self.collectionView.reloadData()
        }
      }
    }
    
    func getCommentFromList() {
        
        self.comments.removeAll()
        
        db.collection("Comment")
            .whereField("documentID", isEqualTo: self.documentID)
            .getDocuments{ snapshot, error in
            if error != nil {
                print("Error getting documents: \(String(describing: error))")
            } else {
                for document in (snapshot?.documents)! {
                    
                    let dataDic = document.data() as NSDictionary
                    
                    let loginID = dataDic["loginID"] as? String ?? ""
                    let nickname = dataDic["nickname"] as? String ?? ""
                    let profileImageURL = dataDic["profileImageURL"] as? String ?? ""
                    let commentText = dataDic["comment"] as? String ?? ""
                    let uploadedTime = dataDic["uploadedTime"] as? String ?? ""
                    let tagedUserLoginID = dataDic["tagedUserLoginID"] as? String ?? ""
                    let tagedUserNickname = dataDic["tagedUserNickname"] as? String ?? ""
                    
                    var comment = Comment()
                    comment.loginID = loginID
                    comment.nickname = nickname
                    comment.profileImageURL = profileImageURL
                    comment.commentText = commentText
                    comment.uploadedTime = uploadedTime
                    comment.tagedUserLoginID = tagedUserLoginID
                    comment.tagedUserNickname = tagedUserNickname
                    
                    self.comments.append(comment)
                }
                self.checkCommentCount()
                self.commentTableView.reloadData()
                self.labelCommentCount.text = "전체댓글 \(self.comments.count)"
            }
        }
    }
    
    func checkMyWishPost() {
        let myLoginID = appDelegate.userInfo.loginID

        _ = db.collection("WishPost")
            .whereField("myLoginID", isEqualTo: myLoginID)
            .whereField("documentID", isEqualTo: documentID)
            .getDocuments{ snapshot, error in
            if error != nil {
                print("에러?")
            } else {
                for document in (snapshot?.documents)! {
                self.wishDocumentID = document.documentID // wishDocID 변수에 저장
                //WishPost에 저장된 해당 post의 documentID
                self.buttonHeart.setBackgroundImage(self.heartfilled, for: .normal)
                }
            }
        }
    }
    
    func checkCommentCount() {
        let commentCount = comments.count
        
        switch commentCount {
            case 1:
                commentViewHeight.constant = 60
            case 2:
                commentViewHeight.constant = 120
        case 2..<Int.max:
                commentViewHeight.constant = 120
            default:
                commentViewHeight.constant = 0
        }
    }
    
    func goSellerProfileVC() {
        let PostingUserProfileVC = storyboard?.instantiateViewController(withIdentifier: "PostingUserProfileVC") as? PostingUserProfileViewController
        
            PostingUserProfileVC?.loginID = loginID
            
            self.navigationController?.pushViewController(PostingUserProfileVC!, animated: true)
    }
    
    func myAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok",
                                   style: UIAlertAction.Style.default,
                                   handler: nil)
        
        alert.addAction(action)
        self.present(alert,
                     animated: true,
                     completion: nil)
    }
    
    func makeToast(message: String) {
        self.view.makeToast(message,
        duration: 2,
        point: CGPoint(x: 207, y: 300),
        title: nil,
        image: nil,
        style: .init(),
        completion: nil)
    }
}

extension PostViewController : UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        
        let comment = self.comments[indexPath.row]
        
        let commentDic = comment.getDict()
        
        cell.labelNickname.text = commentDic["nickname"]!
        cell.labelComment.text = commentDic["commentText"]!
        cell.imageProfile.layer.cornerRadius = cell.imageProfile.frame.size.width / 2
        cell.imageProfile.sd_setImage(with: URL(string: commentDic["profileImageURL"]!))
        cell.labelUploadedTime.text = commentDic["uploadedTime"]!
        
        return cell
    }
    
    //MARK:- CollecionView
    
    func settingCollectionViewLayOut() {
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.sectionInset = UIEdgeInsets(top: 16,left: 20,bottom: 16,right: 20)
        layout.minimumInteritemSpacing = 0 //0
        layout.itemSize = CGSize(width: 160, height: 140) //160
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostProductCell", for: indexPath) as! CollectionViewCell
        
        let product = self.products[indexPath.row]
        let productDic = product.getDict()
        
        cell.imageProduct.layer.cornerRadius = 10
        cell.imageProduct.sd_setImage(with: URL(string: productDic["imageUrl1"]! as! String))
        cell.labelTitle.text = productDic["title"] as? String
        cell.labelPrice.text = productDic["price"]! as! String + "원"
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController
        
        let product = self.products[indexPath.row]
        let productDic = product.getDict()
        
        postVC?.documentID = productDic["documentID"]! as! String

        self.navigationController?.pushViewController(postVC!, animated: true)
    }
    
}

