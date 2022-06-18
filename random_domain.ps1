param([Parameter(Mandatory=$true)] $OutputJsonFile)

$group_names = [System.Collections.ArrayList](Get-Content "data/group_names.txt")
$first_names = [System.Collections.ArrayList](Get-Content "data/first_names.txt")
$last_names = [System.Collections.ArrayList](Get-Content "data/last_names.txt")
$passwords = [System.Collections.ArrayList](Get-Content "data/passwords.txt")

$groups = @()
$num_users = 100
$users = @()
$num_groups = 10

for($i = 0; $i -lt $num_groups;$i++) {
    $new_group = (Get-Random -InputObject $group_names)
    $groups += @{"name"="$new_group"}
}

for ($i = 0; $i -lt $num_users; $i += 1) {
    # $group = (Get-Random -InputObject $group_names)
    $fname = (Get-Random -InputObject $first_names)
    $lname = (Get-Random -InputObject $last_names)
    $password = (Get-Random -InputObject $passwords)

    $new_user = @{
        "name"="$fname $lname"
        "password"="$password"
        "groups"=@((Get-Random -InputObject $groups).name)
    }

    $users += $new_user

    $first_names.Remove($fname)
    $last_names.Remove($lname)
    $passwords.Remove($password)
}

@{ 
    "domain"="xyz.com"
    "groups"=$groups
    "users"=$users
 } | ConvertTo-Json | Out-File $OutputJsonFile