import UIKit

struct CheckBoxButtonViewModel {
    let text: String
}

class CheckBoxButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setImage(UIImage(systemName: "square"), for: .normal)
        setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        contentHorizontalAlignment = .left

        var config = UIButton.Configuration.plain()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            return outgoing
        }
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in
            return self.isSelected ? UIColor.systemBlue : UIColor.systemGray.withAlphaComponent(0.6)
        }
        config.background.backgroundColor = .clear
        config.baseForegroundColor = .label.withAlphaComponent(0.9)
        config.imagePlacement = .leading
        config.imagePadding = 8.0
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with viewModel: CheckBoxButtonViewModel) {
        self.setTitle(viewModel.text, for: .normal)
    }
}
