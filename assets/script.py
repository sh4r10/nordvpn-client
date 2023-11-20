import os

# Mapping of country codes to country names
country_mapping = {
    'AL': 'albania',
    'AR': 'argentina',
    'AT': 'austria',
    'AU': 'australia',
    'BA': 'bosnia_and_herzegovina',
    'BE': 'belgium',
    'BG': 'bulgaria',
    'BR': 'brazil',
    'CA': 'canada',
    'CH': 'switzerland',
    'CL': 'chile',
    'CO': 'colombia',
    'CR': 'costa_rica',
    'HR': 'croatia',
    'CY': 'cyprus',
    'CZ': 'czech_republic',
    'DE': 'germany',
    'DK': 'denmark',
    'EE': 'estonia',
    'ES': 'spain',
    'FI': 'finland',
    'FR': 'france',
    'GE': 'georgia',
    'GR': 'greece',
    'HK': 'hong_kong',
    'HU': 'hungary',
    'ID': 'indonesia',
    'IE': 'ireland',
    'IL': 'israel',
    'IT': 'italy',
    'JP': 'japan',
    'KR': 'south_korea',
    'LV': 'latvia',
    'LT': 'lithuania',
    'LU': 'luxembourg',
    'MK': 'north_macedonia',
    'MY': 'malaysia',
    'MX': 'mexico',
    'NL': 'netherlands',
    'NO': 'norway',
    'NZ': 'new_zealand',
    'PL': 'poland',
    'PT': 'portugal',
    'RO': 'romania',
    'RS': 'serbia',
    'SG': 'singapore',
    'SI': 'slovenia',
    'SK': 'slovakia',
    'TH': 'thailand',
    'TR': 'turkey',
    'TW': 'taiwan',
    'UA': 'ukraine',
    'US': 'united_states',
    'VN': 'vietnam',
    'ZA': 'south_africa',
    'GB': 'united_kingdom',
}

# Get the current directory
current_directory = os.getcwd()

# List all files in the current directory
files = os.listdir(current_directory)

# Filter only .svg files
svg_files = [file for file in files if file.lower().endswith('.svg')]

# Rename each .svg file based on the country code
for svg_file in svg_files:
    country_code = os.path.splitext(svg_file)[0].upper()
    country_name_lowercase = country_mapping.get(country_code, None)

    if country_name_lowercase:
        new_file_name = f"{country_name_lowercase}.svg"
        old_file_path = os.path.join(current_directory, svg_file)
        new_file_path = os.path.join(current_directory, new_file_name)

        # Rename the file
        os.rename(old_file_path, new_file_path)
        print(f"Renamed {svg_file} to {new_file_name}")
    else:
        print(f"No mapping found for country code: {country_code}")

