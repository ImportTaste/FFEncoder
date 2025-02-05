#
# Module manifest for module 'FFTools'
#
# Generated by: Patrick Kelly
#
# Generated on: 12/30/2020
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'FFTools.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '9f724436-f327-4487-8eb9-1704f92283c8'

# Author of this module
Author = 'Patrick Kelly'

# Company or vendor of this module
CompanyName = 'NA'

# Copyright statement for this module
Copyright = '(c) 2021 Patrick Kelly, Boe Prox, and the FFMpeg developers. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module designed to make interfacing with FFMpeg tools easier, with a primary focus on 4K HDR audio/video encoding'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Invoke-FFMpeg', 'Invoke-TwoPassFFMpeg', 'New-CropFile', 'Measure-CropDimensions', 'Remove-FilePrompt', 'Write-Report'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = 'progressColors', 'warnColors', 'emphasisColors'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'iffmpeg', 'itpffmpeg', 'ncf', 'ghdr'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = 'FFTools.psd1', 'FFTools.psm1', 'Private\Set-AudioPreference.ps1', 'Private\Get-SubtitleStream', 'Private\Set-SubtitlePreference',
'Private\Get-HDRMetadata.ps1', 'Public\Invoke-FFMpeg.ps1', 'Public\Invoke-TwoPassFFMpeg.ps1', 'Public\New-CropFile.ps1', 'Public\Measure-CropDimensions.ps1',
'Private\Convert-ToStereo.ps1', 'Private\Set-PresetParameters.ps1', 'Private\Set-FFMPegArgs.ps1', 'Utils\Remove-FilePrompt.ps1', 'Utils\Write-Report.ps1',
'Utils\Confirm-HDR10Plus.ps1'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        Category = "Video Encoding"

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("ffmpeg", "4K", "HDR", "x265", "H.265", "FFEncoder", "PowerShellCore")

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/patrickenfuego/FFEncoder'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
        RequireLicenseAcceptance = "False"

        IsPrerelease = 'True'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

