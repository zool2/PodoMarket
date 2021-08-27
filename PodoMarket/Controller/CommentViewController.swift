

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImage
import Toast_Swift
//import MobileCoreServices
//import UserNotifications

class CommentViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet var lableCommentCount: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var buttonUploadComment: UIButton! 
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var myLoginID: String = ""
    var myNickname: String = ""
    
    var profileImageURL: String = ""
    var imageUser: UIImage = UIImage(named: "user.png")!
    
    var documentID:String = ""
    var commentCount:Int = 0
    var tagedUserLoginID:String = ""
    var tagedUserNickname:String = ""
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        settingView()
        getCommentFromList()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        print("touchesBegan") // 화면 터치하면 작동 
    }
    
    @objc func dismissKeyboard() {
        print("키보드 dismiss")
        self.view.endEditing(true) // 키보드 사라지게
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func writeCompleteTapped(_ sender: Any) {
        
        let date:Date = Date() // 업로드 시간 넣기
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"

        let now:String = dateFormatter.string(from: date)

        var ref: DocumentReference? = nil // documentID가 필드에 저장됨.
        
        ref = self.db.collection("Comment").addDocument(data: [
            "documentID": documentID,
            "nickname": myNickname,
            "comment": self.textField.text!,
            "loginID": myLoginID,
            "profileImageURL": profileImageURL,
            "uploadedTime": now,
            "tagedUserLoginID": tagedUserLoginID,
            "tagedUserNickname": tagedUserNickname
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                self.getCommentFromList() // 댓글 tableView 업데이트
            }
        }
        textField.text = ""
    }
    
    func settingView() {
        buttonUploadComment.layer.cornerRadius = 5
        
        myNickname = appDelegate.userInfo.nickName
        myLoginID = appDelegate.userInfo.loginID
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag //테이블뷰에서의 키보드 해제모드  override touchesBegan관련
        
        getImageProfile() // 내 프로필이미지 URL 가져오기.
    }
    
    func getImageProfile() {
        
        let userRef = db.collection("users").document(myLoginID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {

                let usersDic = document.data()! as NSDictionary

                self.profileImageURL = usersDic["profileImageURL"] as? String ?? ""
            } else {
                print("이미지 없음.")
            }
        }
    }
    
    func getCommentFromList() {

        self.comments.removeAll()

        db.collection("Comment")
            .whereField("documentID", isEqualTo: documentID)
            .getDocuments{ snapshot, error in
            if error != nil {
                print("Error getting documents: \(String(describing: error))")
            } else {
                for document in (snapshot?.documents)! {

                    let documentID = document.documentID
                    
                    let dataDic = document.data() as NSDictionary

                    let loginID = dataDic["loginID"] as? String ?? ""
                    let nickname = dataDic["nickname"] as? String ?? ""
                    let profileImageURL = dataDic["profileImageURL"] as? String ?? ""
                    let commentText = dataDic["comment"] as? String ?? ""
                    let uploadedTime = dataDic["uploadedTime"] as? String ?? ""
                    let tagedUserLoginID = dataDic["tagedUserLoginID"] as? String ?? ""
                    let tagedUserNickname = dataDic["tagedUserNickname"] as? String ?? ""

                    var comment = Comment() // Struct에 집어넣음.

                    comment.documentID = documentID
                    comment.loginID = loginID
                    comment.nickname = nickname
                    comment.profileImageURL = profileImageURL
                    comment.commentText = commentText
                    comment.uploadedTime = uploadedTime
                    comment.tagedUserLoginID = tagedUserLoginID
                    comment.tagedUserNickname = tagedUserNickname

                    self.comments.append(comment) // Struct에 저장된 데이타를 Array에 넣어주기.
                }
                self.checkCommentCount()
                self.tableView.reloadData()
            }
        }
    }
    
    func checkCommentCount() { // 댓글개수 확인,정렬,댓글수 표시
        if self.comments.count == 0 {
            self.tableView.isHidden = true
            self.lableCommentCount.text = "댓글 \(self.comments.count)"
        } else {
            self.tableView.isHidden = false
            self.comments.sort{ $0.uploadedTime < $1.uploadedTime}
            self.lableCommentCount.text = "댓글 \(self.comments.count)"
        }
    }
    
}

extension CommentViewController : UITableViewDelegate, UITableViewDataSource {

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

        cell.labelLoginID = commentDic["loginID"]!
        cell.labelNickname.text = commentDic["nickname"]!
        cell.labelComment.text = commentDic["commentText"]!
        cell.imageProfile.layer.cornerRadius = cell.imageProfile.frame.size.width / 2
        cell.imageProfile.sd_setImage(with: URL(string: commentDic["profileImageURL"]!))
        cell.labelUploadedTime.text = commentDic["uploadedTime"]!
        
        // 내 댓글만 다른색으로 표시하기
        let myLoginID = appDelegate.userInfo.loginID
        if commentDic["loginID"]! == myLoginID {
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 셀의 indexPath를 가져옴.
        
        let cell = tableView.cellForRow(at: indexPath) as! CommentTableViewCell
        
        let unwrappingNickname: String = cell.labelNickname.text!
        
        let myNickname = appDelegate.userInfo.nickName
        
        if myNickname == unwrappingNickname {
            textField.text = ""
        } else {
            textField.text = "@\(unwrappingNickname) "
        }
        
        tagedUserNickname = cell.labelNickname.text!
        tagedUserLoginID = cell.labelLoginID
        
        _ = tableView.indexPathForSelectedRow
    }
    
    // 테이블뷰 행 스와이프 삭제
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let comment = self.comments[indexPath.row]
        let commentLoginID = comment.loginID
        
        guard commentLoginID == appDelegate.userInfo.loginID else {
            self.view.makeToast("다른 유저의 댓글은 삭제 불가능합니다!",
                                duration: 2,
                                point: CGPoint(x: 207, y: 300),
                                title: nil,
                                image: nil,
                                style: .init(),
                                completion: nil)
        return }
        
        if editingStyle == .delete {
             
            let comment = self.comments[indexPath.row]
            
            db.collection("Comment").document( comment.documentID).delete() { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    self.view.makeToast("댓글에서 삭제되었습니다!",
                                        duration: 2,
                                        point: CGPoint(x: 207, y: 300),
                                        title: nil,
                                        image: nil,
                                        style: .init(),
                                        completion: nil)
                    self.getCommentFromList()
                }
            }
        }
    }
// getDic할 필요 없이 바로 "product.wishDocumentID"가져와서 해당 문서 삭제하면 됨.
}

// 키보드 움직이게 설정하니까 셀선택이 안됨. ->https://medium.com/@KaushElsewhere/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1 테이블뷰가 있을 때엔 4번째 방식으로 해야됨.

// 이건 테이블뷰 없을 때 사용가능.
// 키보드 바깥 누르면 키보드 사라지는 이벤트 - dismissKeyboard() 실행.
//        let tap :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)


   
//    func textViewDidEndEditing(_ commentTF: UITextView) {
//
//        if commentTF.text == "" {
//            let currentNickname = appDelegate.userInfo.nickName
//
//            commentTF.text = "\(currentNickname)님 댓글을 달아보세요!"
//            commentTF.textColor = UIColor.lightGray
//            commentTF.font = UIFont(name: "verdana", size: 17.0)
//        }
//    }
    
//    func textViewDidBeginEditing(_ commentTF: UITextView) {
//
//        let userNickname = appDelegate.userInfo.nickName
//
//        if textField.text == "\(userNickname)님 댓글을 달아보세요!" {
//            textField.text = ""
//            textField.textColor = UIColor.black
//            textField.font = UIFont(name: "verdana", size: 18.0)
//        }
//    }
    




    //21/07/16 최근수정됨
//    @objc func keyboardWillShow(notification : Notification) {
//        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            self.bottomConstraint.constant = keyboardSize.height
//            print("키보드 willshow")
//        }
//    }
    
//    @objc func keyboardWillHide(notification:Notification) {
//        self.bottomConstraint.constant = 0
//        print("키보드 willhide")
//        self.view.layoutIfNeeded()
//    }
