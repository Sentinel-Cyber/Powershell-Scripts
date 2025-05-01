Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll")]
        public static extern bool IsIconic(IntPtr hWnd);
    }
"@

# Try multiple possible Teams process names
$teamsProcesses = Get-Process | Where-Object { $_.ProcessName -match "Teams|ms-teams" }

foreach ($proc in $teamsProcesses) {
    if ($proc.MainWindowHandle -ne 0) {
        $hwnd = $proc.MainWindowHandle
        
        # If window is minimized, restore it
        if ([Win32]::IsIconic($hwnd)) {
            [Win32]::ShowWindow($hwnd, 9)  # SW_RESTORE
        }
        
        # Multiple attempts to bring to front
        [Win32]::ShowWindow($hwnd, 5)      # SW_SHOW
        [Win32]::SetForegroundWindow($hwnd)
        Start-Sleep -Milliseconds 100
        [Win32]::SetForegroundWindow($hwnd)
        
        Write-Host "Found Teams window and attempted to bring to front"
        break
    }
}