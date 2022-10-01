import UIKit
import RealmSwift

final class RealmManager {
    
    static let shared = RealmManager()
    
    private let realm = try! Realm()
    
//    public enum Types {
//        case AlertModel
//    }
    
    private init() {}
    
    //MARK: - Public
    
    public func fetchAllAlerts() -> Results<AlertModel> { // type: Types
        let alerts = realm.objects(AlertModel.self)
        return alerts
    }
    
    public func saveNewAlert(_ alert: AlertModel) {
        try! realm.write {
            realm.add(alert)
        }
    }
    
    public func deleteAlert(_ alert: AlertModel) {
        try! realm.write {
            realm.delete(alert)
        }
    }
}
