import UIKit

final class BDUIViewMapper: BDUIViewMapperProtocol {
    private weak var actionHandler: BDUIActionHandler?
        
    init(actionHandler: BDUIActionHandler? = nil) {
        self.actionHandler = actionHandler
    }
    
    private struct EnrichedBDUIView: BDUIViewProtocol {
        let type: String
        let content: [String: Any]?
        let subviews: [BDUIView]?
        let actions: [String: BDUIAction]?
    }
    
    func map(viewModel: BDUIViewProtocol) -> UIView {
        let view: UIView
        
        switch viewModel.type {
        case "contentView":
            view = mapContentView(viewModel: viewModel)
        case "stackView":
            view = mapStackView(viewModel: viewModel)
        case "label":
            view = mapLabel(viewModel: viewModel)
        case "imageView":
            view = mapImageView(viewModel: viewModel)
        case "serviceCard":
            view = mapServiceCard(viewModel: viewModel)
        case "button":
            view = mapButton(viewModel: viewModel)
            if let button = view as? UIButton {
                if let parentActions = viewModel.actions,
                   let buttonText = button.title(for: .normal),
                   let action = parentActions[buttonText] {
                    
                    print("Adding action for button: \(buttonText)")
                    button.addAction(UIAction { [weak self] _ in
                        print("Button tapped: \(buttonText)")
                        self?.actionHandler?.handleAction(action)
                    }, for: .touchUpInside)
                } else {
                    print("No action found for button: \(button.title(for: .normal) ?? "")")
                    print("Available actions: \(viewModel.actions?.keys)")
                }
            }
        default:
            view = UIView()
            view.backgroundColor = .red
        }
        
        if let subviews = viewModel.subviews {
            for subviewModel in subviews {
                let enrichedViewModel = EnrichedBDUIView(
                    type: subviewModel.type,
                    content: subviewModel.content,
                    subviews: subviewModel.subviews,
                    actions: viewModel.actions ?? subviewModel.actions
                )
                
                let subview = map(viewModel: enrichedViewModel)
                
                if let stackView = view as? UIStackView {
                    stackView.addArrangedSubview(subview)
                } else {
                    view.addSubview(subview)
                    subview.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        subview.topAnchor.constraint(equalTo: view.topAnchor),
                        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                    ])
                }
            }
        }
        
        return view
    }
    
    private func mapContentView(viewModel: BDUIViewProtocol) -> UIView {
        let view = UIView()
        
        if let content = viewModel.content,
           let backgroundColor = content["backgroundColor"] as? String {
            view.backgroundColor = colorFromString(backgroundColor)
        }
        
        return view
    }
    
    private func mapStackView(viewModel: BDUIViewProtocol) -> UIView {
        guard let content = viewModel.content else { return DSStackView() }
        
        let axisRaw = content["axis"] as? String ?? "vertical"
        let axis: NSLayoutConstraint.Axis = axisRaw == "horizontal" ? .horizontal : .vertical
        
        let spacing = content["spacing"] as? String ?? "medium"
        let stackSpacing = spacingFromString(spacing)
        
        let alignmentRaw = content["alignment"] as? String ?? "fill"
        let alignment: UIStackView.Alignment = {
            switch alignmentRaw {
            case "leading": return .leading
            case "trailing": return .trailing
            case "center": return .center
            case "fill": return .fill
            default: return .fill
            }
        }()
        
        let stackView = DSStackView(axis: axis, spacing: stackSpacing, alignment: alignment)
        
        if let padding = content["padding"] as? String {
            let paddingValue = spacingFromString(padding)
            stackView.layoutMargins = UIEdgeInsets(
                top: paddingValue,
                left: paddingValue,
                bottom: paddingValue,
                right: paddingValue
            )
            stackView.isLayoutMarginsRelativeArrangement = true
        }
        
        return stackView
    }
    
    private func mapLabel(viewModel: BDUIViewProtocol) -> UIView {
        guard let content = viewModel.content else { return DSLabel() }
        
        let text = content["text"] as? String ?? ""
        let typeRaw = content["type"] as? String ?? "body"
        let alignmentRaw = content["alignment"] as? String ?? "left"
        
        let type: DSLabelViewModel.LabelType = {
            switch typeRaw {
            case "largeTitle": return .largeTitle
            case "title": return .title
            case "body": return .body
            case "caption": return .caption
            case "error": return .error
            default: return .body
            }
        }()
        
        let alignment: NSTextAlignment = {
            switch alignmentRaw {
            case "left": return .left
            case "center": return .center
            case "right": return .right
            default: return .left
            }
        }()
        
        let label = DSLabel()
        label.configure(with: DSLabelViewModel(text: text, type: type, textAlignment: alignment))
        return label
    }
    
    private func mapButton(viewModel: BDUIViewProtocol) -> UIView {
        guard let content = viewModel.content else { return DSButton() }
        
        let title = content["text"] as? String ?? ""
        let typeRaw = content["type"] as? String ?? "primary"
        let isLoading = content["isLoading"] as? Bool ?? false
        
        let type: DSButtonViewModel.ButtonType = {
            switch typeRaw {
            case "primary": return .primary
            case "secondary": return .secondary
            case "error": return .error
            default: return .primary
            }
        }()
        
        let button = DSButton()
        button.configure(with: DSButtonViewModel(
            title: title,
            type: type,
            isLoading: isLoading
        ))
        
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
        button.setTitle(title, for: .selected)
        button.setTitle(title, for: .disabled)
        
        if let height = content["height"] as? CGFloat {
            button.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        return button
    }
    
    private func mapImageView(viewModel: BDUIViewProtocol) -> UIView {
        guard let content = viewModel.content else { return UIImageView() }
        
        let imageName = content["imageName"] as? String ?? ""
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        if let tintColor = content["tintColor"] as? String {
            imageView.tintColor = colorFromString(tintColor)
        }
        
        if let height = content["height"] as? CGFloat {
            imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let width = content["width"] as? CGFloat {
            imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        return imageView
    }
    
    private func mapServiceCard(viewModel: BDUIViewProtocol) -> UIView {
        guard let content = viewModel.content else { return UIView() }
        
        let title = content["title"] as? String ?? ""
        let subtitle = content["subtitle"] as? String ?? ""
        let iconName = content["iconName"] as? String ?? ""
        let icon = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        
        let stackView = DSStackView(axis: .vertical, spacing: DSSpacing.medium)
        stackView.alignment = .center
        
        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = DSColors.primary
        iconView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let titleLabel = DSLabel()
        titleLabel.configure(with: DSLabelViewModel(
            text: title,
            type: .body,
            textAlignment: .center
        ))
        
        let subtitleLabel = DSLabel()
        subtitleLabel.configure(with: DSLabelViewModel(
            text: subtitle,
            type: .caption,
            textAlignment: .center
        ))
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        let container = UIView()
        container.backgroundColor = DSColors.background
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = DSColors.primaryLight.cgColor
        
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: DSSpacing.large),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: DSSpacing.medium),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -DSSpacing.medium),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -DSSpacing.large)
        ])
        
        return container
    }
    
    private func colorFromString(_ colorString: String) -> UIColor {
        switch colorString {
        case "primary": return DSColors.primary
        case "primaryLight": return DSColors.primaryLight
        case "error": return DSColors.error
        case "textPrimary": return DSColors.textPrimary
        case "textSecondary": return DSColors.textSecondary
        case "background": return DSColors.background
        case "white": return .white
        default: return .black
        }
    }
    
    private func spacingFromString(_ spacingString: String) -> CGFloat {
        switch spacingString {
        case "small": return DSSpacing.small
        case "medium": return DSSpacing.medium
        case "large": return DSSpacing.large
        case "xLarge": return DSSpacing.xLarge
        default: return DSSpacing.medium
        }
    }
}
