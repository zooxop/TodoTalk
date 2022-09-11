import UIKit
import CoreData

class CoredataManager {
    // singleton
    static let shared: CoredataManager = CoredataManager()
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext

    // 신규 TalkContents 생성하기
    func insertTalkContents(todoTalk: TodoTalk, content: String) {
        if let context = context {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "TalkContents", in: context) else {
                return
            }
            
            guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? TalkContents else {
                return
            }
            
            object.uuid = UUID()
            object.content = content
            object.sendDate = Date()
            
            todoTalk.insertIntoJoinTalkId(object, at: 0)
            
            appDelegate?.saveContext()
        }
    }
    
    // TodoTalk 데이터 가져오기
    func getTodoTalks(ascending: Bool = false, isFinished: Bool) -> [TodoTalk] {
        var models: [TodoTalk] = [TodoTalk]()
        
        if let context = context {
            let dateSort = NSSortDescriptor(key: "createDate", ascending: ascending)
            let fetchRequest: NSFetchRequest<TodoTalk> = TodoTalk.fetchRequest()
            let predicate = NSPredicate(format: "isFinished = %d", isFinished)
            
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [dateSort]  // 정렬 기준
            
            do {
                models = try context.fetch(fetchRequest)

            } catch let error as NSError {
                print("fetch failed: \(error), \(error.userInfo)")
            }
        }
        
        return models
    }
    
    // 신규 TodoTalk 생성하기
    func insertTodoTalk(title: String, isUseDate: Bool, selectedDate: Date?) {
        if let context = context {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "TodoTalk", in: context) else {
                return
            }
            
            guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? TodoTalk else {
                return
            }
            
            object.uuid = UUID()  // UUID: Unique ID
            object.title = title
            object.createDate = Date()  // 현재 날짜
            object.isFinished = false  // 신규생성: 기본값 false
            
            object.isUseDate = isUseDate
            object.selectedDate = selectedDate
            
            appDelegate?.saveContext()
            
        }
        
    }
    
    
    // TodoTalk 완료처리(Update)
    func updateTalkFinished(talkData: TodoTalk, isFinished: Bool) {
        guard let hasUUID = talkData.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<TodoTalk> = TodoTalk.fetchRequest()
        let predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        fetchRequest.predicate = predicate
        
        if let context = context {
            do {
                let loadedData = try context.fetch(fetchRequest)
                
                loadedData.first?.isFinished = isFinished
                
                appDelegate?.saveContext()
                
            } catch let error as NSError {
                print("update failed: \(error), \(error.userInfo)")
            }
        }
        
    }
}
