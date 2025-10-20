//
//  HomeView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: WeatherManagerViewModel
    @EnvironmentObject var favoritesStoreViewModel:FavoritesStoreViewModel
    
    
    var body: some View {
        ZStack {
            vm.weatherType.color.ignoresSafeArea()
            VStack(spacing: 0) {
                
                GeometryReader { proxy in
                    ZStack {
                        Image(vm.weatherType.backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                        
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
                
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
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
                    
                 
                    List(vm.dailyForecasts) { day in
                        HStack {
                            Text(day.day)
                                .foregroundStyle(.white)
                                .frame(width: 100,alignment: .leading)
                            Spacer(minLength: 0)
                            Image(day.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer(minLength: 0)
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
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                if favoritesStoreViewModel.isFavorite(lat: vm.getFavourite().lat, log:  vm.getFavourite().log) {
                                    favoritesStoreViewModel.setCurrentFavorite(nil)
                                   favoritesStoreViewModel.removeFavorite(lat: vm.getFavourite().lat, long:  vm.getFavourite().log)
                                } else {
                                    favoritesStoreViewModel.setCurrentFavorite(vm.getFavourite())
                                    favoritesStoreViewModel.addFavorite(vm.getFavourite())
                                  
                                }
                                
                            }) {
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


let previewWeatherManagerViewModel = WeatherManagerViewModel(weatherManager: .init(apiService:APIClient.shared), locationManager: .init())

#Preview {
    HomeView()
        .environmentObject(previewWeatherManagerViewModel)
        .environmentObject(FavoritesStoreViewModel())
}
