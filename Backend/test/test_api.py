import requests

BASE_URL = "http://localhost:5001"

def test_endpoint(path, description):
    url = f"{BASE_URL}{path}"
    try:
        response = requests.get(url)
        status = response.status_code

        if status == 200:
            data = response.json()

            # For big datasets, only show summary
            if "data" in data and isinstance(data["data"], list):
                print(f"[✅ OK] {description}: {status} - {len(data['data'])} records")
            elif "devices" in data:
                print(f"[✅ OK] {description}: {status} - {data['total_devices']} devices")
            elif "sensors" in data:
                print(f"[✅ OK] {description}: {status} - {data['total_sensors']} sensors")
            else:
                print(f"[✅ OK] {description}: {status}")
        else:
            print(f"[❌ FAIL] {description}: {status}")
    except Exception as e:
        print(f"[❌ ERROR] {description}: {e}")

if __name__ == "__main__":
    print("Running backend tests...\n")

    test_endpoint("/", "Root (API docs)")
    test_endpoint("/sensors", "Sensors list")
    test_endpoint("/devices", "Devices list")
    test_endpoint("/data", "All data")
    test_endpoint("/data?sensor=temperature", "Temperature data")

    print("\n✅ Test run completed")