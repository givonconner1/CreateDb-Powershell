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

function Show-Menu
{
    param (
        [string]$Title = 'Database Deployment & User Creation'
    )
    clear
    Write-Host "================= $Title ================="

    Write-Host "1: Press '1' to create a DevCi database"
    Write-Host "2: Press '2' to create a Qa database"
    Write-Host "3: Press '3' to create a DevCi and Qa Database"
    Write-Host "Q: Press 'Q' to exit the program"
}

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

#This is the do until loop
do 
{
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch($input)
    {
        '1'{
            clear
            'You chose to create a DevCi database'
            $devDb = CreateDbName $environmentDev $applicationName
            $devUser = CreateUsername $environmentDev.ToLower().Trim() $applicationName.ToLower()
            $devPwd = GenerateDbPassword
            $sqlParametersDev = @("user = $devUser", "dbName = $devDb", "sqlPassword = $devPwd")
            invokeSql $serverIpDev $userName $pass $filePath $sqlParametersDev
            saveDbPassword $devUser $devPwd
            Write-Host DevCi database: $devDb 
            Write-Host Username: $devUser
            Write-Host Password: $devPwd

        }
        '2'{
            clear
            'You chose to create a Qa database'
            $qaDb = CreateDbName $environmentQa $applicationName
            $qaUser = CreateUsername $environmentQa.ToLower().Trim() $applicationName.ToLower()
            $qaPwd = GenerateDbPassword
            $sqlParametersQa = @("user = $qaUser", "dbName = $qaDb", "sqlPassword = $qaPwd")
            invokeSql $serverIpQ $userName $pass $filePath $sqlParametersQa
            saveDbPassword $qaUser $qaPwd

            Write-Host Qa database: $qaDb
            Write-Host Username: $qaUser
            Write-Host Password: $qaPwd

        }
        '3'{
            clear
            'You chose to create a DevCi and Qa Database'
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
        }
        'q'{
            return
        }
    }
    pause
}
until ($input -eq 'q')