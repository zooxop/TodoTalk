import UIKit

class TalkVC: UIViewController {

    @IBOutlet weak var talkTableView: UITableView! {
        didSet {
            talkTableView.delegate = self
            talkTableView.dataSource = self
            talkTableView.separatorStyle = .none
            
            talkTableView.register(UINib(nibName: "MyTalkCell", bundle: nil), forCellReuseIdentifier: "MyTalkCell")
        }
    }
    
    var talk: TodoTalk!
    
    lazy var talkContents: [TalkContents]! = {
        return self.talk.joinTalkId?.array as! [TalkContents]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func saveTalkContent(_ sender: Any) {
        CoredataManager.shared.insertTalkContents(todoTalk: self.talk, content: "test")
    }
}

extension TalkVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.talkContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTalkCell", for: indexPath) as! MyTalkCell
        cell.contentTextView.text = self.talkContents[indexPath.row].content
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let sendDateString = dateFormatter.string(from: self.talkContents[indexPath.row].sendDate!)
        cell.dateLabel.text = sendDateString
        
        return cell
    }
    
}
