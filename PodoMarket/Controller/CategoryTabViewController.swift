
import UIKit

class CategoryTabViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let categoryNames = ["여성의류", "남성패션/잡화",
                         "디지털/가전", "도서/음반",
                         "뷰티/미용", "스포츠/레저",
                         "출산/육아", "여행/여가활동",
                         "게임/취미", "반려동물용품",
                         "티켓/문화생활", "생활 가공식품",
                         "가구/인테리어", "식물",
                         "기타 중고물품", "삽니다"]
    
    let categoryImages: [UIImage] = [UIImage(named: "women.png")!, UIImage(named: "men.png")!,
                                     UIImage(named: "digital.png")!, UIImage(named: "book.png")!,
                                     UIImage(named: "cosmetic.png")!, UIImage(named: "sportstools.png")!,
                                     UIImage(named: "baby.png")!, UIImage(named: "travel.png")!,
                                     UIImage(named: "game.png")!, UIImage(named: "dog.png")!,
                                     UIImage(named: "ticket.png")!, UIImage(named: "food.png")!,
                                     UIImage(named: "furniture.png")!, UIImage(named: "plant.png")!,
                                     UIImage(named: "other.png")!, UIImage(named: "iwillbuy.png")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        settingCollectionViewLayOut()
        settingViewLayout()
    }
    
    func settingViewLayout() {
        topView.layer.addBorder([.bottom], color: UIColor.lightGray, width: 0.5)
    }

}

extension CategoryTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func settingCollectionViewLayOut() {
            let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            
            layout.sectionInset = UIEdgeInsets(top: 0,left: 32,bottom: 16,right: 32)
            layout.minimumInteritemSpacing = 28
            layout.itemSize = CGSize(width: 90, height: 120)
        }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.imageCategory.image = categoryImages[indexPath.item]
        cell.labelCategoryName.text = categoryNames[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCategory = self.categoryNames[indexPath.row]
        print(selectedCategory)
        
        let categorySearchVC = storyboard?.instantiateViewController(withIdentifier: "categorySearchVC") as? CategorySelectedNSearchViewController
        
        categorySearchVC?.selectedCategory = selectedCategory
        
        self.navigationController?.pushViewController(categorySearchVC!, animated: true)
    }
}
