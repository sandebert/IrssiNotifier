Param(
    [Switch] $premium,
    [Switch] $free
)

$regexPackageName = 'package=".+"'
$regexApplicationName = '<string name="app_name">.+?</string>'
$regexC2dPermission = 'fi\.iki\.murgo\.irssinotifier\..*?permission\.C2D_MESSAGE'
$regexCategory = '<category android:name="fi\.iki\.murgo\.irssinotifier.*?" />'

Function Replace-File
{
    Param([string]$file, [string]$regex, [string]$value)
    $path = Resolve-Path $file
    $text = (Get-Content $path -Encoding UTF8 | Out-String) |
        Foreach-Object {$_ -replace $regex, $value}
    [System.IO.File]::WriteAllLines($path, $text.TrimEnd())
}

Function Change-Premium()
{
    Write-Host "Changing values to premium..."
    Replace-File "AndroidManifest.xml" $regexPackageName 'package="fi.iki.murgo.irssinotifier.premium"'
    Replace-File "AndroidManifest.xml" $regexC2dPermission 'fi.iki.murgo.irssinotifier.premium.permission.C2D_MESSAGE'
    Replace-File "AndroidManifest.xml" $regexCategory '<category android:name="fi.iki.murgo.irssinotifier.premium" />'
    Replace-File "res\values\strings.xml" $regexApplicationName '<string name="app_name">IrssiNotifier+</string>'
    $regexImport = '(package fi.iki.murgo.irssinotifier;)'
    $import = '$1import fi.iki.murgo.irssinotifier.premium.R;'
    Replace-File "src\fi\iki\murgo\irssinotifier\InitialSettingsActivity.java" $regexImport $import
    Replace-File "src\fi\iki\murgo\irssinotifier\SettingsActivity.java" $regexImport $import
    Replace-File "src\fi\iki\murgo\irssinotifier\MessagePagerAdapter.java" $regexImport $import
    Replace-File "src\fi\iki\murgo\irssinotifier\AboutActivity.java" $regexImport $import
    Replace-File "src\fi\iki\murgo\irssinotifier\ChannelSettingsActivity.java" $regexImport $import
    Replace-File "src\fi\iki\murgo\irssinotifier\IrcNotificationManager.java" $regexImport $import
    Replace-File "src\fi\iki\murgo\irssinotifier\IrssiNotifierActivity.java" $regexImport $import
}

Function Change-Free()
{
    Write-Host "Changing values to free..."
    Replace-File "AndroidManifest.xml" $regexPackageName 'package="fi.iki.murgo.irssinotifier"'
    Replace-File "AndroidManifest.xml" $regexC2dPermission 'fi.iki.murgo.irssinotifier.permission.C2D_MESSAGE'
    Replace-File "AndroidManifest.xml" $regexCategory '<category android:name="fi.iki.murgo.irssinotifier" />'
    Replace-File "res\values\strings.xml" $regexApplicationName '<string name="app_name">IrssiNotifier</string>'
    $regexImport = 'import fi\.iki\.murgo\.irssinotifier\.premium\.R;'
    Replace-File "src\fi\iki\murgo\irssinotifier\InitialSettingsActivity.java" $regexImport ''
    Replace-File "src\fi\iki\murgo\irssinotifier\SettingsActivity.java" $regexImport ''
    Replace-File "src\fi\iki\murgo\irssinotifier\MessagePagerAdapter.java" $regexImport ''
    Replace-File "src\fi\iki\murgo\irssinotifier\AboutActivity.java" $regexImport ''
    Replace-File "src\fi\iki\murgo\irssinotifier\ChannelSettingsActivity.java" $regexImport ''
    Replace-File "src\fi\iki\murgo\irssinotifier\IrcNotificationManager.java" $regexImport ''
    Replace-File "src\fi\iki\murgo\irssinotifier\IrssiNotifierActivity.java" $regexImport ''
}

If (($premium -and $free) -or (!$premium -and !$free))
{
    Write-Host "Use switch -premium OR -free"
    exit
}

If ($premium)
{
    Change-Premium
}
ElseIf ($free)
{
    Change-Free
}
