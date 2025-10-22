//
//  HomeView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.
//


/// HomeView.swift
/// Displays current weather, a daily forecast list, and a favourites toggle.
/// Uses environment-injected view models for weather data and favourites management.
//
import SwiftUI

/// The main home screen showing current conditions, a background image themed to the weather,
/// a min/current/max summary, and a list of upcoming daily forecasts.
///
/// - Requires `WeatherManagerViewModel` and `FavoritesStoreViewModel` via `@EnvironmentObject`.
struct HomeView: View {
    /// Provides current weather, forecast data, and derived presentation values like `weatherType`.
    @EnvironmentObject var vm: WeatherManagerViewModel
    /// Manages the user's favourite locations, including querying and updating favourites.
    @EnvironmentObject var favoritesStoreViewModel:FavoritesStoreViewModel
    
    
    /// Composes the weather UI with a themed background, header image and temperature, summary triplet,
    /// a daily forecast list, and a favourites toggle button overlay.
    var body: some View {
        ZStack {
            // Themed background color based on current weather type
            vm.weatherType.color.ignoresSafeArea()
            VStack(spacing: 0) {
                
                GeometryReader { proxy in
                    ZStack {
                        // Weather-themed background image filling the top section
                        Image(vm.weatherType.backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                        
                        // Current apparent temperature and weather description
                        VStack(spacing: 8) {
                            
                            Text(vm.currentWeather?.feelsLikeCelsius?.asTemp ?? "0°")
                                .foregroundStyle(.white)
                                .font(.system(size: 64, weight: .semibold, design: .rounded))
                            
                            Text(vm.weatherType.rawValue)
                                .foregroundStyle(.white)
                                .font(.title3.weight(.semibold))
                                .kerning(2)
                        }
                        
                       
                    }
                    .frame(maxWidth: .infinity, maxHeight: proxy.size.height / 1.5)
                }
                
                // Summary triplet (min/current/max) and upcoming daily forecast list
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        // Show min, current (feels like), and max temperatures side-by-side
                        TripletItem(value: vm.currentWeather?.minCelsius?.asTemp ?? "0°", label: "Min")
                        Spacer()
                        TripletItem(value: vm.currentWeather?.feelsLikeCelsius?.asTemp ?? "0°", label: "Current")
                        Spacer()
                        TripletItem(value: vm.currentWeather?.maxCelsius?.asTemp ?? "0°", label: "Max")
                    }
                    .font(.callout)
                    .padding(.horizontal, 16)
                    .padding(.top, -24)
                    
                    Divider()
                        .frame(height: 2)
                        .background(Color.white.opacity(0.8))
                    
                 
                    // Daily forecast list with day label, icon, and max temperature
                    List(vm.dailyForecasts) { day in
                        HStack {
                            // Day name (e.g., Mon, Tue)
                            Text(day.day)
                                .foregroundStyle(.white)
                                .frame(width: 100,alignment: .leading)
                            Spacer(minLength: 0)
                            // Small weather icon for the day
                            Image(day.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer(minLength: 0)
                            // Max temperature for the day
                            Text(day.maxTemp.asTemp)
                                .foregroundStyle(.white)
                                .frame(width: 100,alignment: .trailing)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(vm.weatherType.color)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(vm.weatherType.color)
                    .clipped()
                    
                    // Overlay favourites toggle aligned to the top trailing corner
                    VStack {
                        HStack {
                            Spacer()
                            // Toggle favourite for the current location; update store and current selection
                            Button(action: {
                                // If already a favourite, remove it and clear current favourite; otherwise add and set it
                                if favoritesStoreViewModel.isFavorite(lat: vm.getFavourite().lat, log:  vm.getFavourite().log) {
                                    favoritesStoreViewModel.setCurrentFavorite(nil)
                                   favoritesStoreViewModel.removeFavorite(lat: vm.getFavourite().lat, long:  vm.getFavourite().log)
                                } else {
                                    favoritesStoreViewModel.setCurrentFavorite(vm.getFavourite())
                                    favoritesStoreViewModel.addFavorite(vm.getFavourite())
                                  
                                }
                                
                            }) {
                                // Heart icon reflects favourite status and uses material background
                                Image(systemName:  favoritesStoreViewModel.isFavorite(lat: vm.getFavourite().lat, log:  vm.getFavourite().log) ? "heart.fill" : "heart")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle( favoritesStoreViewModel.isFavorite(lat: vm.getFavourite().lat, log:  vm.getFavourite().log) ? .red : .white)
                                    .padding(10)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                            .tabTapFeedback()
                        }
                      
                    }
                    .frame(maxHeight: 20)
                }
            }
        }
    }
}


/// Preview helpers and configuration
let previewWeatherManagerViewModel = WeatherManagerViewModel(weatherManager: .init(apiService:APIClient.shared), locationManager: .init())

/// Renders HomeView with mock environment objects for design-time preview.
#Preview {
    HomeView()
        .environmentObject(previewWeatherManagerViewModel)
        .environmentObject(FavoritesStoreViewModel())
}

