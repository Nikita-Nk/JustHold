import UIKit

final class RankLabel: UILabel {
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 6
        return CGSize(width: originalContentSize.width + 14, height: height)
    }
}
