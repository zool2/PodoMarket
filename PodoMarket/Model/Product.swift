
import Foundation
struct Product {
    var title: String? = ""
    var price: String? = ""
    var category: String? = ""
    var explanation: String? = ""
    var loginID: String? = ""
    var nickname: String? = ""
    var town: String? = ""
    var imageUrl1: String? = ""
    var imageUrl2: String? = ""
    var imageUrl3: String? = ""
    var documentID: String? = ""
    var uploadTime: String? = ""
    var uploadTimeInt: UInt?
    var wishDocumentID: String? = ""
    var myLoginID: String? = ""
    var myNickname: String? = ""
    var currentLoginID: String? = ""
    var currentNickname: String? = ""
    
    func getDict() -> [String: Any] {
        let dict = ["title": self.title!,
                    "price": self.price!,
                    "category": self.category!,
                    "explanation": self.explanation!,
                    "loginID": self.loginID!,
                    "nickname": self.nickname!,
                    "town": self.town!,
                    "imageUrl1": self.imageUrl1!,
                    "imageUrl2": self.imageUrl2!,
                    "imageUrl3": self.imageUrl3!,
                    "documentID": self.documentID!,
                    "uploadTime": self.uploadTime!,
                    "uploadTimeInt": self.uploadTimeInt as Any,
                    "wishDocumentID": self.wishDocumentID!,
                    "myLoginID": self.myLoginID!,
                    "myNickname": self.myNickname!,
                    "currentLoginID": self.currentLoginID!,
                    "currentNickname": self.currentNickname!
            ] as [String : Any]
        
        return dict 
    }

}


