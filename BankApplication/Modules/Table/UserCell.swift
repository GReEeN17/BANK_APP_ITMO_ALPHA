import UIKit

final class UserCell: UITableViewCell, ConfigurableCell {
    typealias Model = TableCellModel
    
    private let avatarImageView = UIImageView()
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
    
    func configure(with model: UserCellViewModel) {
        titleLabel.configure(with: DSLabelViewModel(
            text: model.title,
            type: .body,
            textAlignment: .left
        ))
        
        subtitleLabel.configure(with: DSLabelViewModel(
            text: model.subtitle ?? "",
            type: .caption,
            textAlignment: .left
        ))
        
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = model.isSelected ? DSColors.primary : DSColors.textSecondary
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let textStack = DSStackView(axis: .vertical, spacing: DSSpacing.small)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        
        stackView.alignment = .center
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(textStack)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DSSpacing.medium),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DSSpacing.large),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DSSpacing.large),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DSSpacing.medium)
        ])
    }
}
