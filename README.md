# KeyHound

A PowerShell tool for testing Google Maps API key configurations and permissions. KeyHound helps security researchers and developers verify the implementation of their Google Maps API keys across different endpoints.

```
 __                 .__                             .___
|  | __ ____ ___.__.|  |__   ____  __ __  ____    __| _/
|  |/ // __ <   |  ||  |  \ /  _ \|  |  \/    \  / __ | 
|    <\  ___/\___  ||   Y  (  <_> )  |  /   |  \/ /_/ | 
|__|_ \\___  > ____||___|  /\____/|____/|___|  /\____ | 
     \/    \/\/          \/                  \/      \/ 
```

## Features

- Tests 12 different Google Maps API endpoints
- Supports both web and mobile API key testing
- Provides detailed response analysis for each endpoint
- Shows pricing information for each API endpoint
- Automatic APK package name and certificate extraction for Android testing
- TLDR summary of successful endpoints

## Prerequisites

- PowerShell 5.1 or higher
- For mobile testing:
  - Java Runtime Environment (JRE)
  - APK Signer (included in Resources folder)
  - AAPT (included in Resources folder)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/b0tmtl/keyhound.git
```

2. Ensure you have all required tools in the `Resources` folder for mobile testing.

## Usage

1. Run the script in PowerShell:
```powershell
.\KeyHound.ps1
```

2. Enter your API key when prompted

3. Choose testing mode (web/mobile)

4. For mobile testing, provide the APK file name when prompted

## ⚠️ Responsible Usage

This tool is intended for:
- Security researchers with proper authorization
- Developers testing their own API keys
- Bug bounty hunters testing in-scope targets

Do NOT use this tool to:
- Test API keys without explicit permission
- Conduct unauthorized security testing
- Exploit or abuse Google Maps services

## Endpoints Tested

- Static Maps
- Street View
- Embed
- Directions
- Geocoding
- Distance Matrix
- Find Place
- Autocomplete
- Elevation
- Timezone
- Roads
- Geolocate

Each endpoint test includes:
- Response validation
- Error checking
- Cost information
- Response preview (when successful)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Made with ❤️ by b0tmtl

## Acknowledgments

- Google Maps Platform Documentation
- PowerShell Community
