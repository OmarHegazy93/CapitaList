//
//  CountryDetailView.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import SwiftUI

struct CountryDetailView: View {
    let country: Country
    let coordinator: CountryDetailCoordinator
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Flag and country name header
                HStack(spacing: 15) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 60)
                        .overlay(
                            Text(country.code.prefix(2))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(country.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(country.code)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
                
                // Details
                detailSection(title: "Capital", value: country.capital ?? "Unknown")
                
                detailSection(
                    title: "Currencies",
                    value: country.currencyString,
                    subtitle: ""
                )
                
                if let location = country.location {
                    detailSection(
                        title: "Coordinates",
                        value: String(format: "Lat: %.2f", location.latitude),
                        subtitle: String(format: "Long: %.2f", location.longitude)
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Country Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func detailSection(title: String, value: String, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
            
            if let subtitle = subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.top, 4)
        }
    }
} 
