protocol ServiceManagerProtocol {
    func fetchServices(completion: @escaping(Result<[Service], Error>) -> Void)
}
