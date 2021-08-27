
import Foundation

struct Comment {
    var loginID: String = ""
    var nickname: String = ""
    var profileImageURL: String = ""
    var commentText: String = ""
    var uploadedTime: String = ""
    var documentID: String = ""
    var tagedUserLoginID: String = ""
    var tagedUserNickname: String = ""
    
    func getDict() -> [String: String] {
        
        let dict = ["loginID": self.loginID,
                    "nickname": self.nickname,
                    "profileImageURL": self.profileImageURL,
                    "commentText": self.commentText,
                    "documentID": self.documentID,
                    "uploadedTime": self.uploadedTime,
                    "tagedUserLoginID": self.tagedUserNickname,
                    "tagedUserNickname": self.tagedUserNickname
        ]
        return dict
    }
    
//    struct CommentData {
//        var loginID: String = ""
//        var nickname: String = ""
//        var comment: String = ""
//        var uploadedTime: String = ""
//        var documentID: String = ""
//        var tagedUserLoginID: String = ""
//        var tagedUserNickname: String = ""
//
//        func getDict() -> [String:String] {
//            let dict = ["loginID" : self.loginID,
//                        "nickname" : self.nickname,
//                        "comment" : self.comment,
//                        "documentID" : self.documentID,
//                        "uploadedTime" : self.uploadedTime,
//                        "tagedUserLoginID" : self.tagedUserNickname,
//                        "tagedUserNickname" : self.tagedUserNickname
//                        ]
//            return dict
//        }
//    }
}
