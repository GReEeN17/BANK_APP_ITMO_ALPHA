protocol ConfigurableView {
    associatedtype ViewModel
    func configure(with viewModel: ViewModel)
}
