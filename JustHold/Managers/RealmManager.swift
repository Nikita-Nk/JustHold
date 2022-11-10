import UIKit
import RealmSwift

final class RealmManager {
    
    static let shared = RealmManager()
    
    private lazy var realm: Realm = {
        do {
            return try Realm()
        }
        catch let error as NSError {
            print(error)
        }
        return self.realm
    }()
    
//    public enum Types {
//        case AlertModel
//    }
    
    private init() {}
    
    //MARK: - Public
    
    public func fetchAllAlerts() -> List<AlertModel> { // Results / List
        let alerts = realm.objects(AlertModel.self)
        let alertsList = List<AlertModel>()
        for alert in alerts {
            alertsList.append(alert)
        }
        return alertsList
    }
    
    public func updateAlert(_ block: () -> ()) {
        do {
            if !realm.isInWriteTransaction {
                try realm.write(block)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    public func saveNewAlert(_ alert: AlertModel) {
        do {
            try realm.write {
                realm.add(alert)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    public func deleteAlert(_ alert: AlertModel) {
        do {
            try realm.write {
                realm.delete(alert)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}
