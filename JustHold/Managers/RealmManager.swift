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
    
    public func fetchAllAlerts() -> List<AlertModel> { // Results / List
        let alerts = realm.objects(AlertModel.self)
        let alertsList = List<AlertModel>()
        for alert in alerts {
            alertsList.append(alert)
        }
        return alertsList
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
