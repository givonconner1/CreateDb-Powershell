##Paramaters
Param(
	[Parameter(Mandatory=$true)][string]$applicationName,
    [string]$environmentDev = 'DEVCI',
    [string]$environmentQa  = 'QA',
    [string]$serverIpDev = '.',
    [string]$serverIpQa = '.',
    [string]$userName = 'sa',
    [string]$filePath = (Get-Item -Path ".\" -Verbose).FullName
)

#Password Prompt
$credential = Get-Credential "$userName"  #Change this when executing remotly
$pass = $credential.GetNetworkCredential().password 

#Create the Database name
Function CreateDbName($environment, $applicationName)
{
    return $environment + '_' + $applicationName -replace '\s',''
}

#Create the db username
Function CreateUsername($environment, $applicationName)
{
    return "$environment-$applicationName user" -replace '\s',''
}

#Create the db passwords (if I assign a variable of $sqlPassword to the GenerateDbPassword function can I merger SaveDb and this function?)
Function GenerateDbPassword()
{
    return -join ((65..90) + (97..122) | Get-Random -Count 28 | % {[char]$_})

}

#Save the database password
Function saveDbPassword($user, $sqlPassword)
{
    Out-File -Append -FilePath "$filePath\GeneratePasswords.txt" -InputObject "$user $sqlPassword" #Outputs the username and password
}


#Pass variables into sql script and execute on the server
Function invokeSql($serverIp, $userName, $pass, $filePath, $sqlParam)
{
    invoke-sqlcmd -ServerInstance $serverIp -Username $userName -Password $pass -inputfile "$filePath\CreateSqlUser.sql" -variable $sqlParam
}

##Variables
$devDb = CreateDbName $environmentDev $applicationName
$qaDb = CreateDbName $environmentQa $applicationName

$devUser = CreateUsername $environmentDev.ToLower().Trim() $applicationName.ToLower()
$qaUser = CreateUsername $environmentQa.ToLower().Trim() $applicationName.ToLower()

$devPwd = GenerateDbPassword
$qaPwd = GenerateDbPassword


$sqlParametersDev = @("user = $devUser", "dbName = $devDb", "sqlPassword = $devPwd")
$sqlParametersQa = @("user = $qaUser", "dbName = $qaDb", "sqlPassword = $qaPwd")


invokeSql $serverIpDev $userName $pass $filePath $sqlParametersDev
invokeSql $serverIpQ $userName $pass $filePath $sqlParametersQa

saveDbPassword $devUser $devPwd
saveDbPassword $qaUser $qaPwd

Write-Host DevCi database: $devDb 
Write-Host Username: $devUser
Write-Host Password: $devPwd

Write-Host Qa database: $qaDb
Write-Host Username: $qaUser
Write-Host Password: $qaPwd