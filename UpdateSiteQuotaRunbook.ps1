#Parameters
param(
    [parameter(Mandatory=$true)]
    [string]$SiteURL,
    [parameter(Mandatory=$true)]
    [int]$storageQuota=100 #100GB
)

#Convert GB to MB   
$storageQuota=$storageQuota*1024 

# Connect to SharePoint Online
write-output "Connect with ClientId and Thumbprint" 

#update tenant and connection credentials here
$c = Connect-PnPOnline -Tenant jasonofterpsys.onmicrosoft.com -Thumbprint 6E9AAEFA4270AC8204C7ABBFD10DB95429B8403C -ClientId c4475ff2-f1f7-404a-9fdd-2548af35e823 -Url $SiteURL

try {
    #Get-PnPTenantSite returns storage quota settings, Get-PnPSite only returns storage usage information
    $site = Get-PnPTenantSite -Connection $c -Url $SiteURL 
    
	Write-Output "Got PnPTenantSite $($site.Url)"
	Write-Output "StorageQuota: $($site.StorageQuota) StorageQuotaWarningLevel:$($site.StorageQuotaWarningLevel)  StorageUsageCurrent:$($site.StorageUsageCurrent)"

	Set-PnPTenantSite -Identity $SiteURL -StorageQuota $storageQuota -StorageQuotaWarningLevel $storageQuota
	
	#There is also a Set-PnPSite cmdlet that can achieve the same thing with slightly different parameter
	#Set-PnPSite -Identity $SiteURL -StorageMaximumLevel $storageQuota -StorageWarningLevel $storageQuota

	#refresh $site, and report updated properties
	$site= Get-PnPTenantSite -Connection $c -Url $SiteURL

	Write-Output "Updated StorageQuota: $($site.StorageQuota) StorageQuotaWarningLevel:$($site.StorageQuotaWarningLevel)  StorageUsageCurrent:$($site.StorageUsageCurrent)"
    Write-Output "Success"
}
catch
{
	write-output "Exception occurred"
	write-output $_
}
Finally{
	#write-output "Disconnect-PnPOnline"
	Disconnect-PnPOnline
}