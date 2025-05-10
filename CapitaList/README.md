# CapitaList

CapitaList is a Swift iOS application that allows users to search, save, and view details about countries around the world. The app automatically detects the user's location to suggest the initial country and supports managing a curated list of up to 5 countries.

## Features

- Location-based country detection
- Country search functionality with real-time filtering
- Detailed country information including capital, currency, and location
- Save up to 5 favorite countries for quick access
- Clean and modern SwiftUI interface

## Architecture

The application follows the MVVM (Model-View-ViewModel) architecture pattern with a Coordinator for navigation management. It's structured into the following main components:

### Core

- **Models**: Defines the data structures (Country, Currency, Location)
- **ViewState**: Enum for representing UI states (idle, loading, loaded, error)
- **Protocols**: Interfaces for network and storage operations
- **AppCoordinator**: Manages navigation flow between screens
- **LocationService**: Handles user location detection

### Views

- **MainView**: Displays the list of saved countries
- **SearchView**: Allows searching and selecting countries
- **CountryDetailView**: Shows detailed information about a selected country

### Repositories

- **CountryRepository**: Handles data operations for countries
- **Network**: Manages API requests to fetch country data
- **Storage**: Persists user selections locally

## Data Flow

1. The app starts with the `AppCoordinator` instantiating the main navigation 
2. `MainViewModel` loads saved countries or attempts to detect the user's location
3. Users can add countries through the search screen (limited to 5 maximum)
4. Country data is fetched from a remote API and cached locally
5. Country selections persist between app launches

## Dependencies

The app uses:
- SwiftUI for the user interface
- Combine for reactive programming
- Core Location for user positioning
- Swift's built-in networking capabilities

## Project Structure

```
CapitaList/
├── Core/
│   ├── Models/
│   │   └── Country.swift
│   ├── LocationService/
│   ├── AppCoordinator.swift
│   └── ViewModelFactory.swift
├── MainScreen/
│   ├── MainView.swift
│   └── MainViewModel.swift
├── SearchView/
│   ├── CountrySearchView.swift
│   └── SearchViewModel.swift
├── Repositories/
│   ├── CountryRepository.swift
│   ├── Network/
│   └── Storage/
└── CapitaListApp.swift
``` 