# Retrieve the sensor data from the OpenHardwareMonitor namespace
$sensors = Get-WmiObject -Namespace root\OpenHardwareMonitor -Query "SELECT Name, Value FROM Sensor WHERE SensorType='Temperature'"

# Filter the result to find the temperature for "CPU Core"
$cpuCoreTemp = $sensors | Where-Object { $_.Name -eq "CPU Core" } | Select-Object -ExpandProperty Value

# Output only the temperature value
Write-Output $cpuCoreTemp
