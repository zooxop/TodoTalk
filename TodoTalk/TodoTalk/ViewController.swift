// Core data
// messageKit
// calendar
// toast-swift


import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var talkTableView: UITableView!
    
    // App delegate 접근
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        let fetchRequest: NSFetchRequest<TodoTalk> = TodoTalk.fetchRequest()
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            self.todoTalks = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
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
        cell.dateCheckView.layer.cornerRadius = cell.dateCheckView.bounds.height / 2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // cell 클릭 이벤트
        // Talk 화면으로 넘어가는 코딩 필요.
        
        talkTableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// Add 팝업 페이지 delegate
extension ViewController: AddTalkVCDelegate {
    func didFinishSaveData() {
        self.fetchTodoTalks()
        self.talkTableView.reloadData()
    }
}
