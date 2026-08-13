<#
.SYNOPSIS
    宏觀風險掃描 — 補齊 6 項缺失指標
.DESCRIPTION
    從各大金融網站 scrape 以下 6 項數據：
    1. FINRA Margin Debt
    2. Insider Buy/Sell Ratio
    3. BofA Bull &amp; Bear Indicator
    4. NYSE Advance/Decline Line
    5. AAII Household Stock Allocation
    6. Margin Debt / GDP
.NOTES
    作者: Paper Boy
    日期: 2026-08-12
#>

param(
    [switch]$OutputJson,
    [string]$OutputPath = ""
)

$ErrorActionPreference = "SilentlyContinue"
$results = @{}
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  宏觀風險掃描 - 補齊 6 項缺失指標" -ForegroundColor Cyan
Write-Host "  執行時間: $timestamp" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ===== Helper Functions =====
function Get-WebText {
    param([string]$Url)
    try {
        $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 15 -UserAgent $ua
        return $resp.Content
    }
    catch {
        return $null
    }
}

# ===== 1. FINRA Margin Debt =====
Write-Host "[1/6] FINRA Margin Debt ... " -NoNewline
$marginText = Get-WebText "https://www.finra.org/rules-guidance/key-topics/margin-accounts/margin-statistics"
if ($marginText) {
    $marginVal = [regex]::Match($marginText, '(\d[\d,]*\.?\d*)\s*(?:billion|Billion)').Groups[1].Value
    $marginDate = [regex]::Match($marginText, '(?:January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{4}').Groups[0].Value
    if ($marginVal) {
        Write-Host "OK - $marginVal billion" -ForegroundColor Green
        $results.MarginDebt = @{Value = "$marginVal billion"; Date = $marginDate; Source = "FINRA" }
    }
    else {
        Write-Host "FINRA blocked, trying FRED..." -ForegroundColor Yellow
        $altText = Get-WebText "https://fred.stlouisfed.org/series/MARGINDEBT"
        if ($altText -match 'Observations.*?(\d{4}-\d{2}-\d{2}):\s*([\d.]+)') {
            $results.MarginDebt = @{Value = "$($Matches[2]) billion"; Date = $Matches[1]; Source = "FRED" }
            Write-Host "OK - $($Matches[2]) billion ($($Matches[1]))" -ForegroundColor Green
        }
        else {
            Write-Host "FAILED - need manual input" -ForegroundColor Red
            $results.MarginDebt = @{Value = "MANUAL"; Date = ""; Source = "" }
        }
    }
}
else {
    Write-Host "FAILED - FINRA blocked" -ForegroundColor Red
    $results.MarginDebt = @{Value = "MANUAL"; Date = ""; Source = "" }
}

# ===== 2. Insider Buy/Sell Ratio =====
Write-Host "[2/6] Insider Buy/Sell Ratio ... " -NoNewline
$insiderText = Get-WebText "https://www.gurufocus.com/economic_indicators/4359/insider-buysell-ratio"
if ($insiderText) {
    $ratioMatch = [regex]::Match($insiderText, '([0-9]\.[0-9]{2})')
    if ($ratioMatch.Success) {
        $results.InsiderBuySell = @{Value = $ratioMatch.Groups[1].Value; Date = "latest"; Source = "GuruFocus" }
        Write-Host "OK - $($ratioMatch.Groups[1].Value)" -ForegroundColor Green
    }
    else {
        Write-Host "PAGE LOADED but value not found" -ForegroundColor Yellow
        $results.InsiderBuySell = @{Value = "MANUAL"; Date = ""; Source = "" }
    }
}
else {
    Write-Host "FAILED - GuruFocus blocked" -ForegroundColor Red
    $results.InsiderBuySell = @{Value = "MANUAL"; Date = ""; Source = "" }
}

# ===== 3. BofA Bull & Bear Indicator =====
Write-Host "[3/6] BofA Bull and Bear Indicator ... " -NoNewline
$bofaText = Get-WebText "https://www.bing.com/search?q=%22BofA+Bull+Bear+Indicator%22+2026"
if ($bofaText) {
    $bofaMatch = [regex]::Match($bofaText, 'Bull.*?Bear.*?([0-9]\.[0-9])')
    if ($bofaMatch.Success) {
        $results.BofABullBear = @{Value = $bofaMatch.Groups[1].Value; Date = "latest"; Source = "Bing Search" }
        Write-Host "OK - $($bofaMatch.Groups[1].Value)" -ForegroundColor Green
    }
    else {
        Write-Host "NOT FOUND - proprietary research, manual needed" -ForegroundColor Red
        $results.BofABullBear = @{Value = "MANUAL"; Date = ""; Source = "" }
    }
}
else {
    Write-Host "FAILED" -ForegroundColor Red
    $results.BofABullBear = @{Value = "MANUAL"; Date = ""; Source = "" }
}

# ===== 4. NYSE Advance/Decline Line =====
Write-Host "[4/6] NYSE Advance/Decline Line ... " -NoNewline
$adText = Get-WebText "https://www.barchart.com/stocks/indices/nyse-advance-decline"
if ($adText) {
    $adAdv = [regex]::Match($adText, 'Advancing.*?(\d[\d,]*)')
    $adDec = [regex]::Match($adText, 'Declining.*?(\d[\d,]*)')
    if ($adAdv.Success) {
        $results.NYSEAD = @{Value = "Adv: $($adAdv.Groups[1].Value) / Dec: $($adDec.Groups[1].Value)"; Date = "latest"; Source = "Barchart" }
        Write-Host "OK - Adv $($adAdv.Groups[1].Value) / Dec $($adDec.Groups[1].Value)" -ForegroundColor Green
    }
    else {
        Write-Host "PAGE LOADED but value not found" -ForegroundColor Yellow
        $results.NYSEAD = @{Value = "MANUAL"; Date = ""; Source = "" }
    }
}
else {
    Write-Host "FAILED - Barchart blocked" -ForegroundColor Red
    $results.NYSEAD = @{Value = "MANUAL"; Date = ""; Source = "" }
}

# ===== 5. AAII Household Stock Allocation =====
Write-Host "[5/6] AAII Household Stock Allocation ... " -NoNewline
$aaiiText = Get-WebText "https://www.aaii.com/assetallocationsurvey"
if ($aaiiText) {
    $allocMatch = [regex]::Match($aaiiText, 'Stock.*?([0-9.]+)%')
    if ($allocMatch.Success) {
        $results.AAIIAllocation = @{Value = "$($allocMatch.Groups[1].Value)%"; Date = "latest"; Source = "AAII" }
        Write-Host "OK - $($allocMatch.Groups[1].Value)%" -ForegroundColor Green
    }
    else {
        Write-Host "PAGE LOADED but value not found" -ForegroundColor Yellow
        $results.AAIIAllocation = @{Value = "MANUAL"; Date = ""; Source = "" }
    }
}
else {
    Write-Host "FAILED - AAII blocked" -ForegroundColor Red
    $results.AAIIAllocation = @{Value = "MANUAL"; Date = ""; Source = "" }
}

# ===== 6. Margin Debt / GDP =====
Write-Host "[6/6] Margin Debt / GDP Ratio ... " -NoNewline
if ($results.MarginDebt.Value -and $results.MarginDebt.Value -ne "MANUAL") {
    $gdpText = Get-WebText "https://fred.stlouisfed.org/series/GDP"
    if ($gdpText -match 'Observations.*?(\d{4}-\d{2}-\d{2}):\s*([\d.]+)') {
        $gdpVal = $Matches[2]
        $gdpDate = $Matches[1]
        $mdNum = [regex]::Match($results.MarginDebt.Value, '([\d.]+)').Groups[1].Value
        if ($mdNum -and $gdpVal) {
            $ratio = [math]::Round([double]$mdNum / ([double]$gdpVal / 1000), 1)
            $results.MarginDebtGDP = @{Value = "$ratio%"; MD = "$mdNum B"; GDP = "$gdpVal B"; Date = $gdpDate; Source = "FRED" }
            Write-Host "OK - $ratio% (MD $mdNum B / GDP $gdpVal B)" -ForegroundColor Green
        }
    }
    else {
        Write-Host "GDP not found" -ForegroundColor Yellow
        $results.MarginDebtGDP = @{Value = "MANUAL"; Date = ""; Source = "" }
    }
}
else {
    Write-Host "SKIP - need Margin Debt first" -ForegroundColor Yellow
    $results.MarginDebtGDP = @{Value = "MANUAL"; Date = ""; Source = "" }
}

# ===== Manual Input =====
$manualCount = ($results.Values | Where-Object { $_["Value"] -eq "MANUAL" }).Count
if ($manualCount -gt 0) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Yellow
    Write-Host "  $manualCount item(s) need manual input" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Yellow
    Write-Host ""

    if ($results.MarginDebt.Value -eq "MANUAL") {
        Write-Host "1. FINRA Margin Debt" -ForegroundColor Yellow
        Write-Host "   Open: https://www.finra.org/rules-guidance/key-topics/margin-accounts/margin-statistics"
        $md = Read-Host "   Margin Debt (in billions)"
        $mdDate = Read-Host "   Date (yyyy-mm)"
        if ($md) { $results.MarginDebt = @{Value = "$md billion"; Date = $mdDate; Source = "MANUAL" } }
    }
    if ($results.InsiderBuySell.Value -eq "MANUAL") {
        Write-Host ""
        Write-Host "2. Insider Buy/Sell Ratio" -ForegroundColor Yellow
        Write-Host "   Open: https://www.gurufocus.com/economic_indicators/4359/insider-buysell-ratio"
        $ins = Read-Host "   Insider Buy/Sell Ratio"
        if ($ins) { $results.InsiderBuySell = @{Value = $ins; Date = "latest"; Source = "MANUAL" } }
    }
    if ($results.BofABullBear.Value -eq "MANUAL") {
        Write-Host ""
        Write-Host "3. BofA Bull and Bear Indicator" -ForegroundColor Yellow
        Write-Host "   Search: 'BofA Bull Bear Indicator August 2026'"
        $bofa = Read-Host "   BofA Bull and Bear reading (0-10)"
        if ($bofa) { $results.BofABullBear = @{Value = $bofa; Date = "latest"; Source = "MANUAL" } }
    }
    if ($results.NYSEAD.Value -eq "MANUAL") {
        Write-Host ""
        Write-Host "4. NYSE Advance/Decline Line" -ForegroundColor Yellow
        Write-Host "   Search: 'NYSE advance decline August 12 2026'"
        $ad = Read-Host "   Advancing / Declining numbers"
        $adNote = Read-Host "   Divergence from SPX? (Yes/No)"
        if ($ad) { $results.NYSEAD = @{Value = $ad; Divergence = $adNote; Source = "MANUAL" } }
    }
    if ($results.AAIIAllocation.Value -eq "MANUAL") {
        Write-Host ""
        Write-Host "5. AAII Household Stock Allocation" -ForegroundColor Yellow
        Write-Host "   Open: https://www.aaii.com/assetallocationsurvey"
        $alloc = Read-Host "   Allocation (%)"
        if ($alloc) { $results.AAIIAllocation = @{Value = "$alloc%"; Date = "latest"; Source = "MANUAL" } }
    }
}

# ===== Output =====
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  RESULTS" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

$summary = @"
=== Macro Scan Results ===
Date: $timestamp

1. FINRA Margin Debt: $($results.MarginDebt.Value) ($($results.MarginDebt.Date))
2. Insider Buy/Sell Ratio: $($results.InsiderBuySell.Value)
3. BofA Bull and Bear: $($results.BofABullBear.Value)
4. NYSE A/D Line: $($results.NYSEAD.Value)
5. AAII Stock Allocation: $($results.AAIIAllocation.Value)
6. Margin Debt/GDP: $($results.MarginDebtGDP.Value)
"@

Write-Host $summary

$desktop = [Environment]::GetFolderPath("Desktop")
$outPath = if ($OutputPath) { $OutputPath } else { "$desktop\macro_scan_results.txt" }
$summary | Out-File -FilePath $outPath -Encoding UTF8
Write-Host "Saved to: $outPath" -ForegroundColor Cyan

if ($OutputJson) {
    $jsonPath = [System.IO.Path]::ChangeExtension($outPath, ".json")
    $results | ConvertTo-Json | Out-File -FilePath $jsonPath -Encoding UTF8
    Write-Host "JSON saved to: $jsonPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Please send these numbers to Paper Boy to update the report!" -ForegroundColor Magenta