

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import MobileCoreServices
import NVActivityIndicatorView
import Toast_Swift

class WritingViewController: UIViewController {

    @IBOutlet weak var labelWritingStatus: UILabel!
    @IBOutlet weak var buttonComplete: UIButton!
    @IBOutlet weak var labelTownNotice: UILabel!
    @IBOutlet weak var labelImageCount: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var pickerCategory: UIPickerView!
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textFieldPrice: UITextField!
    @IBOutlet weak var textFieldExplanation: UITextView!
    
    //피커뷰
    let pickerViewColumn = 1
    var categoryNames = ["여성의류","남성패션/잡화","디지털/가전","도서/음반","뷰티/미용","스포츠/레저","출산/육아", "여행/여가활동","게임/취미", "반려동물용품","티켓/문화생활", "생활 가공식품","가구/인테리어", "식물","기타 중고물품", "삽니다"]
    
    var categoryName: String = ""
    
    //이미지피커
    var indexOfImage = 0 // 각 imgImage1,2,3의 인덱스
    var countOfImage = 0 // 총 사진 업로드 수
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var captureImage: UIImage! // 이미지 피커뷰 사진 선택시 들어갈 UIImage 담음
    
    var imageURL: URL!
    var downloadURL1: String = ""
    var downloadURL2: String = ""
    var downloadURL3: String = ""
    
    var coverView:UIView = {
        let view = UIView()
        view.frame = CGRect(x:0, y:0, width:414, height:896)
        view.backgroundColor = UIColor.white
        view.alpha = 0.5
        
        return view
    }()
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 180, y: 448, width: 50, height: 50),
    type: .ballRotateChase,
    color: .black,
    padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "글 작성 취소하시겠어요?",
                                      message: nil,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "확인",
                                      style: UIAlertAction.Style.default,
                                      handler: { action in
                                                self.navigationController?.popViewController(animated: true)}))
        alert.addAction(UIAlertAction(title: "취소",
                                      style: UIAlertAction.Style.cancel,
                                      handler: { action in
                                        alert.dismiss(animated: true, completion: nil) }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // imgImage1,2,3에 index넣어줌.
    @IBAction func onButtonImage1(_ sender: Any) {
        indexOfImage = 0
        presentImagePicker()
    }
    
    @IBAction func onButtonImage2(_ sender: Any) {
        indexOfImage = 1
        presentImagePicker()
    }
    
    @IBAction func onButtonImage3(_ sender: Any) {
        indexOfImage = 2
        presentImagePicker()
    }
    
    @IBAction func writeCompleteTapped(_ sender: Any) {
        
        if self.countOfImage == 0 || categoryName == "" || textFieldTitle.text == "" ||
           textFieldPrice.text == "" || textFieldExplanation.text == "" {
            myAlert("업로드 할 수 없음!", message: "사진,카테고리,제목,가격,설명란을 다 채워주세요!")
        } else {
            setUpLoadingView()
                    
            if self.countOfImage >= 1 {
            let imageData = self.imageView1.image!.pngData()!
            self.uploadAndSetValue(imageData: imageData) // 이미지를 업로드, 그 이미지 url 다운로드, 글정보 data저장까지.
            }
        }
    }
    
     func uploadAndSetValue(imageData: Data?) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let timeStamp = Int(NSDate.timeIntervalSinceReferenceDate*1000) // Storage 유니크아이디
        let storageFileName = storageRef.child("\(timeStamp).png")
        
        let date:Date = Date() // 업로드 시간
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let now: String = dateFormatter.string(from: date)
        
        var sendCount = 0 // 이미지 데이터 업로드, 다운로드 완료시 +1.
        
        // storage 이미지 업로드
        let _ = storageFileName.putData(imageData!, metadata: nil) { metadata, error in
            
            guard metadata != nil else { return }
            
            // storage 이미지 URL 다운로드 & Post 업로드
            storageFileName.downloadURL { url, error in
                
                guard let downloadURL = url else { return }
                
                sendCount += 1 // imageView1 데이터가 이미 업로드 되고 다운로드 받아져서 sendCount 1 올림
                
                let imageCount = self.countOfImage
                
                switch imageCount {
                    case 1 :
                        self.downloadURL1 = downloadURL.absoluteString
                        var ref: DocumentReference? = nil
                        ref = db.collection("Post").addDocument(data: [
                            "category":self.categoryName,
                            "title": self.textFieldTitle.text!,
                            "price": self.textFieldPrice.text!,
                            "explanation": self.textFieldExplanation.text!,
                            "loginID": appDelegate.userInfo.loginID,
                            "nickname": appDelegate.userInfo.nickName,
                            "town": appDelegate.userInfo.town,
                            "uploadTime": now,
                            "imageUrl1": self.downloadURL1,
                            "imageUrl2": "",
                            "imageUrl3": "",
                            "salesStatus": ""
                        ]) { error in
                            if let error = error {
                                print("Error adding document: \(error)")
                            } else {
                                print("Document added with ID: \(ref!.documentID)")
                            }
                        }
                    case 2 :
                        if sendCount == 1 {
                            
                            self.downloadURL1 = downloadURL.absoluteString
                            
                            let data2 = self.imageView2.image!.pngData()!
                            self.uploadAndSetValue(imageData: data2)
                        } else {
                            self.downloadURL2 = downloadURL.absoluteString
                            
                            var ref: DocumentReference? = nil
                            ref = db.collection("Post").addDocument(data: [
                                "category":self.categoryName,
                                "title": self.textFieldTitle.text!,
                                "price": self.textFieldPrice.text!,
                                "explanation": self.textFieldExplanation.text!,
                                "loginID": appDelegate.userInfo.loginID,
                                "nickname": appDelegate.userInfo.nickName,
                                "town": appDelegate.userInfo.town,
                                "uploadTime": now,
                                "imageUrl1": self.downloadURL1,
                                "imageUrl2": self.downloadURL2,
                                "imageUrl3": "",
                                "salesStatus": ""
                            ]) { error in
                                if let error = error {
                                    print("Error adding document: \(error)")
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                }
                            }
                        }
                    case 3 :
                        if sendCount == 1 {
                            self.downloadURL1 = downloadURL.absoluteString
                            let data2 = self.imageView2.image!.pngData()!
                            self.uploadAndSetValue(imageData: data2)
                        } else if sendCount == 2 {
                            self.downloadURL2 = downloadURL.absoluteString
                            let data3 = self.imageView3.image!.pngData()!
                            self.uploadAndSetValue(imageData: data3)
                        } else {
                            self.downloadURL3 = downloadURL.absoluteString
                            
                            var ref: DocumentReference? = nil
                            ref = db.collection("Post").addDocument(data: [
                                "category":self.categoryName,
                                "title": self.textFieldTitle.text!,
                                "price": self.textFieldPrice.text!,
                                "explanation": self.textFieldExplanation.text!,
                                "loginID": appDelegate.userInfo.loginID,
                                "nickname": appDelegate.userInfo.nickName,
                                "town": appDelegate.userInfo.town,
                                "uploadTime": now,
                                "imageUrl1": self.downloadURL1,
                                "imageUrl2": self.downloadURL2,
                                "imageUrl3": self.downloadURL3,
                                "salesStatus": ""
                            ]) { error in
                                if let error = error {
                                    print("Error adding document: \(error)")
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                }
                            }
                        }
                    default:
                    print("인덱스 값을 벗어남.")
                }
                
            }
            
            self.indicator.stopAnimating()
            
            self.makeToast(message: "글 작성이 완료되었습니다!")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
            self.navigationController?.pushViewController(homeVC, animated: true)
            }
        }
    }
    
    func viewSetting() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        buttonComplete.layer.cornerRadius = 10
        labelTownNotice.text = "현재 '\(appDelegate.userInfo.town)'에서 글 작성중입니다."
        
        imageView1.image = UIImage(named: "add.png")
        imageView2.image = UIImage(named: "add.png")
        imageView3.image = UIImage(named: "add.png")
        
        imageView1.layer.borderColor = UIColor.lightGray.cgColor
        imageView1.layer.borderWidth = 1
        imageView2.layer.borderColor = UIColor.lightGray.cgColor
        imageView2.layer.borderWidth = 1
        imageView3.layer.borderColor = UIColor.lightGray.cgColor
        imageView3.layer.borderWidth = 1
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
    
    func setUpLoadingView() {
        self.view.addSubview(self.coverView)
        self.view.addSubview(self.indicator)
        self.indicator.startAnimating()
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
    
    func presentImagePicker() {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {

            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true

            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Photo album inaccessable")
            myAlert("Photo album inaccessable",
                    message: "Application cannot access the photo album.")
        }
    }
    
}

extension WritingViewController: UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate {
    
    // 이미지피커 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 이미지피커 앨범 이미지 선택
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as NSString as String) {
            captureImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            
            let indexCount = self.indexOfImage
            
            switch indexCount {
            case 0:
                imageView1.image = captureImage
                countOfImage += 1
                labelImageCount.text = "1/3"
            case 1:
                imageView2.image = captureImage
                countOfImage += 1
                labelImageCount.text = "2/3"
            case 2:
                imageView3.image = captureImage
                countOfImage += 1
                labelImageCount.text = "3/3"
            default:
                print("인덱스 값을 벗어남.")
            }
        }
        self.dismiss(animated: true, completion: nil) // 앨범 선택후 사라지는것
    }
    
    // 피커뷰
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerViewColumn
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryName = categoryNames[row]
    }
    
}

// 로딩중 커스텀 인디케이터 
//https://github.com/ninjaprox/NVActivityIndicatorView
