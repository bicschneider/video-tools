# Installation
se [Installation af ffmpeg](installation-af-ffmpeg.md) og installation af `klip-video.sh`

# Opdater klip-video.sh
Opdater ofte klip-video.sh
- Åben terminalen
- `git -C $(dirname $(which klip-video.sh)) pull` 

# Brug klip-video.sh
- Find videoen i `Stifinder`/ `Explorer`
- Åben terminalen som beskrevet i installationen
- Find videoen:
    -  `ls` - lister filer hvor du står
- Start klip-video.sh med en video som parameter
    - `klip-video.sh 07102023_rodovre_nordsjaelland_2353294509.mp4`
    - INFO: hvis den ikke kan finde `klip-video.sh` så er der gået noget galt i installationen
    - HINT: Tryk på `<tab>` og der skulle gerne komme en liste med filer inklusive videoer på skærmen. Nu kan du taste de førte karakterer af video navnet og tryk `<tab>` igen og nu skulle den gerne auto-complete filnavnet
    - Nu skulle der gerne være hjælp på skærmen om hvordan du skal gøre 

# Download et stream link
## Via browseren
- Find linket via Developer Tools -> network i browseren
- Sæt url ind i denne kommando
    - download-stream.sh [video-url]
- Hvis du vil "klippe" den i download så kan du komma-separere tidsintervaler med start og til sektioner ss=00:01@to=00:02. Denne metode kan også bruges til at download parallelt, da hver sektioner downloades parallelt og sammensættes bagefter
    - download-stream.sh [video-url] ss=00:05@to=00:10,ss=14:20@to=49:02,ss=1:03:49@to=1:49:00

