$groups = [System.Collections.Generic.Dictionary[string, int]]::new()
$parents = [System.Collections.Generic.Stack[string]]::new()

$startingPoint = (Get-ADUser -Identity USERNAMEGOESHERE).distinguishedName

function Start-EnumWorker($parent) {
    $group = Get-ADObject -Properties memberOf -Identity $parent
    if (-not $groups.ContainsKey($parent)) {
        $parents.Push($parent)
        $groups.Add($parent, 0)
        $group.MemberOf | ForEach-Object {
            Add-GroupCount
            Start-EnumWorker $_
        }
        $_ = $parents.Pop()
    }
}

function Add-GroupCount() {
    $parents | ForEach-Object {
        $groups[$_] += 1
    }
}

Start-EnumWorker $startingPoint

$groups.Keys | ForEach-Object {
    [pscustomobject]@{
        DN = $_
        SubGroups = $groups[$_]
    }
} | Sort-Object -Property SubGroups -Descending
