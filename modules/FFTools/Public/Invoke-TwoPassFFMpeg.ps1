function Invoke-TwoPassFFMpeg {
    [CmdletBinding()]
    param (
        # The input file to be encoded
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("InFile", "I")]
        [string]$InputFile,

        # Crop dimensions for the output file
        [Parameter(Mandatory = $true, Position = 1)]
        [Alias("Crop", "CropDim")]
        [int[]]$CropDimensions,

        # Audio preference for the output file
        [Parameter(Mandatory = $false)]
        [Alias("Audio", "A")]
        [string]$AudioInput = "none",

        [Parameter(Mandatory = $false)]
        [Alias("AB", "AQ")]
        [int]$AudioBitrate,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [Alias("S")]
        [string]$Subtitles,

        # x265 preset setting
        [Parameter(Mandatory = $false)]
        [Alias("P")]
        [string]$Preset,

        # x265 CRF / constant bitrate array of arguments
        [Parameter(Mandatory = $true)]
        [array]$RateControl,

        # Deblock filter setting
        [Parameter(Mandatory = $false)]
        [Alias("DBF")]
        [int[]]$Deblock,

        # aq-mode setting. Default is 2
        [Parameter(Mandatory = $false)]
        [Alias("AQM")]
        [int]$AqMode,

        # aq-strength. Higher values equate to a lower QP, but can also increase bitrate significantly
        [Parameter(Mandatory = $false)]
        [Alias("AQS")]
        [double]$AqStrength,

        # psy-rd. Psycho visual setting
        [Parameter(Mandatory = $false)]
        [double]$PsyRd,

        # psy-rdoq (trellis). Psycho visual setting
        [Parameter(Mandatory = $false)]
        [Alias("PRDQ")]
        [double]$PsyRdoq,

        # Filter to help reduce high frequency noise (grain)
        [Parameter(Mandatory = $false)]
        [Alias("NRTR")]
        [int]$NrInter,

        # Adjusts the quantizer curve compression factor
        [Parameter(Mandatory = $false)]
        [Alias("Q")]
        [double]$QComp,

        # Path to the output file
        [Parameter(Mandatory = $true)]
        [Alias("O")]
        [string]$OutputPath,

        # Path to the log file
        [Parameter(Mandatory = $true)]
        [Alias("L")]
        [hashtable]$Paths,

        # Switch to enable a test run 
        [Parameter(Mandatory = $false)]
        [Alias("T")]
        [int]$TestFrames
    )

    function Write-FirstBanner {
        Write-Host "***** STARTING FFMPEG PASS 1 *****" @progressColors
        Write-Host "Generating 1st pass encoder metrics..."
    }

    function Write-SecondBanner {
        Write-Host
        Write-Host "***** STARTING FFMPEG PASS 2 *****" @progressColors
        Write-Host "To view your progress, run " -NoNewline
        Write-Host "Get-Content '$($Paths.LogPath)' -Tail 10" @emphasisColors -NoNewline
        Write-Host " in a different PowerShell session`n`n"
    }
    
    #Gathering HDR metadata
    $HDR = Get-HDRMetadata $InputFile
    #Builds the audio argument array based on user input
    $audio = Set-AudioPreference -InputFile $InputFile -UserChoice $AudioInput -Bitrate $AudioBitrate
    #Builds the subtitle argument array based on user input
    $subs = Set-SubtitlePreference -InputFile $InputFile -UserChoice $Subtitles

    Write-Host "## 2 Pass Average Bitrate Selected ##" @emphasisColors

    if ($PSBoundParameters['TestFrames']) {
        Write-FirstBanner
        Write-Host "`n`nTest Run Enabled. Analyzing $TestFrames frames`n" @warnColors
        ffmpeg -probesize 100MB -ss 00:01:30 -i $InputFile -frames:v $TestFrames -vf "crop=w=$($CropDimensions[0]):h=$($CropDimensions[1])" `
            -color_range tv -map 0:v:0 -c:v libx265 -an -sn $RateControl -preset $Preset -pix_fmt $HDR.PixelFmt `
            -x265-params "pass=1:stats='$($Paths.X265Log)':nr-inter=$NrInter`:aq-mode=$AqMode`:aq-strength=$AqStrength`:psy-rd=$PsyRd`:psy-rdoq=$PsyRdoq`:level-idc=5.1:`
            open-gop=0:qcomp=$QComp`:keyint=120:deblock=$($Deblock[0]),$($Deblock[1]):sao=0:rc-lookahead=48:subme=4:strong-intra-smoothing=0:`
            colorprim=$($HDR.ColorPrimaries):transfer=$($HDR.Transfer):colormatrix=$($HDR.ColorSpace):`
            chromaloc=2:$($HDR.MasterDisplay)L($($HDR.MaxLuma),$($HDR.MinLuma)):max-cll=$($HDR.MaxCLL),$($HDR.MaxFAL):hdr10-opt=1" `
            -f null - 2>$Paths.LogPath
            
        Start-Sleep -Seconds 1

        Write-SecondBanner
        Write-Host "`n`nTest Run Enabled. Encoding $TestFrames frames`n" @warnColors
        ffmpeg -probesize 100MB -ss 00:01:30 -i $InputFile -frames:v $TestFrames -vf "crop=w=$($CropDimensions[0]):h=$($CropDimensions[1])" `
            -color_range tv -map 0:v:0 -c:v libx265 $audio $subs $RateControl -preset $Preset -pix_fmt $HDR.PixelFmt `
            -x265-params "pass=2:stats='$($Paths.X265Log)':nr-inter=$NrInter`:aq-mode=$AqMode`:aq-strength=$AqStrength`:psy-rd=$PsyRd`:psy-rdoq=$PsyRdoq`:level-idc=5.1:`
            open-gop=0:qcomp=$QComp`:keyint=120:deblock=$($Deblock[0]),$($Deblock[1]):sao=0:rc-lookahead=48:subme=4:strong-intra-smoothing=0:`
            colorprim=$($HDR.ColorPrimaries):transfer=$($HDR.Transfer):colormatrix=$($HDR.ColorSpace):`
            chromaloc=2:$($HDR.MasterDisplay)L($($HDR.MaxLuma),$($HDR.MinLuma)):max-cll=$($HDR.MaxCLL),$($HDR.MaxFAL):hdr10-opt=1" `
            $OutputPath 2>$Paths.LogPath
    }
    #Run a full 2 pass encode
    else {
        Write-FirstBanner
        ffmpeg -probesize 100MB -i $InputFile -vf "crop=w=$($CropDimensions[0]):h=$($CropDimensions[1])" `
            -color_range tv -map 0:v:0 -c:v libx265 -an -sn $RateControl -preset $Preset -pix_fmt $HDR.PixelFmt `
            -x265-params "pass=1:stats='$($Paths.X265Log)':nr-inter=$NrInter`:aq-mode=$AqMode`:aq-strength=$AqStrength`:psy-rd=$PsyRd`:psy-rdoq=$PsyRdoq`:level-idc=5.1:`
            open-gop=0:qcomp=$QComp`:keyint=120:deblock=$($Deblock[0]),$($Deblock[1]):sao=0:rc-lookahead=48:subme=4:strong-intra-smoothing=0:`
            colorprim=$($HDR.ColorPrimaries):transfer=$($HDR.Transfer):colormatrix=$($HDR.ColorSpace):`
            chromaloc=2:$($HDR.MasterDisplay)L($($HDR.MaxLuma),$($HDR.MinLuma)):max-cll=$($HDR.MaxCLL),$($HDR.MaxFAL):hdr10-opt=1" `
            -f null - 2>$Paths.LogPath
            
        Start-Sleep -Seconds 1

        Write-SecondBanner
        ffmpeg -probesize 100MB -i $InputFile -vf "crop=w=$($CropDimensions[0]):h=$($CropDimensions[1])" `
            -color_range tv -map 0:v:0 -c:v libx265 $audio $subs $RateControl -preset $Preset -pix_fmt $HDR.PixelFmt `
            -x265-params "pass=2:stats='$($Paths.X265Log)':nr-inter=$NrInter`:aq-mode=$AqMode`:aq-strength=$AqStrength`:psy-rd=$PsyRd`:psy-rdoq=$PsyRdoq`:level-idc=5.1:`
            open-gop=0:qcomp=$QComp`:keyint=120:deblock=$($Deblock[0]),$($Deblock[1]):sao=0:rc-lookahead=48:subme=4:strong-intra-smoothing=0:`
            colorprim=$($HDR.ColorPrimaries):transfer=$($HDR.Transfer):colormatrix=$($HDR.ColorSpace):`
            chromaloc=2:$($HDR.MasterDisplay)L($($HDR.MaxLuma),$($HDR.MinLuma)):max-cll=$($HDR.MaxCLL),$($HDR.MaxFAL):hdr10-opt=1" `
            $OutputPath 2>$Paths.logPath
    }
}