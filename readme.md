Azure VM Insights, also called Azure Monitor for VMs, is a great tool to monitor the core operating system. But knowing exactly what is being monitored and what the thresholds are is not easy from the portal. This script will reach out and query a specific Azure IaaS Virtual Machine and bring back all the monitors being used by Azure VM Insights. 

It will take the results and output them to a csv file formated with <servername>_vminsights.csv. The output will look simular to this:  

Needed|Monitor Id|Type|Category|State|Alert|Frequency|LookBack|Configurable|Signal Type|Signal Name|Criteria
|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
||Microsoft_CPU_TotalCPUUtilization|Unit|PerformanceHealth|Enabled|Enabled|5|12|True|Metrics|VMHealth_% Processor Time|[Error,GreaterThanOrEqual,95.0]
||Microsoft_LogicalDisk_AvailabilityState|Unit|AvailabilityHealth|Enabled|Enabled|0|2|False|Metrics|VMHealth_Availability State|[Error,LessThan,4.0][Error,GreaterThan,4.0]  

To run this script provide the following parameters:

	subscriptionID
	This is the Azure Subscription ID you are querying.

	resourceGroupName
	This is the Resource Group Name that contains the Azure IaaS Virtual Machine

	vmName
	This is the name of the Azure IaaS Virtual Machine

	outputLocation
	This is the path where the csv file will live. Use the following format c:\<folder>\

# EXAMPLE

get-monitoringInsightsforVM.ps1 -subscriptionID 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx' -resourceGroupName 'exampleRG' -vmName 'exampleVM' -outputLocation 'c:\temp\'
