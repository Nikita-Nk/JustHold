import UIKit

final class RankLabel: UILabel {
    // Размер фона у Label автоматически установливается с запасом вне зависимости от длины текста
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 6
        return CGSize(width: originalContentSize.width + 14, height: height)
    }
}
