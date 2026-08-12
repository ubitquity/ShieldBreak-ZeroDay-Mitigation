Interim Mitigation Script (PowerShell)
Until Microsoft releases an official binary patch via Windows Update, system administrators can apply temporary mitigations. The following script restricts the ability of standard users to create directory junctions in temporary folders commonly targeted by these exploits.

Note: Run this script from an elevated PowerShell prompt (Run as Administrator). This is a temporary workaround and may impact certain legacy applications that rely on these specific temp folder behaviors.


# ShieldBreak Interim Mitigation Script
# Prevents standard users from creating junction points in common temp directories

$TargetDirectories = @(
    "C:\Temp",
    "C:\Windows\Temp"
)

Write-Host "Applying interim mitigations for ShieldBreak..." -ForegroundColor Cyan

foreach ($Dir in $TargetDirectories) {
    if (Test-Path $Dir) {
        # Get current ACL
        $Acl = Get-Acl $Dir
        
        # Define the deny rule for creating junctions (WriteData/CreateFiles) for the 'Users' group
        $DenyRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "BUILTIN\Users",
            "CreateDirectories",
            "ContainerInherit, ObjectInherit",
            "None",
            "Deny"
        )
        
        # Apply the rule
        $Acl.AddAccessRule($DenyRule)
        Set-Acl -Path $Dir -AclObject $Acl
        
        Write-Host "[+] Secured ACLs on $Dir" -ForegroundColor Green
    } else {
        Write-Host "[-] Directory $Dir not found, skipping." -ForegroundColor Yellow
    }
}

Write-Host "Mitigation applied successfully. Await official Microsoft patch." -ForegroundColor Cyan
