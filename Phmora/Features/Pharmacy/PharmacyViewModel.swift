import Foundation
import Combine
import CoreLocation

@MainActor
class PharmacyViewModel: ObservableObject {
    @Published var pharmacies: [Pharmacy] = []
    @Published var filteredPharmacies: [Pharmacy] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCity: String?
    @Published var selectedDistrict: String?
    @Published var availableCities: [String] = []
    
    private let pharmacyService = PharmacyService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        Task {
            await loadPharmacies()
            await loadCities()
        }
    }
    
    private func setupBindings() {
        // PharmacyService'den veri akışını dinle
        pharmacyService.$pharmacies
            .assign(to: \.pharmacies, on: self)
            .store(in: &cancellables)
        
        pharmacyService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        pharmacyService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        // Arama ve filtreleme
        Publishers.CombineLatest3($pharmacies, $searchText, $selectedCity)
            .map { pharmacies, searchText, selectedCity in
                var filtered = pharmacies
                
                // Şehir filtresi
                if let city = selectedCity, !city.isEmpty {
                    filtered = filtered.filter { $0.address.city.lowercased().contains(city.lowercased()) }
                }
                
                // Arama filtresi
                if !searchText.isEmpty {
                    filtered = filtered.filter { pharmacy in
                        pharmacy.name.lowercased().contains(searchText.lowercased()) ||
                        pharmacy.fullAddress.lowercased().contains(searchText.lowercased())
                    }
                }
                
                return filtered
            }
            .assign(to: \.filteredPharmacies, on: self)
            .store(in: &cancellables)
    }
    
    func loadPharmacies() async {
        await pharmacyService.fetchAllPharmacies()
    }
    
    func loadNearbyPharmacies(location: CLLocation) async {
        await pharmacyService.fetchNearbyPharmacies(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    func loadPharmacies(city: String? = nil, district: String? = nil) async {
        await pharmacyService.fetchPharmacies(city: city, district: district)
    }
    
    func loadCities() async {
        pharmacyService.fetchCities()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Cities fetch error: \(error)")
                    }
                },
                receiveValue: { [weak self] cities in
                    Task { @MainActor in
                        self?.availableCities = cities
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshData() async {
        await pharmacyService.refreshData()
    }
    
    func clearError() async {
        await pharmacyService.clearError()
    }
    
    func clearFilters() {
        searchText = ""
        selectedCity = nil
        selectedDistrict = nil
    }
    
    // MARK: - Computed Properties
    
    var pharmaciesWithMedications: [Pharmacy] {
        filteredPharmacies.filter { !$0.availableMedications.isEmpty }
    }
    
    var activePharmacies: [Pharmacy] {
        filteredPharmacies.filter { $0.isActive }
    }
    
    var onDutyPharmacies: [Pharmacy] {
        filteredPharmacies.filter { $0.isOnDuty }
    }
} 