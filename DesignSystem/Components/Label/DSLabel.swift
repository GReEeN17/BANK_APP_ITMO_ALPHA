import UIKit

class DSLabel: UILabel {
    func configure(with viewModel: DSLabelViewModel) {
        text = viewModel.text
        textAlignment = viewModel.textAlignment
        numberOfLines = 0
        
        switch viewModel.type {
        case .largeTitle:
            font = DSTypography.largeTitle
            textColor = DSColors.textPrimary
        case .title:
            font = DSTypography.title
            textColor = DSColors.textPrimary
        case .body:
            font = DSTypography.body
            textColor = DSColors.textPrimary
        case .caption:
            font = DSTypography.caption
            textColor = DSColors.textSecondary
        case .error:
            font = DSTypography.caption
            textColor = DSColors.error
        }
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}
