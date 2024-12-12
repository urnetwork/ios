//
//  ConnectViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import Foundation
import URnetworkSdk
import BottomSheet
import SwiftUI
import Combine

private class FindLocationsCallback: SdkCallback<SdkFindLocationsResult, SdkFindLocationsCallbackProtocol>, SdkFindLocationsCallbackProtocol {
    func result(_ result: SdkFindLocationsResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

enum FetchProvidersError: Error {
    case noProvidersFound
}

extension ConnectView {
    
    class ViewModel: ObservableObject {
        
        /**
         * Bottom sheet
         */
        @Published var bottomSheetPosition: BottomSheetPosition = .absoluteBottom(164)
        let bottomSheetSwitchablePositions: [BottomSheetPosition] = [.absoluteBottom(164), .relativeTop(0.95)]
        
        /**
         * Provider groups
         */
        @Published private(set) var providerCountries: [SdkConnectLocation] = []
        @Published private(set) var providerPromoted: [SdkConnectLocation] = []
        @Published private(set) var providerDevices: [SdkConnectLocation] = []
        @Published private(set) var providerRegions: [SdkConnectLocation] = []
        @Published private(set) var providerCities: [SdkConnectLocation] = []
        @Published private(set) var providerBestSearchMatches: [SdkConnectLocation] = []
        
        /**
         * Selected Provider
         */
        @Published private(set) var selectedProvider: SdkConnectLocation?
        
        func setSelectedProvider(_ provider: SdkConnectLocation?) {
            selectedProvider = provider
            bottomSheetPosition = .absoluteBottom(164)
        }
        
        /**
         * Search
         */
        private var cancellables = Set<AnyCancellable>()
        private var debounceTimer: AnyCancellable?
        @Published var searchQuery: String = ""
        
        
        var api: SdkBringYourApi
        
        init(api: SdkBringYourApi) {
            self.api = api
            
            // when search changes
            // debounce and fire search
            $searchQuery
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .sink { [weak self] query in
                    self?.performSearch(query)
                }
                .store(in: &cancellables)
            
        }
        
        private func performSearch(_ query: String) {
            Task {
                await filterLocations(query)
            }
        }
        
        private func filterLocations(_ query: String) async -> Result<Void, Error> {
            
            if query.isEmpty {
                return await self.getAllProviders()
            } else {
                return await searchProviders(query)
            }
            
        }
        
        private func getAllProviders() async -> Result<Void, Error> {
            
            do {
                
                let result: SdkFilteredLocations = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = FindLocationsCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        let filter = ""
                        let filteredLocations = SdkGetFilteredLocationsFromResult(result, filter)
                        
                        guard let filteredLocations = filteredLocations else {
                            continuation.resume(throwing: FetchProvidersError.noProvidersFound)
                            return
                        }
                        
                        continuation.resume(returning: filteredLocations)
                        
                    }
                    
                    api.getProviderLocations(callback)
                }
                
                self.handleLocations(result)
                
                return .success(())
                
            } catch (let error) {
                return .failure(error)
            }
            
        }
        
        private func searchProviders(_ query: String) async -> Result<Void, Error> {
            do {
                
                let result: SdkFilteredLocations = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = FindLocationsCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        let filteredLocations = SdkGetFilteredLocationsFromResult(result, query)
                        
                        guard let filteredLocations = filteredLocations else {
                            continuation.resume(throwing: FetchProvidersError.noProvidersFound)
                            return
                        }
                        
                        continuation.resume(returning: filteredLocations)
                        
                    }
                    
                    let args = SdkFindLocationsArgs()
                    args.query = query
                    
                    api.findProviderLocations(args, callback: callback)
                }
                
                self.handleLocations(result)
                
                return .success(())
                
            } catch (let error) {
                return .failure(error)
            }
        }
        
        private func handleLocations(_ result: SdkFilteredLocations) {
            DispatchQueue.main.async {
                self.providerCountries.removeAll()
                self.providerPromoted.removeAll()
                self.providerDevices.removeAll()
                self.providerRegions.removeAll()
                self.providerCities.removeAll()
                self.providerBestSearchMatches.removeAll()
                
                if let countries = result.countries {
                    self.providerCountries.append(contentsOf: self.flattenConnectLocationList(countries))
                }
                
                if let promoted = result.promoted {
                    self.providerPromoted.append(contentsOf: self.flattenConnectLocationList(promoted))
                }
                
                if let devices = result.devices {
                    self.providerDevices.append(contentsOf: self.flattenConnectLocationList(devices))
                }
                
                if let regions = result.regions {
                    self.providerRegions.append(contentsOf: self.flattenConnectLocationList(regions))
                }
                
                if let cities = result.cities {
                    self.providerCities.append(contentsOf: self.flattenConnectLocationList(cities))
                }
                
                if let bestMatches = result.bestMatches {
                    self.providerBestSearchMatches.append(contentsOf: self.flattenConnectLocationList(bestMatches))
                }
                
            }
        }
        
        private func flattenConnectLocationList(_ connectLocationList: SdkConnectLocationList) -> [SdkConnectLocation] {
            
            var locations: [SdkConnectLocation] = []
            let len = connectLocationList.len()
            
            // ensure not an empty list
            if len > 0 {
                
                // loop
                for i in 0..<len {
                    
                    // unwrap connect location
                    if let location = connectLocationList.get(i) {
                        
                        // append to the connect location array
                        locations.append(location)
                    }
                }
            }
            
            return locations
            
        }
        
        func getProviderColor(_ provider: SdkConnectLocation) -> Color {
            return Color(hex: SdkGetColorHex(
                provider.locationType == SdkLocationTypeCountry ? provider.countryCode : provider.connectLocationId?.string()
            ))
        }
        
    }
    
}
