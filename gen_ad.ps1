param([Parameter(Mandatory=$true)] $JSONFile)

function CreatADGroup() {
    param([Parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    # echo $name
    New-ADGroup -name $name -GroupScope Global
}

function RemoveADGroup() {
    param([Parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    # echo $name
    Remove-ADGroup -Identity $name -Confirm:$false
}

function CreateADUser() {
    param([Parameter(Mandatory=$true)] $userObject)

    # Get name from schema
    $name = $userObject.name
    $first_name, $last_name = $name.Split(" ")

    # username (first initial, last name) structure
    $username = ($first_name[0] + $last_name).tolower()

    $samAccountName = $username
    $principalname = $username
    $password = $userObject.password

    # Actually create AD user object
    New-ADUser -Name "$name" -GivenName $first_name -Surname $last_name -SamAccountName $samAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    # Add users to group
    foreach($group_name in $userObject.groups) {

        try {
            Get-ADGroup -Identity "$group_name"
            Add-ADGroupMember -Identity $group_name -Members $username
        } catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning "User $name NOT added to group $group_name because it does not exist"
        }  
    }
}

function WeakenPasswordPolicy() {
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}

WeakenPasswordPolicy

$json = (Get-Content $JSONFile | ConvertFrom-Json)

$Global:Domain = $json.domain

foreach($group in $json.groups) {
    CreatADGroup $group
}

foreach ($user in $json.users) {
    CreateADUser $user
}