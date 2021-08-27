//
//  WritingModifyViewController.swift
//  PodoMarket
//
//  Created by 정주리 on 2021/04/08.
//  Copyright © 2021 zool2. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView
import MobileCoreServices
import Toast_Swift

class WritingModifyViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

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
    
    let db = Firestore.firestore()
    
    // postView에서 넘어온 데이터
    var documentID = ""
    var countOfUrls: Int!
    var imageUrls: [String]!
    var imageUrl1: String = ""
    var imageUrl2: String = ""
    var imageUrl3: String = ""
    var townName = ""
    var postTitle = ""
    var price = ""
    var category = ""
    var explanation = ""
    
    let pickerViewColumn = 1
    var categoryNames = [String]()
    
    var imageData1: Data?
    var imageData2: Data?
    var imageData3: Data?
    
    var imageDatas = [Data]()
    
    var downloadURL1: String = ""
    var downloadURL2: String = ""
    var downloadURL3: String = ""
    
    //이미지피커
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    var indexOfImage = 0 // 각 imgImage1,2,3의 인덱스
    var countOfImage = 0 // 총 사진 업로드 수
    var sendCount = 0 // image data
    
    var captureImage: UIImage! // 이미지 피커뷰 사진 선택시 들어갈 UIImage 담음

    var coverView: UIView = {
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
        
        pickerCategory.delegate = self
        pickerCategory.dataSource = self
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        buttonComplete.layer.cornerRadius = 5
        setImageView()
        setPostData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func buttonBackTapped() {
        let alert = UIAlertController(title: "글 수정 취소하시겠어요?",
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
    
    @IBAction func buttonImage1Tapped(_ sender: Any) {
        indexOfImage = 0
        settingImagePicker()
    }
    
    @IBAction func buttonImage2Tapped(_ sender: Any) {
        indexOfImage = 1
        settingImagePicker()
    }
    
    @IBAction func buttonImage3Tapped(_ sender: Any) {
        indexOfImage = 2
        settingImagePicker()
    }
    
    @IBAction func buttonCompleteTapped(_ sender: Any) {
//        setUpLoadingView()
        
        guard textFieldTitle.text != "" else { return myAlert("업로드 할 수 없음!", message: "제목,가격,설명란을 다 채워주세요!")}
        guard textFieldPrice.text != "" else { return myAlert("업로드 할 수 없음!", message: "제목,가격,설명란을 다 채워주세요!") }
        guard textFieldExplanation.text != "" else { return myAlert("업로드 할 수 없음!", message: "제목,가격,설명란을 다 채워주세요!") }
        
        self.view.addSubview(self.coverView)
        self.view.addSubview(self.indicator)
        self.indicator.startAnimating()
        
//        let storage = Storage.storage() // 이미지를 storage에 업로드
//        let storageRef = storage.reference() // Create a root reference
//
//        for i in imageUrls {
//
//        }
//        let timeStamp = Int(NSDate.timeIntervalSinceReferenceDate*1000) // Storage 유니크아이디
//        let storageFileName = storageRef.child("\(timeStamp).png") // imgUrl 파일 저장(원래이름 riversRef)
        
        let postRef = self.db.collection("Post").document(self.documentID)

        postRef.updateData([
            "title":"\(self.textFieldTitle.text!)",
            "price":"\(self.textFieldPrice.text!)",
            "explanation":"\(self.textFieldExplanation.text!)",
            "imageUrl1": self.imageUrl1
        ]) { error in
            if let err = error {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }

        self.indicator.stopAnimating()
        
        self.view.makeToast("글수정 완료!",
                            duration: 2,
                            point: CGPoint(x: 207, y: 300),
                            title: nil,
                            image: nil,
                            style: .init(),
                            completion: nil)

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    func settingImagePicker() {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        switch indexOfImage {
        case 0:
            imageView1.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            countOfImage += 1
            self.imageData1 = self.imageView1.image!.pngData()!

        case 1:
            imageView2.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            countOfImage += 1
            self.imageData2 = self.imageView2.image!.pngData()!

        case 2:
            imageView3.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            countOfImage += 1
            self.imageData3 = self.imageView3.image!.pngData()!

        default:
            print("인덱스 값을 벗어남.")
        }

        dismiss(animated: true, completion: nil)
    }
    
    func setPostData() {
        let realPrice = price.trimmingCharacters(in: ["원"])
        
        labelTownNotice.text = "현재 '\(townName)'에서 글 수정중입니다."
        setImageView()
        categoryNames.append(category)
        textFieldTitle.text = postTitle
        textFieldPrice.text = realPrice
        textFieldExplanation.text = explanation
    }
    
    func setImageView() {
        
        labelImageCount.text = "\(String(describing: self.countOfUrls!))/3"
        
        switch imageUrls.count {
        case 1 :
            imageUrl1 = imageUrls[0]
            imageView1.sd_setImage(with: URL(string:imageUrl1))
            imageView2.image = UIImage(named: "add.png")
            imageView3.image = UIImage(named: "add.png")
        case 2 :
            imageUrl1 = imageUrls[0]
            imageUrl2 = imageUrls[1]
            imageView1.sd_setImage(with: URL(string:imageUrl1))
            imageView2.sd_setImage(with: URL(string:imageUrl2))
            imageView3.image = UIImage(named: "add.png")
        case 3 :
            imageUrl1 = imageUrls[0]
            imageUrl2 = imageUrls[1]
            imageUrl3 = imageUrls[2]
            imageView1.sd_setImage(with: URL(string:imageUrl1))
            imageView2.sd_setImage(with: URL(string:imageUrl2))
            imageView3.sd_setImage(with: URL(string:imageUrl3))
            
        default:
            "인덱스 값을 벗어남"
        }
    }
    
    func setUpLoadingView() {
        self.view.addSubview(self.coverView)
        self.view.addSubview(self.indicator)
        self.indicator.startAnimating()
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
    
}

extension WritingModifyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // 뭘 보여줄거냐
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return categoryNames[row]
        }
//    출처: https://codemath.tistory.com/16 [CodeMath]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerViewColumn
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryNames.count
    }
    
    
}


//
//let storage = Storage.storage() // 이미지를 storage에 업로드
//let storageRef = storage.reference() // Create a root reference
//
//let timeStamp = Int(NSDate.timeIntervalSinceReferenceDate*1000) // Storage 유니크아이디
//let storageFileName = storageRef.child("\(timeStamp).png") // imgUrl 파일 저장(원래이름 riversRef)
//
//let _ = storageFileName.putData(imageData1!, metadata: nil) { metadata, error in
//
//    guard metadata != nil else { return }
//
//    storageFileName.downloadURL { url, error
//        in
//        guard let downloadURL = url else { return }
//        self.imageUrl1 = downloadURL.absoluteString
//        print("이미지1 다운로드 완료")
//    }
//}


//func showToast(message : String) {
//    let width_variable: CGFloat = 60 // 양쪽 마진 조절하는 거?
//    let toastLabel = UILabel(frame: CGRect(x: width_variable, y: self.view.frame.size.height-700, width: view.frame.size.width-2*width_variable, height: 50)) // frame.size.height-??? -> ???의 숫자가 커질수록 상단에 위치하게됨 , height : 35
//            // 뷰가 위치할 위치를 지정해준다. 여기서는 아래로부터 100만큼 떨어져있고, 너비는 양쪽에 10만큼 여백을 가지며, 높이는 35로
//    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//    toastLabel.textColor = UIColor.white
//    toastLabel.textAlignment = .center;
//    toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
//    toastLabel.text = message
//    toastLabel.alpha = 1.0
//    toastLabel.layer.cornerRadius = 10;
//    toastLabel.clipsToBounds  =  true
//    self.view.addSubview(toastLabel)
//    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
//        toastLabel.alpha = 0.0
//    }, completion: {(isCompleted) in
//        toastLabel.removeFromSuperview()
//    }) 출처: https://hyongdoc.tistory.com/281 [Doony Garage]
//}













//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
//        imageView1.addGestureRecognizer(tapGesture)
//        imageView1.isUserInteractionEnabled = true
//        imageView2.addGestureRecognizer(tapGesture)
//        imageView2.isUserInteractionEnabled = true
//        imageView3.addGestureRecognizer(tapGesture)
//        imageView3.isUserInteractionEnabled = true


// case
//self.imageData1 = self.imageView1.image!.pngData()!
//let _ = storageFileName.putData(imageData1!, metadata: nil) { metadata, error in
//
//    guard metadata != nil else { return }
//
//    storageFileName.downloadURL { url, error
//        in
//        guard let downloadURL = url else { return }
//
//        self.sendCount += 1
//
//        if self.countOfImage == 1 {
//
//            self.downloadURL1 = downloadURL.absoluteString
//            let postRef = self.db.collection("Post").document(self.documentID)
//
//            postRef.updateData([
//                "title":"\(self.textFieldTitle.text!)",
//                "price":"\(self.textFieldPrice.text!)",
//                "explanation":"\(self.textFieldExplanation.text!)",
//                "imageUrl1": self.downloadURL1
//            ]) { error in
//                if let err = error {
//                    print("Error updating document: \(err)")
//                } else {
//                    print("Document successfully updated")
//                }
//            }
//        }
//    }
//
//}
