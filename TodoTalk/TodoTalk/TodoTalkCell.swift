import UIKit

class TodoTalkCell: UITableViewCell {
    @IBOutlet weak var dateCheckView: UIView!  // 기한 일자 or 체크표시
    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var todoContentLabel: UILabel!
    
    
    // awakeFromNib: Storyboard 기반으로 셀을 만들었을 때 호출됨.
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
