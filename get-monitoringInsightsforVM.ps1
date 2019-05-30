<#
.SYNOPSIS
Get the monitors for a specific Azure IaaS VM being monitored by VM Insights.

.DESCRIPTION
This script will query a specific Azure IaaS Virtual Machine using the API
to pull all the monitors being used by VM insights. It will then output the
results into a csv file.

.NOTES
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│ ORIGIN STORY                                                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│   DATE        : 2019.05.30
│   AUTHOR      : Brad Watts
│   DESCRIPTION : Initial Draft
└─────────────────────────────────────────────────────────────────────────────────────────────┘

.PARAMETER subscriptionID
This is the Azure Subscription ID you are querying.

.PARAMETER resourceGroupName
This is the Resource Group Name that contains the Azure IaaS Virtual Machine

.PARAMETER vmName
This is the name of the Azure IaaS Virtual Machine

.PARAMETER outputLocation
This is the path where the csv file will live. 
Use the following format c:\<folder>\

.EXAMPLE

get-monitoringInsightsforVM.ps1 -subscriptionID 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx' -resourceGroupName 'exampleRG' -vmName 'exampleVM' -outputLocation 'c:\temp\'

#>

Param(
    [Parameter(Mandatory = $True)]
    [string]$subscriptionID,
    [Parameter(Mandatory = $True)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $True)]
    [string]$vmName,
    [Parameter(Mandatory = $True)]
    [string]$outputLocation
)
armclient.exe login

$monitors = (armclient.exe GET https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/providers/Microsoft.WorkloadMonitor/monitors?api-version=2018-08-31-preview) | ConvertFrom-Json

$i = 0
while($i -lt 10 -and $monitors.error.code -eq 'GatewayTimeout') {
    $monitors = (armclient.exe GET https://management.azure.com/subscriptions/5f1c1322-cebc-4ea3-8779-fac7d666e18f/resourceGroups/OPSLABRG/providers/Microsoft.Compute/virtualMachines/LABVM/providers/Microsoft.WorkloadMonitor/monitors?api-version=2018-08-31-preview) | ConvertFrom-Json
    $i++
}


$output = @()
foreach($result in $monitors.value) {
    $stringCriteria = ''
    if($result.properties.criteria -ne $null) {
        foreach($criteria in $result.properties.criteria) {
            $stringCriteria += "[$($criteria.healthState),$($criteria.comparisonOperator),$($criteria.threshold)]"
        }
    }

    $obj = [PSCustomObject]@{
        id     = $result.id
        monitorId = $result.properties.monitorId
        monitorType = $result.properties.monitorType
        monitorCategory = $result.properties.monitorCategory
        state = $result.properties.monitorState
        alert = $result.properties.alertGeneration
        frequency = $result.properties.frequency
        lookbackDuration = $result.properties.lookbackDuration
        configurable = $result.properties.configurable
        signalType = $result.properties.signalType
        signalName = $result.properties.signalName
        criteria = $stringCriteria
    }

    $output += $obj
}

$output | Export-Csv -Path "$($outputLocation)$($vmName)_vminsights.csv" -NoTypeInformation

$vms = get-azvm
$vms[0] | fl *