
import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var btnGoTownSetting: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnGoTownSetting.layer.cornerRadius = 5
    }
  
    @IBAction func pushFindTownVC() {
        let findTownVC = self.storyboard?.instantiateViewController(withIdentifier: "findTownVC") as! FindTownViewController
        
        self.navigationController?.pushViewController(findTownVC, animated: true)
    }

}

// https://zeddios.tistory.com/157


