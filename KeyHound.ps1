# Google Maps API Endpoint Tester
# Made by b0tmtl 2025
# This script tests various Google Maps API endpoints with a provided API key

function Show-Banner {
    Write-Host @"
    
 __                 .__                             .___
|  | __ ____ ___.__.|  |__   ____  __ __  ____    __| _/
|  |/ // __ <   |  ||  |  \ /  _ \|  |  \/    \  / __ | 
|    <\  ___/\___  ||   Y  (  <_> )  |  /   |  \/ /_/ | 
|__|_ \\___  > ____||___|  /\____/|____/|___|  /\____ | 
     \/    \/\/          \/                  \/      \/ 

     KeyHound - Google API Key Hunter v1.0
     Made with <3 by b0tmtl
"@ -ForegroundColor Cyan
}

# Example usage:
Show-Banner

# Prompt for API key and platform
$apiKey = Read-Host -Prompt 'Please enter your Google Maps API key'
$platform = Read-Host -Prompt 'Is this for mobile or web testing? (Enter mobile/web)'

# Variables for mobile headers
$androidPackage = ""
$androidCert = ""

if ($platform.ToLower() -eq "mobile") {
    $apkPath = Read-Host -Prompt 'Enter the name of the APK file (it should be in the current folder)'
    
    # Get SHA-1 certificate
    Write-Host "Getting APK certificate..."
    $certInfo = & java -jar "Resources\apksigner.jar" verify --print-certs $apkPath
    $sha1Line = $certInfo | Where-Object { $_ -match "Signer #1 certificate SHA-1 digest: " }
    if ($sha1Line) {
        $androidCert = ($sha1Line -split ": ")[1].Trim()
        Write-Host "Found SHA-1: $androidCert"
    } else {
        Write-Host "Error: Could not extract SHA-1 certificate" -ForegroundColor Red
        exit
    }
    
    # Get package name
    Write-Host "Getting package name..."
    $packageInfo = & "Resources\aapt.exe" dump badging $apkPath | findstr package
    if ($packageInfo -match "package: name='([^']+)'") {
        $androidPackage = $matches[1]
        Write-Host "Found package name: $androidPackage"
    } else {
        Write-Host "Error: Could not extract package name" -ForegroundColor Red
        exit
    }
}

# Array of endpoints to test
$endpoints = @(
    @{
        Name = "Static Maps"
        URL = "https://maps.googleapis.com/maps/api/staticmap?center=45%2C10&zoom=7&size=400x400&key=$apiKey"
        Cost = '$2/1000 requests'
    },
    @{
        Name = "Street View"
        URL = "https://maps.googleapis.com/maps/api/streetview?size=400x400&location=40.720032,-73.988354&fov=90&heading=235&pitch=10&key=$apiKey"
        Cost = '$7/1000 requests'
    },
    @{
        Name = "Embed"
        URL = "https://www.google.com/maps/embed/v1/place?q=place_id:ChIJyX7muQw8tokR2Vf5WBBk1iQ&key=$apiKey"
        Cost = 'Varies/1000 requests'
    },
    @{
        Name = "Directions"
        URL = "https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood4&key=$apiKey"
        Cost = '$5/1000 requests'
    },
    @{
        Name = "Geocoding"
        URL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=40,30&key=$apiKey"
        Cost = '$5/1000 requests'
    },
    @{
        Name = "Distance Matrix"
        URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C-73.9976592&key=$apiKey"
        Cost = '$5/1000 requests'
    },
    @{
        Name = "Find Place"
        URL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=Museum%20of%20Contemporary%20Art%20Australia&inputtype=textquery&fields=photos,formatted_address,name,rating,opening_hours,geometry&key=$apiKey"
        Cost = 'Varies/1000 requests'
    },
    @{
        Name = "Autocomplete"
        URL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Bingh&types=%28cities%29&key=$apiKey"
        Cost = 'Varies/1000 requests'
    },
    @{
        Name = "Elevation"
        URL = "https://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&key=$apiKey"
        Cost = '$5/1000 requests'
    },
    @{
        Name = "Timezone"
        URL = "https://maps.googleapis.com/maps/api/timezone/json?location=39.6034810,-119.6822510&timestamp=1331161200&key=$apiKey"
        Cost = '$5/1000 requests'
    },
    @{
        Name = "Roads"
        URL = "https://roads.googleapis.com/v1/nearestRoads?points=60.170880,24.942795|60.170879,24.942796|60.170877,24.942796&key=$apiKey"
        Cost = '$10/1000 requests'
    },
    @{
        Name = "Geolocate"
        URL = "https://www.googleapis.com/geolocation/v1/geolocate?key=$apiKey"
        Cost = '$5/1000 requests'
    }
)

# Add a list to store successful endpoints
$successfulEndpoints = @()

# Function to test endpoint
function Test-Endpoint {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$EndpointInfo
    )
    
    Write-Host "`nTesting $($EndpointInfo.Name) API (Cost: $($EndpointInfo.Cost))" -ForegroundColor Cyan
    Write-Host "URL: $($EndpointInfo.URL)" -ForegroundColor Gray
    
    try {
        # Set up headers based on platform
        if ($platform.ToLower() -eq "mobile") {
            $headers = @{
                "X-Android-Package" = $androidPackage
                "X-Android-Cert" = $androidCert
                "User-Agent" = "Dalvik/2.1.0 (Linux; U; Android 12; Device Model)"
            }
        } else {
            $headers = @{}
        }

        $response = Invoke-WebRequest -Uri $EndpointInfo.URL -Method GET -Headers $headers -UseBasicParsing
        $content = $response.Content
        
        # Try to parse as JSON if possible
        try {
            $jsonContent = $content | ConvertFrom-Json
            
            # Check for various error responses
            if ($jsonContent.error) {
                Write-Host "Error detected in response:" -ForegroundColor Red
                Write-Host "Code: $($jsonContent.error.code)" -ForegroundColor Red
                Write-Host "Message: $($jsonContent.error.message)" -ForegroundColor Red
            }
            elseif ($jsonContent.status -eq "REQUEST_DENIED") {
                Write-Host "Request Denied:" -ForegroundColor Red
                Write-Host "Error Message: $($jsonContent.error_message)" -ForegroundColor Red
            }
            elseif ($jsonContent.errorMessage) {
                Write-Host "Error Message: $($jsonContent.errorMessage)" -ForegroundColor Red
            }
            elseif ($response.StatusCode -eq 200 -and ($jsonContent.status -eq "OK" -or -not $jsonContent.status)) {
                Write-Host "Response Status: SUCCESS" -ForegroundColor Green
                Write-Host "Response Preview:" -ForegroundColor Yellow
                $jsonContent | ConvertTo-Json -Depth 1 | Write-Host
                # Add to successful endpoints
                $script:successfulEndpoints += @{
                    Name = $EndpointInfo.Name
                    Cost = $EndpointInfo.Cost
                }
            }
            else {
                Write-Host "Response received but status not OK" -ForegroundColor Yellow
                $jsonContent | ConvertTo-Json -Depth 1 | Write-Host
            }
        }
        catch {
            # For non-JSON responses, check status code
            if ($response.StatusCode -eq 200) {
                Write-Host "Response received (non-JSON) - Length: $($content.Length) bytes" -ForegroundColor Green
                # Add to successful endpoints
                $script:successfulEndpoints += @{
                    Name = $EndpointInfo.Name
                    Cost = $EndpointInfo.Cost
                }
            }
            else {
                Write-Host "Response received (non-JSON) but status not 200" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "Request Failed:" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.ErrorDetails.Message) {
            try {
                $errorJson = $_.ErrorDetails.Message | ConvertFrom-Json
                Write-Host "API Error Message: $($errorJson.error_message)" -ForegroundColor Red
            }
            catch {
                Write-Host "Error Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
            }
        }
    }
    Write-Host ("-" * 80)
}

# Main execution
Write-Host "Starting Google Maps API endpoint tests..." -ForegroundColor Green
Write-Host "Testing $($endpoints.Count) endpoints..."
Write-Host "Platform: $platform"
if ($platform.ToLower() -eq "mobile") {
    Write-Host "Package Name: $androidPackage"
    Write-Host "Certificate: $androidCert"
}
Write-Host ("-" * 80)

foreach ($endpoint in $endpoints) {
    Test-Endpoint -EndpointInfo $endpoint
    # Add a small delay between requests to avoid rate limiting
    Start-Sleep -Milliseconds 500
}

Write-Host "`nTesting completed!" -ForegroundColor Green
# TLDR Summary
Write-Host "`n=== TLDR SUMMARY ===" -ForegroundColor Cyan
Write-Host "Successfully tested $($successfulEndpoints.Count) endpoints:" -ForegroundColor Green
foreach ($endpoint in $successfulEndpoints) {
    Write-Host "✓ $($endpoint.Name) - Cost: $($endpoint.Cost)" -ForegroundColor Green
}

# Pause at the end
Pause