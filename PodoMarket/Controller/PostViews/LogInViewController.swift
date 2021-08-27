
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignin: UIButton!
    
    var loginID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonLogin.layer.cornerRadius = 5
        buttonSignin.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        if loginID != "" {
            textFieldEmail.text = loginID
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // 터치하면 키보드 사라짐.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.pushHomeVC()
    }
    
    @IBAction func goSignUpTapped(_ sender: Any) {
        
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    // MARK:- 포트폴리오 코드
    @IBAction func loginTapped(_ sender: Any) {
        
        let email = textFieldEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = textFieldPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if error != nil {
                if email == "" || password == "" {
                    let alret = UIAlertController(title: "로그인 실패",
                                                  message: error.debugDescription,
                                                  preferredStyle: UIAlertController.Style.alert)
                    print("에러: \(error.debugDescription)")
                    
                    let defaultAction = UIAlertAction(title: "확인",
                                                      style: .destructive,
                                                      handler : nil)
                    
                    alret.addAction(defaultAction)
                    
                    self.present(alret, animated: true, completion: nil)
                } else {
                    let alret = UIAlertController(title: "로그인 실패",
                                                  message: error.debugDescription,
                                                  preferredStyle: UIAlertController.Style.alert)
                    
                    let defaultAction = UIAlertAction(title: "확인",
                                                      style: .destructive,
                                                      handler : nil)
                    
                    alret.addAction(defaultAction)
                    
                    self.present(alret, animated: true, completion: nil)
                }
            } else { //로그인 성공.
                
                print("로그인되었습니다.")
                
                // 사용자 계정 가져오기
                let user = Auth.auth().currentUser
                print("\(String(describing: user?.email)), \(String(describing: user?.uid))")
                
                if let email = user?.email {
                    self.loginID = email
                }
                
                // firestore users DocumentID와 Auth 사용자 이메일 계정이 일치하는 데이터 가져오기.
                let db = Firestore.firestore()

                db.collection("users")
                    .document("\(self.loginID)")
                    .getDocument{ document, error in
                    
                    let dataDic = document!.data()! as NSDictionary
                        
                    if dataDic != nil {
                        let nickname = dataDic["nickname"] as? String ?? ""
                        let imageURL = dataDic["profileImageURL"] as? String ?? ""
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let appDelegateTown = appDelegate.townSetting.town
                            
                        appDelegate.userInfo.loginID = email // textfield에 적힌 email
                        appDelegate.userInfo.nickName = nickname
                        appDelegate.userInfo.imageProfileURL = imageURL
                        appDelegate.userInfo.town = appDelegateTown
                            
                        self.pushHomeVC()
                    } else {
                        print("DataDic is nil")
                    }
                }
            }
        }
    }
    
    func pushHomeVC() {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }

}
