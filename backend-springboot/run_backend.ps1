$envLines = Get-Content .env
foreach ($line in $envLines) {
    if ($line -match '^\s*([^#=]+)\s*=\s*(.*)') {
        [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
    }
}
.\mvnw.cmd spring-boot:run
