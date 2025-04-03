import UIKit

final class CustomTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let cellImageView = UIImageView()
    private let selectionIndicator = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        cellImageView.contentMode = .scaleAspectFill
        cellImageView.clipsToBounds = true
        cellImageView.layer.cornerRadius = 8
        
        selectionIndicator.image = UIImage(systemName: "checkmark.circle.fill")
        
        activityIndicator.hidesWhenStopped = true
        cellImageView.addSubview(activityIndicator)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        contentView.addSubview(cellImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(selectionIndicator)
        
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellImageView.widthAnchor.constraint(equalToConstant: 60),
            cellImageView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 12),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: selectionIndicator.leadingAnchor, constant: -8),
            
            selectionIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            selectionIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 24),
            
            activityIndicator.centerXAnchor.constraint(equalTo: cellImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: cellImageView.centerYAnchor)
        ])
    }
    
    func configure(with model: TableCellModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        selectionIndicator.isHidden = !model.isSelected
        
        if let imageUrl = model.imageUrl {
            activityIndicator.startAnimating()
            cellImageView.image = nil
            
            ImageLoader.shared.loadImage(from: imageUrl) { [weak self] image in
                self?.activityIndicator.stopAnimating()
                self?.cellImageView.image = image ?? UIImage(systemName: "photo")
            }
        } else {
            activityIndicator.stopAnimating()
            cellImageView.image = UIImage(systemName: "photo")
        }
    }
}
