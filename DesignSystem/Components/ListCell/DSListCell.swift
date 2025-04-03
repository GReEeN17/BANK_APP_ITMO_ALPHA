import UIKit

final class DSListCell: UITableViewCell, ConfigurableCell {
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = DSLabel()
    private let subtitleLabel = DSLabel()
    private let stackView = DSStackView(axis: .horizontal, spacing: DSSpacing.medium)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: DSListCellModel) {
        titleLabel.configure(with: DSLabelViewModel(
            text: model.title,
            type: .body,
            textAlignment: .left
        ))
        
        subtitleLabel.configure(with: DSLabelViewModel(
            text: model.subtitle,
            type: .caption,
            textAlignment: .left
        ))
        
        iconImageView.image = model.icon
        iconImageView.tintColor = model.isSelected ? DSColors.primary : DSColors.textSecondary
        containerView.backgroundColor = model.isSelected ?
            DSColors.primary.withAlphaComponent(0.1) :
            DSColors.background
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let textStack = DSStackView(axis: .vertical, spacing: DSSpacing.small)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        
        stackView.alignment = .center
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textStack)
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DSSpacing.small),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DSSpacing.medium),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DSSpacing.medium),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DSSpacing.small),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: DSSpacing.medium),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DSSpacing.medium),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DSSpacing.medium),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -DSSpacing.medium)
        ])
    }
}
