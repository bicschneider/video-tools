# Instruktioner til installation af ffmpeg:

## MacOS
- Sørg for at være på nyeste hovedopdatering af MacOS til din laptop/maskine .. ( Er der opdateringer tilgengængelige ? )
- <cmd> + <space>/<mellem-rum>
- indtast "Terminal" + <enter>/<retur>
- der kommer nu en tekst terminal op
- kopier og indsæt:  
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"` + `<enter>/<retur>`
    - nu bliver der hentet og kørt et installation script/program, så programmet "homebrew" bliver installeret
  - Reference: https://phoenixnap.com/kb/install-homebrew-on-mac 
 - Nu skal vi installere programmet `ffmpeg`  ( ref: https://phoenixnap.com/kb/ffmpeg-mac )
    - `brew update`
    - `brew upgrade`
    - `brew install ffmpeg` 
    - prøv at skrive `ffmpeg + <enter>`
        - hvis der kommer en hjælpe besked
       - hvis den kommer ud med en fejl ala "jeg kender ikke ffmpeg" så skal vi fixe det.. :-)
 - Lav shortcut til Terminal
    - https://themacbeginner.com/open-terminal-window-directly-current-finder-location/
    - Reference: https://www.howtogeek.com/210147/how-to-open-terminal-in-the-current-os-x-finder-location/
 - Download en video fra OneDrive eller XPS og gem den i dit foretrukne sted
 - Find den i "Finder" 
 - Åben den folder i Terminal
   - nu skulle Terminalen gerne stå samme sted som videoen er gemt

## Windows
- Installer https://docs.chocolatey.org/en-us/choco/setup#non-administrative-install
- Installer `ffmpeg`
    - `choco install ffmpeg`
- Installer `git`
    - `chco install git`
- Åben `Git Bash`
    - clone dette repository
        - `git clone https://github.com/bicschneider/video-tools.git `
    - lav klip-video.sh tilgængeligt
        - `echo 'export PATH=$(pwd)/video-tools:$PATH' >> ~/.bashrc`
- Åben `Stifinder` / `Explorer` der hvor din video er gemt
- Høje-klik i dette tomme rum ( dvs ikke på nogen filer ) + vælg `Git Bash`
    -  Nu har du en `Git bash` terminal der hvor din video er
    - prøv at skrive `ls` + `<enter>`
        -  ... nu skulle du gerne se videoen i listen
    
# Nu burde du være klar til at konvertere videoer

-  

Nu kan du åbne videoen og find det først klip du vil gemme
Nu kan du lave en klip fra videoen
ffmpeg -i input.mp4 -ss 00:02:00 -t 00:07:28 part1.mp4
-i  = den downloadede video
-ss = Start tid
-t = hvor lang tid skal klippet være
Det sidste parameter er output videoklippet. i stedet for mellem, så bruge "-" og hvis du vi lave "kategorier" så kan fil navne ala "angreb--undertal--godt-5-0.mp4" .. 
Reference: How to Cut Sections out of an MP4 File with FFmpeg (markheath.net)

Hvis du gerne vil samle flere split til en samlet fil: Se sidst i denne: How to Cut Sections out of an MP4 File with FFmpeg (markheath.net)
