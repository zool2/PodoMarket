
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Toast_Swift

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var labelNickname: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var buttonModifyProfile: UIButton!
    
    var documentID: String = ""
    var nickname: String = ""
    var loginID: String = ""
    var imageURL: String = ""
    
    let db = Firestore.firestore()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loginStatus()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        
        do {
        try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
            self.appDelegate.userInfo.nickName = ""
            self.appDelegate.userInfo.loginID = ""
            self.appDelegate.userInfo.town = ""
            self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editProfileTapped() {
        print("edit tapped")
        let storyboard: UIStoryboard = self.storyboard!
        let editProfileVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as UIViewController
        self.present(editProfileVC, animated: true, completion: nil)
        editProfileVC.modalTransitionStyle = .crossDissolve
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        
        let alert = UIAlertController(title: "정말 탈퇴하시겠어요?",
                                      message: nil,
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "네",
                                      style: UIAlertAction.Style.default,
                                      handler: { action in
                                                user.delete { error in
                                                    if error != nil {
                                                        // 계정 삭제 실패
                                                    } else {
                                                        self.appDelegate.userInfo.loginID = ""
                                                        self.view.makeToast("계정 삭제 완료되었습니다.",
                                                        duration: 2,
                                                        point: CGPoint(x: 207, y: 300),
                                                        title: nil,
                                                        image: nil,
                                                        style: .init(),
                                                        completion: nil)
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                            self.navigationController?.popViewController(animated: true)
                                                        }
                                                    }
                                                }
                                        }))
        
        alert.addAction(UIAlertAction(title: "아니요",
                                      style: UIAlertAction.Style.cancel,
                                      handler: { action in
                                                alert.dismiss(animated: true,
                                                              completion: nil) }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func loginStatus() {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        nickname = self.appDelegate.userInfo.nickName
        loginID = self.appDelegate.userInfo.loginID
        imageURL = self.appDelegate.userInfo.imageProfileURL
        imageProfile.layer.cornerRadius = imageProfile.frame.size.width / 2
        imageProfile.sd_setImage(with: URL(string: imageURL))
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1

        labelNickname.text = "\(nickname)"
        labelEmail.text = "\(loginID)"
        
        buttonModifyProfile.layer.borderColor = UIColor.lightGray.cgColor
        buttonModifyProfile.layer.borderWidth = 1
        buttonModifyProfile.layer.cornerRadius = 5
    }
    
    
}
