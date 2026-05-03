param(
    [string]$DashboardDbContainer = "postgres-data",
    [string]$ManagerDbContainer = "postgres-manager",
    [string]$DashboardDbName = "dashboard",
    [string]$ManagerDbName = "dashboardmanager",
    [string]$DbUser = "postgres"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dashboardSql = Join-Path $repoRoot "db-sample-data\cleanbike-dashboard.sql"
$managerSql = Join-Path $repoRoot "db-sample-data\cleanbike-manager.sql"

if (-not (Test-Path $dashboardSql)) {
    throw "Missing SQL file: $dashboardSql"
}

if (-not (Test-Path $managerSql)) {
    throw "Missing SQL file: $managerSql"
}

Write-Host "Copying CleanBike dashboard data seed..."
docker cp $dashboardSql "${DashboardDbContainer}:/tmp/cleanbike-dashboard.sql"

Write-Host "Applying CleanBike dashboard data seed..."
docker exec $DashboardDbContainer psql -U $DbUser -d $DashboardDbName -f /tmp/cleanbike-dashboard.sql

Write-Host "Copying CleanBike manager metadata seed..."
docker cp $managerSql "${ManagerDbContainer}:/tmp/cleanbike-manager.sql"

Write-Host "Applying CleanBike manager metadata seed..."
docker exec $ManagerDbContainer psql -U $DbUser -d $ManagerDbName -f /tmp/cleanbike-manager.sql

Write-Host ""
Write-Host "CleanBike seed completed."
Write-Host "Open: http://localhost/dashboard?index=cleanbike_metrotaipei&city=metrotaipei"
