# Disable-SelectedWin11Popups.ps1
# Disables select popups and consumer distractions in Windows 11
# Logs every attempt: success, already set, or failure

function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [object]$Value
    )
    try {
        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
            Write-Host "Created registry key: $Path"
        }

        $currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Name -ErrorAction SilentlyContinue

        if ($currentValue -ne $Value) {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force -ErrorAction Stop
            Write-Host "Set: $Path\$Name = $Value"
        }
        else {
            Write-Host "Unchanged: $Path\$Name is already $Value"
        }
    }
    catch {
        Write-Warning "Failed: $Path\$Name - $_"
    }
}

$registrySettings = @(
    # Current User
    @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name = "SoftLandingEnabled"; Value = 0 },
    @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name = "SubscribedContent-338387Enabled"; Value = 0 },
    @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowSyncProviderNotifications"; Value = 0 },

    # Local Machine
    @{ Path = "HKLM:\Software\Policies\Microsoft\Windows\OOBE"; Name = "DisablePrivacyExperience"; Value = 1 },
    @{ Path = "HKLM:\Software\Policies\Microsoft\Windows\CloudContent"; Name = "DisableWindowsConsumerFeatures"; Value = 1 }
)

Write-Host "`n--- Applying Selected Windows 11 Tweaks ---`n"

foreach ($setting in $registrySettings) {
    Set-RegistryValue -Path $setting.Path -Name $setting.Name -Value $setting.Value
}

Write-Host "`nAll selected registry settings processed.`n"