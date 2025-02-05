- [FFEncoder](#ffencoder)
  - [About](#about)
  - [Dependencies](#dependencies)
  - [Dependency Installation](#dependency-installation)
    - [Windows](#windows)
    - [Linux](#linux)
    - [macOS](#macos)
  - [Auto-Cropping](#auto-cropping)
  - [Automatic HDR Metadata](#automatic-hdr-metadata)
  - [Rate Control Options](#rate-control-options)
  - [Script Parameters](#script-parameters)
    - [Using the Extra Parameter Options](#using-the-extra-parameter-options)
  - [Hard Coded Parameters](#hard-coded-parameters)
    - [Exclusive to First Pass ABR](#exclusive-to-first-pass-abr)
    - [Exclusive to 4K UHD Content](#exclusive-to-4k-uhd-content)
    - [Exclusive to SDR Content 1080p and Below](#exclusive-to-sdr-content-1080p-and-below)
  - [Audio Options](#audio-options)
    - [Using the libfdk_aac Encoder](#using-the-libfdk_aac-encoder)
    - [Using the aac_at Encoder](#using-the-aac_at-encoder)
    - [Downmixing Multi-Channel Audio to Stereo](#downmixing-multi-channel-audio-to-stereo)
  - [Subtitle Options](#subtitle-options)

&nbsp;

# FFEncoder

FFEncoder is a cross-platform PowerShell script that is meant to make high definition video encoding easier. FFEncoder uses [ffmpeg](https://ffmpeg.org/), [ffprobe](https://ffmpeg.org/ffprobe.html), and the [x265 HEVC encoder](https://x265.readthedocs.io/en/master/index.html) to compress video files for streaming or archiving.

&nbsp;

## About

FFEncoder is a simple script that allows you to pass dynamic parameters to ffmpeg without needing to modify complicated CLI arguments for each source. As much as I love the ffmpeg suite, it can be complicated to learn and use; the syntax is extensive, and many of the arguments are not easy to remember unless you use them often. The goal of FFEncoder is to take common encoding workflows and make them easier, while continuing to leverage the power and flexibility of the ffmpeg tool chain.

&nbsp;

## Dependencies

- ffmpeg / ffprobe
- PowerShell Core v. 7.0 or newer
- \*[quietvoid's HDR10+ parser](https://github.com/quietvoid/hdr10plus_parser) (optional for HDR10+ encoding)
  - For the script to work with hdr10plus_parser, make sure it is available via PATH
  - To access the `dhdr10-info` parameter in ffmpeg, enable HDR10_PLUS in `cmake` during manual compilation (or update to the latest version of ffmpeg)

The script requires PowerShell Core v. 7.0 or newer on all systems as it utilizes new parallel processing features introduced in this version. Multi-threading prior to PowerShell 7 was prone to memory leaks which persuaded me to make the change.

> For Windows users, PowerShell Core is a supplemental installation and will will be installed alongside PowerShell 5.1

&nbsp;

## Dependency Installation

> You can compile ffmpeg manually from source on all platforms, which allows you to select additional libraries (like Fraunhofer's libfdk AAC encoder). For more information, see [here](https://trac.ffmpeg.org/wiki/CompilationGuide)

### Windows

To download ffmpeg, navigate to the [ffmpeg downloads page](https://ffmpeg.org/download.html#build-windows) and install one of the prebuilt Windows exe packages. I recommend the builds provided by Gyan.

To install the latest version of PowerShell Core, follow the instructions provided by Microsoft [here](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1).

### Linux

You can install ffmpeg using your package manager of choice (apt/yum/pacman):

> `apt install ffmpeg`

To install PowerShell core, see Microsoft's instructions for your distribution [here](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1).

### macOS

The easiest way to install ffmpeg and PowerShell core is through the [Homebrew](https://brew.sh/) package manager:

> `brew install ffmpeg`

One of the other benefits of using Homebrew is that you can easily install a build that includes non-free libraries like fdk_aac:

> `brew install ffmpeg --with-fdk-aac`

To install PowerShell Core, run the following command using Homebrew:

> `brew install --cask powershell`

---

## Auto-Cropping

FFEncoder will auto-crop your video, and works similarly to programs like Handbrake. The script uses ffmpeg's `cropdetect` argument to analyze up to 5 separate segments of the source simultaneously. The collected output of each cropping instance is then saved to a file, which is used to determine the ideal cropping width and height for encoding.

---

## Automatic HDR Metadata

FFEncoder will automatically fetch and fill HDR metadata before encoding begins. This includes:

> **NOTE:** Color Range (Limited) and Chroma Subsampling (4:2:0) are currently hard coded as they are the same for every source I've seen.

- Mastering Display Color Primaries (Display P3 and BT.2020 supported)
- Pixel format
- Color Space (Matrix Coefficients)
- Color Primaries
- Color Transfer Characteristics
- Maximum/Minimum Luminance
- Maximum Content Light Level
- Maximum Frame Average Light Level
- HDR10+ SEI packets (optional, see [dependencies](#dependency-installation))

---

## Rate Control Options

FFEncoder supports the following rate control options:

- **Constant Rate Factor (CRF)** - CRF encoding targets a specific quality level throughout, and isn't concerned with file size. Lower CRF values will result in a higher perceived quality and bitrate
  - Recommended values for 1080p content are between 16-24
  - Recommended values for 2160p content are between 17-26
- **Average Bitrate** - Average bitrate encoding targets a specific output file size, and isn't concerned with quality. There are 2 varieties of ABR encoding that FFEncoder supports:
  - **1-Pass** - This option uses a single pass, and isn't aware of the complexities of future frames and can only be scaled based on the past. This generally leads to lower overall quality, but is significantly faster than 2-pass
  - **2-Pass** - 2-Pass encoding uses a first pass to calculate bitrate distribution, which is then used to allocate bits more accurately on the second pass. While it's more time consuming than a single pass encode, quality is generally improved significantly. This script uses a custom combination of parameters for the first pass to help strike a balance between speed and quality

---

## Script Parameters

FFEncoder can accept the following parameters from the command line. Most parameters are optional and have default values, except the following three which are **mandatory**:

- InputPath
- Rate control preference (CRF or Average Bitrate)
- OutputPath

> An Asterisk <b>\*</b> denotes that the parameter is required only for its given parameter set (for example, you can choose either CRF or VideBitrate for rate control, but not both):

| Parameter Name           | Default | Mandatory     | Alias                  | Description                                                                                                                                              |
| ------------------------ | ------- | ------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **TestFrames**           | 0 (off) | False         | **T**                  | Integer value representing the number of test frames to encode. When enabled, encoding starts at 00:01:30 so that title screens are skipped              |
| **Help**                 | False   | <b>\*</b>True | **H**, **/?**, **?**   | Switch to display help information                                                                                                                       |
| **InputPath**            | N/A     | True          | **I**                  | The path to the source file (to be encoded)                                                                                                              |
| **Audio**                | Copy    | False         | **A**                  | Audio preference for the primary stream. See [Audio Options](#audio-options) for more info                                                               |
| **AudioBitrate**         | Codec   | False         | **AB**, **ABitrate**   | Specifies the bitrate for `-Audio` (primary stream). Compatible with AAC, FDK AAC, AC3, EAC3, and DTS. See [Audio Options](#audio-options)               |
| **Stereo**               | False   | False         | **2CH**, **ST**        | Switch to downmix the first audio track to stereo. See [Audio Options](#audio-options)                                                                   |
| **Audio2**               | None    | False         | **A2**                 | Audio preference for the secondary stream. See [Audio Options](#audio-options) for more info                                                             |
| **AudioBitrate2**        | Codec   | False         | **AB2**, **ABitrate2** | Specifies the bitrate for `-Audio2` (secondary stream). Compatible with AAC, FDK AAC, AC3, EAC3, and DTS. See [Audio Options](#audio-options)            |
| **Stereo2**              | False   | False         | **2CH2**, **ST2**      | Switch to downmix the second audio track to stereo. See [Audio Options](#audio-options)                                                                  |
| **Subtitles**            | Default | False         | **S**                  | Subtitle passthrough preference. See the [Subtitle Options](#subtitle-options) section for more info                                                     |
| **Preset**               | Slow    | False         | **P**                  | The x265 preset to be used. Ranges from placebo (slowest) to ultrafast (fastest). See x265 documentation for more info on preset parameters              |
| **CRF**                  | N/A     | <b>\*</b>True | **C**                  | Rate control parameter that targets a specific quality level. Ranges from 0.0 to 51.0. A lower value will result in a higher overall bitrate             |
| **VideoBitrate**         | N/A     | <b>\*</b>True | **VBitrate**           | Rate control parameter that targets a specific file size. Can be used as an alternative to CRF rate control when output size is a priority               |
| **Pass**                 | 2       | False         | **P**                  | The number of passes the encoder will perform for ABR encodes. Used with the `-VideoBitrate` parameter. Default is 2-Pass                                |
| **Deblock**              | -2, -2  | False         | **DBF**                | Deblock filter. The first value controls strength, and the second value controls the frequency of use                                                    |
| **AqMode**               | 2       | False         | **AQM**                | x265 Adaptive Quantization setting. Ranges from 0 - 4. See x265 documentation for more info on AQ Modes and how they work                                |
| **AqStrength**           | 1.00    | False         | **AQS**                | Adjusts the adaptive quantization offsets for AQ. Raising AqStrength higher than 2 will drastically affect the QP offsets, and can lead to high bitrates |
| **PsyRd**                | 2.00    | False         | **PRD**                | Psycho-visual enhancement. Higher values of PsyRd strongly favor similar energy over blur. See x265 documentation for more info                          |
| **PsyRdoq**              | Preset  | False         | **PRDQ**               | Psycho-visual enhancement. Favors high AC energy in the reconstructed image, but it less efficient than PsyRd. See x265 documentation for more info      |
| **QComp**                | 0.60    | False         | **Q**                  | Sets the quantizer curve compression factor, which effects the bitrate variance throughout the encode. Must be between 0.50 and 1.0                      |
| **BFrames**              | Preset  | False         | **B**                  | The number of consecutive B-Frames within a GOP. This is especially helpful for test encodes to determine the ideal number of B-Frames to use            |
| **BIntra**               | Preset  | False         | **BINT**               | Enables the evaluation of intra modes in B slices. Has a minor impact on performance                                                                     |
| **StrongIntraSmoothing** | 1 (on)  | False         | **SIS**                | Enable/disable strong-intra-smoothing. Accepted values are 1 (on) and 0 (off)                                                                            |
| **FrameThreads**         | System  | False         | **FT**                 | Set frame threads. More threads equate to faster encoding, but with a decrease in quality. System default is based on the number of logical CPU cores    |
| **Subme**                | Preset  | False         | **SM**, **SPM**        | The amount of subpel motion refinement to perform. At values larger than 2, chroma residual cost is included. Has a significant performance impact       |
| **FFMpegExtra**          | N/A     | False         | **FE**                 | Pass additional settings to ffmpeg as a generic array of single and multi-valued elements. Useful for options not covered by other parameters            |
| **x265Extra**            | N/A     | False         | **XE**                 | Pass additional settings to the x265 encoder as a hashtable of values. Useful for options not covered by other parameters                                |
| **NoiseReduction**       | 0, 0    | False         | **NR**                 | Noise reduction filter. The first value represents intra frames, and the second value inter frames; values range from 0-2000. Useful for grainy sources  |
| **OutputPath**           | N/A     | True          | **O**                  | The path to the encoded output file                                                                                                                      |
| **RemoveFiles**          | False   | False         | **Del**, **RM**        | Switch that deletes extra files generated by the script (crop file, log file, etc.). Does not delete the input, output, or report files                  |
| **GenerateReport**       | False   | False         | **Report**, **GR**     | Switch that generates a report of the encode. Data is pulled from the log file and written in a reading friendly format                                  |
| **Deinterlace**          | False   | False         | **DI**                 | Switch to enable deinterlacing of interlaced content using yadif                                                                                         |

### Using the Extra Parameter Options

> **WARNING**: The script **does not** check syntax, and assumes you know what you're doing. Be sure to test, test, test!

You can pass additional arguments not provided by the script to both ffmpeg and x265 using the `-FFMpegExtra` and `-x265Extra` parameters, respectively.

`-FFMpegExtra` accepts a generic array that can receive single and multi-valued arguments. For options that receive no argument, i.e. `stats/nostats`, pass it as a single element; otherwise, use a hashtable. For example:

```PowerShell
#Pass additional arguments to ffmpeg using an array with a hashtable and a single value
.\FFEncoder.ps1 $InputPath -CRF 18 -FFMpegExtra @{ '-t', 20; '-stats_period' = 5 }, '-autorotate' -o $OutputPath
```

`-x265Extra` accepts a hashtable of values as input, in the form of `<key = value>`. For example:

```PowerShell
#Pass additional arguments to the x265 encoder using a hashtable of values
.\FFEncoder.ps1 $InputPath -CRF 18 -x265Extra @{ 'max-merge' = 1; 'max-tu-size' = 16 } -o $OutputPath
```

---

## Hard Coded Parameters

Video encoding is a subjective process, and I have my own personal preferences. The following parameters are hard coded (but can be changed easily):

- `no-sao` - I really hate the way sao looks, so it's disabled along with `selective-sao`. There's a reason it's earned the moniker "smooth all objects", and it makes everything look too waxy in my opinion
- `rc-lookahead=48` - I have found 48 (2 \* 24 fps) to be a number with good gains and no diminishing returns. This is recommended by many at the [doom9 forums](https://forum.doom9.org/showthread.php?t=175993)
- `keyint=192` - This is personal preference. I like to spend a few extra bits to insert more I-frames into a GOP, which helps with random seeking throughout the video. The bitrate increase is trivial
- `no-open-gop` - The UHD BD specification recommends that closed GOPs be used. in general, closed GOPs are preferred for streaming content. x264 uses closed GOPs by default. For more insight, listen to what [Ben Waggoner](https://streaminglearningcenter.com/articles/open-and-closed-gops-all-you-need-to-know.html) has to say on the topic

### Exclusive to First Pass ABR

x265 offers a `--no-slow-firstpass` option to speed up the first pass of a 2-Pass ABR encode, but it disables or lowers some very important quality related parameters like `--rd` and `--ref`. Because of this, I have come up with my own custom first pass parameters to help strike a balance between speed and quality. The following parameters are disabled or reduced during pass 1, regardless of the preset selected:

- `rect=0` - Rect is known to eat up CPU cycles for dinner, and so it's disabled. This is also used by `--no-slow-firstpass`
- `max-merge=2` - This is the default value for presets ultrafast - medium, and is meant to increase first pass speeds for presets slow - placebo. `--no-slow-firstpass` lowers this to 1
- `subme=2` - This is one of the settings set by `--no-slow-firstpass`
- `b-intra=0` - Disabled, regardless if it's enabled via parameter or preset

### Exclusive to 4K UHD Content

- `level-idc=5.1`, `high tier=1` - I have found this to be ideal for 4K content as `Main 10@L5@Main` only allows for a maximum bitrate of 25 mb/s (and 4K content sometimes exceeds this, especially if there is a lot of grain). I will add a parameter for this soon

### Exclusive to SDR Content 1080p and Below

- `merange=44` - The default value of 57 is a bit much for 1080p content, and it slows the encode with no noticeable gain

---

## Audio Options

FFEncoder supports the mapping/transcoding of 2 distinct audio streams to the output file. For audio that is transcoded, the primary audio stream is used as it's generally lossless (TrueHD, DTS-HD MA, LPCM, etc.). **It is never recommended to transcode from one lossy codec to another**; if the primary audio stream is lossy compressed, it is best to stream copy it instead of forcing a transcode.

FFEncoder currently supports the following audio options wih the `-Audio`/`-Audio2` parameters. When selecting a named codec (like EAC3, AC3, etc.) the script will go through the following checks:

1.  If either of the `-AudioBitrate` parameters are selected, the corresponding stream will be transcoded to the selected codec, regardless if an existing stream is present in the input file
2.  If the `-AudioBitrate` parameters are not present, the script will search the input file for a matching stream and stream copy it to the output file if found
3.  If no bitrate is specified and no existing stream is found, then the script will transcode to the selected codec at the default bitrates listed below:

> To copy Dolby Atmos streams, you **must** be using the latest ffmpeg build **or the script will fail**

| Type         | Values           | Default        | Description                                                                                                                             |
| ------------ | ---------------- | -------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| **Copy**     | `copy`, `c`      | N/A            | Passes through the primary audio stream without re-encoding                                                                             |
| **Copy All** | `copyall`, `ca`  | N/A            | Passes through all audio streams from the input to the output without re-encoding                                                       |
| **AAC**      | `aac`            | 512 kb/s       | Converts the primary audio stream to AAC using ffmpeg's native CBR encoder. Compatible with the `-AudioBitrate` parameters              |
| **FDK AAC**  | `fdkaac`, `faac` | Variable (VBR) | Converts the primary audio stream to AAC using libfdk_aac. Compatible with the `-AudioBitrate` parameters. See note below for more info |
| **AAC_AT**   | `aac_at`         | Variable (VBR) | Converts the primary audio stream to AAC using Apple Core Audio Toolbox (MacOS only). Compatible with the `-AudioBitrate` parameters    |
| **AC3**      | `ac3`, `dd`      | 640 kb/s       | Dolby Digital. Compatible with the `-AudioBitrate` parameters                                                                           |
| **E-AC3**    | `eac3`           | 448 kb/s       | Dolby Digital Plus. Compatible with the `-AudioBitrate` parameters                                                                      |
| **DTS**      | `dts`            | Variable (VBR) | DTS Core audio. **Warning**: ffmpeg's DTS encoder is "experimental". Compatible with the `-AudioBitrate` parameters                     |
| **FLAC**     | `flac`, `f`      | Variable (VBR) | Converts the primary audio stream to FLAC lossless audio using ffmpeg's native FLAC encoder                                             |
| **Stream #** | `0-5`            | N/A            | Select an audio stream using its stream identifier in ffmpeg/ffprobe. Not compatible with the `-Stereo` parameters                      |
| **None**     | `none`, `n`      | N/A            | No audio streams will be added to the output file                                                                                       |

---

### Using the libfdk_aac Encoder

FFEncoder includes support for Fraunhofer's libfdk_aac, even though it is not included in a standard ffmpeg executable. Due to a conflict with ffmpeg's GPL, libfdk_aac cannot be distributed with any official ffmpeg binaries, but it can be included when compiling ffmpeg manually from source. For more info, see [Dependencies](#Dependencies).

One of the benefits of the FDK encoder is that it supports variable bitrate (VBR). When using the `-AudioBitrate`/`-AudioBitrate2` parameters with `fdkaac`, **values 1-5 are used to signal VBR**. 1 = lowest quality and 5 = highest quality.

### Using the aac_at Encoder

When running FFEncoder on a Mac computer, you gain access to Apple's Core AudioToolbox AAC encoder via the `aac_at` argument. AudioToolbox is, by default, a variable Bitrate (VBR) encoder, but can accept the following values using `-AudioBitrate`/`-AudioBitrate2`:

- -1 - Auto (VBR)
- 0 - Constant bitrate (CBR)
- 1 - Long-term Average bitrate (ABR)
- 2 - Constrained variable bitrate (VBR)
- 3 - Variable bitrate (VBR)

### Downmixing Multi-Channel Audio to Stereo

With FFEncoder, you can downmix either of the two output streams to stereo using the `-Stereo`/`-Stereo2` parameters. The process uses an audio filter that retains the LFE (bass) track in the final mix, which is discarded when using `-ac 2` in ffmpeg directly.

When using any combination of `copy`/`c`/`copyall`/`ca` and `-Stereo`/`-Stereo2`, the script will multiplex the primary audio stream out of the container and encode it separately; this is because ffmpeg cannot stream copy and filter at the same time. See [here](https://stackoverflow.com/questions/53518589/how-to-use-filtering-and-stream-copy-together-with-ffmpeg) for a nice explanation. Once the primary encode finishes, the external audio file (now converted to stereo) is multiplexed back into the primary container with the other streams selected.

---

## Subtitle Options

FFEncoder can copy subtitle streams from the input file to the output file using the `-Subtitles` / `s` parameter. I have not added subtitle transcoding because, frankly, ffmpeg is not the best option for this. If you need to convert subtitles from one format to the other, I recommend using [Subtitle Edit](https://www.nikse.dk/SubtitleEdit/) (Windows only).

The different parameter options are:

- `default` / `d` - Copies the default (primary) subtitle stream from the input file
- `all` / `a` - Copies all subtitle streams from the input file
- `none` / `n` - Excludes subtitles from the output entirely
- **Language** - You can also specify a language to copy, and FFEncoder will search the input for all subtitles matching that language. If the specified language isn't found, no subtitles will be copied. The following languages are supported using the language code on the right:

  | Language  | Code  |
  | --------- | ----- |
  | Chinese   | `chi` |
  | Czech     | `cze` |
  | Danish    | `dan` |
  | Dutch     | `dut` |
  | English   | `eng` |
  | Finnish   | `fin` |
  | French    | `fre` |
  | German    | `ger` |
  | Greek     | `gre` |
  | Korean    | `kor` |
  | Norwegian | `nor` |
  | Polish    | `pol` |
  | Romanian  | `rum` |
  | Spanish   | `spa` |
