Param(
	[Parameter(Mandatory=$true)][string]$applicationName,
    [string]$environmentDev = 'DEVCI',
    [string]$environmentQa  = 'QA',
    [string]$serverIpDev = '.', 
    [string]$serverIpQa = '.',
    [string]$userName = 'sa',
    [string]$filePath = (Get-Item -Path ".\" -Verbose).FullName
)

$ErrorActionPreference = "Stop"

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

function GetDbParams($environment, $applicationName, $serverIp)
{
    
    $params = @{
        dbName = CreateDbName $environment.ToUpper() $applicationName;
        user = CreateUsername $environment.ToLower().Trim() $applicationName.ToLower().Trim();
        password = GenerateDbPassword;        
        serverIp = $serverIp;        
    };
    $params.scriptParams = @("user = $($params.user)", "dbName = $($params.dbName)", "sqlPassword = $($params.password)");
    
    return $params;

}

Function DbExists($Database)
{
    $SQLResults = invoke-sqlcmd -ServerInstance "." -Username "sa" -Password "password" -Query "select name from sys.databases where name = '$Database'"  
    if([string]::IsNullOrEmpty($SQLResults))
    {
	    return $false;
    }
    else
    {
        Write-Host "The Database $Database already exists"
        return $true;
    } 

}

Function MakeDb($dbType, $dbParams)
{

    #check if db exists
    $exists = DbExists $dbParams.dbName;

    if($exists)
    {
       
        return;
    }
    
    invokeSql $dbParams.serverIp $userName $pass $filePath $dbParams.scriptParams;
    saveDbPassword $dbParams.user $dbParams.password;
    Write-Host "$dbType database: $dbParams.dbName";
    Write-Host Username: $dbParams.user;
    Write-Host Password: $dbParams.password;
}
#This is the do until loop
do 
{
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch($input)
    {
        '1'{

            clear;
            Write-Host 'You chose to create a DevCi database';

            $param = GetDbParams $environmentDev $applicationName $serverIpDev;
            MakeDb $environmentDev $param;
            

        }
        '2'{
            clear
            Write-Host 'You chose to create a QA database'

            $param = GetDbParams $environmentQa $applicationName $serverIpQa
            MakeDb $environmentQa $param;
            

        }
        '3'{
            clear
            Write-Host 'You chose to create a DevCi and Qa Database'

            $paramsDev = GetDbParams $environmentDev $applicationName $serverIpDev;
            MakeDb $environmentDev $paramsDev;
            
            $paramsQa = GetDbParams $environmentQa $applicationName $serverIpQa
            MakeDb $environmentQa $paramsQa;
            

        }
        'q'{
            return
        }
    }
    pause
}
until ($input -eq 'q')