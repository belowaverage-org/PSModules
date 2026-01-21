 function Get-ADNestedGroups($DN) {
    $groups = [System.Collections.Generic.Dictionary[string, [System.Collections.Generic.List[int]]]]::new()
    $parents = [System.Collections.Generic.Stack[string]]::new()

    function Start-EnumWorker($parent) {
        $group = Get-ADObject -Properties memberOf -Identity $parent
        if (-not $groups.ContainsKey($parent)) {
            $parents.Push($parent)
            $groups.Add($parent, @(0, ($parents.Count)))
            $group.MemberOf | ForEach-Object {
                Add-GroupCount
                Start-EnumWorker $_
            }
            $_ = $parents.Pop()
        }
    }

    function Get-Spaces($count) {
        for ($i = 1; $i -lt $count; $i++) {
            "    "
        }
    }

    function Add-GroupCount() {
        $parents | ForEach-Object {
            $groups[$_][0] += 1
        }
    }

    Start-EnumWorker $DN

    $groups.Keys | ForEach-Object {
        [pscustomobject]@{
            DN = "$(Get-Spaces $groups[$_][1])$_"
            SubGroups = $groups[$_][0]
        }
    }
}
