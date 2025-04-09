import UIKit

class DSStackView: UIStackView {
    init(axis: NSLayoutConstraint.Axis = .vertical,
         spacing: CGFloat = DSSpacing.medium,
         alignment: UIStackView.Alignment = .fill,
         distribution: UIStackView.Distribution = .fill) {
        super.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
