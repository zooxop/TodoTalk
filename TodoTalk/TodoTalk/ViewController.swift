// Core data
// messageKit
// calendar


import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var talkTableView: UITableView!
    
    // App delegate 접근
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    var todoTalks = [TodoTalk]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "To-Do Talk"
        
        self.talkTableView.delegate = self
        self.talkTableView.dataSource = self
        
        self.makeNavigationBar()
        
        self.fetchTodoTalks()  // coredata - 데이터 가져오기
        self.talkTableView.reloadData()
    }
    
    func makeNavigationBar() {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddTalkVC))
        self.navigationItem.rightBarButtonItem = item
        
    }
    
    @objc func presentAddTalkVC() {
        let addTalkVC = AddTalkVC.init(nibName: "AddTalkVC", bundle: nil)
        
        addTalkVC.delegate = self
        self.present(addTalkVC, animated: true, completion: nil)
    }
    
    func fetchTodoTalks() {
        self.todoTalks = CoredataManager.shared.getTodoTalks(ascending: false, isFinished: false)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoTalks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTalkCell", for: indexPath) as! TodoTalkCell
        
        cell.todoTitleLabel.text = todoTalks[indexPath.row].title
        // cell.todoContentLabel.text = todoTalks[indexPath.row].  // 마지막 채팅 내용이 보여야 함
        cell.todoContentLabel.text = todoTalks[indexPath.row].selectedDate?.description ?? ""  // 임시
        cell.dateCheckView.layer.cornerRadius = cell.dateCheckView.bounds.height / 2
        
        if todoTalks[indexPath.row].isUseDate {
            cell.dateCheckView.layer.backgroundColor = CGColor.init(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
        } else {
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell 클릭 이벤트
        // Talk 화면으로 넘어가는 코딩 필요.
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // 스와이프 이벤트
    // 오른쪽에 스와이프 버튼 만들기
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteTalk = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            
            // talk delete 이벤트 달기
            // coredata 매니저 클래스 만들어서 분리하기.
            CoredataManager.shared.updateTalkFinished(talkData: self.todoTalks[indexPath.row], isFinished: true)
            self.todoTalks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            success(true)
        }
        deleteTalk.backgroundColor = .systemRed
        
        //actions배열 인덱스 0이 왼쪽에 붙어서 나옴
        return UISwipeActionsConfiguration(actions:[deleteTalk])
    }
    
}

// Add 팝업 페이지 delegate
extension ViewController: AddTalkVCDelegate {
    func didFinishSaveData() {
        self.fetchTodoTalks()
        self.talkTableView.reloadData()
    }
}
