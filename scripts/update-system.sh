#!/usr/bin/env bash
# Datum des letzten Ausführens: 15.08.2024

# Pfad zur Batteriekapazität
bat_capacity_path="/sys/class/power_supply/BAT0/capacity"

# Überprüft, ob der Pfad existiert
if [ ! -f "$bat_capacity_path" ]; then
  echo -e "\033[0;31mError: Batteriekapazität konnte nicht gefunden werden.\033[0m"
  exit 1
fi

# Liest die Batteriekapazität aus
bat_capacity=$(cat "$bat_capacity_path")

# Überprüft die Batteriekapazität
if [[ $bat_capacity -le 12 ]]; then
  echo -e "\033[0;31mBattery capacity too low!\033[0m"
  exit 1
fi
# Wenn die Batteriekapazität ausreichend ist, wird nichts ausgegeben und das Skript endet normal.

#---------------------------------------------------------------------------------------

# Schwellenwert für RAM-Nutzung in Prozent
threshold=80

# Aktuelle RAM-Nutzung in Prozent ermitteln
ram_usage=$(free | awk '/^Mem:/ {printf("%.0f"), $3/$2 * 100.0}')

# Überprüfen, ob die RAM-Nutzung den Schwellenwert überschreitet
if [ "$ram_usage" -gt "$threshold" ]; then
  echo -e "\033[0;31mRAM usage too high! Currently using $ram_usage% of RAM.\033[0m"
  exit 1
fi
# Wenn die RAM-Nutzung unter dem Schwellenwert liegt, wird nichts ausgegeben und das Skript endet normal.

#-----------------------------------------------------------------------------------------

# Aktuelles Datum und Uhrzeit anzeigen
echo "Aktuelles Datum und Uhrzeit: $(date +"%d.%m.%Y %H:%M")"

# Pfad zur Datei selbst
DATEI=$(realpath "$0")

# Überprüfe, ob die Datei existiert, um das Datum des letzten Ausführens zu lesen
if [ -f "$DATEI" ]; then
  letztesDatum=$(sed -n '2p' "$DATEI" | grep -oP '\d{2}\.\d{2}\.\d{4}')

  if [ -n "$letztesDatum" ]; then
    formatiertesDatum=$(echo $letztesDatum | awk -F"." '{printf "%04d-%02d-%02d", $3, $2, $1}')
    sekLetztesDatum=$(date -d "$formatiertesDatum" +%s)
    sekHeute=$(date +%s)
    diffTage=$(( (sekHeute - sekLetztesDatum) / 86400 ))
    echo "Das Skript wurde zuletzt vor $diffTage Tagen am $letztesDatum ausgeführt."
  else
    echo "Das Skript wird zum ersten Mal ausgeführt."
  fi
else
  echo "Fehler: Die Datei konnte nicht gefunden werden."
  exit 1
fi

# Neues Datum
newDate=$(date "+%d.%m.%Y")

# Aktualisiere das Datum des letzten Ausführens in der Datei
sed -i "2s/.*/# Datum des letzten Ausführens: $newDate/" "$DATEI"

#------------------------------------------------------------------------------------------

# Bash Historie aufräumen
echo -ne "\e[1;34m>>\e[0m Möchtest du die Bash-Historie reinigen? (Y/n): "
read clean_decision
clean_decision=${clean_decision:-y}

if [[ $clean_decision =~ ^[Yy]$ ]]; then
  password=$(kdialog --password "Enter the keyword, that should be removed from history")
  if [[ -z "$password" ]] || type "$password" &>/dev/null; then
    echo "The input cannot be empty or a valid command."
  else
    temp_file=$(mktemp)
    removed=$(grep -- "$password" ~/.bash_history)

    if [[ ! "$removed" =~ [^[:space:]] ]]; then
      echo "No line with your keyword!"
    else
      echo "Removed the following lines containing your keyword: "
      echo "$removed"
      echo -ne "\e[1;34m>>\e[0m Do you want to remove these commands from your history? (y/N): "
      read remove_decision
      remove_decision=${remove_decision:-y}

      if [[ $remove_decision =~ ^[Yy]$ ]]; then
        grep -v -- "$password" ~/.bash_history > "$temp_file"
        mv "$temp_file" ~/.bash_history
        echo "Commands have been removed."
      else
        echo "Commands have not been removed."
      fi
    fi

    [[ -f $temp_file ]] && rm "$temp_file"
  fi

  # Laden der .bashrc, um sicherzustellen, dass Aliase verfügbar sind
  if [ -f ~/.bashrc ]; then
    source ~/.bashrc
  fi

  histfile="$HOME/.bash_history"
  tmpfile_dup=$(mktemp)

  awk '!seen[$0]++' "$histfile" > "$tmpfile_dup"
  mv "$tmpfile_dup" "$histfile"
  echo "Duplicates removed."

  check_command() {
    type "$1" &>/dev/null
  }

  temp_file=$(mktemp)
  removed_commands=$(mktemp)

  commands_before=$(wc -l < "$histfile")

  while IFS= read -r command; do
    if [[ ! $command =~ ^[[:space:]]*$ ]]; then
      cmd=$(echo $command | cut -d ' ' -f1)

      if [[ $cmd == "sudo" ]]; then
        cmd=$(echo $command | cut -d ' ' -f2)
      fi

      if check_command "$cmd"; then
        echo "$command" >> "$temp_file"
      else
        echo "$command" >> "$removed_commands"
      fi
    fi
  done < "$histfile"

  if [[ -s $removed_commands ]]; then
    echo -ne "\e[1;34m>>\e[0m Möchtest du die Befehle sehen, die entfernt werden würden? (y/N): "
    read show_decision
    show_decision=${show_decision:-n}

    if [[ $show_decision == "y" ]]; then
      echo "Entfernte Befehle:"
      cat "$removed_commands"
    fi

    echo -ne "\e[1;34m>>\e[0m Möchtest du diese Befehle wirklich entfernen? (Y/n): "
    read remove_decision
    remove_decision=${remove_decision:-y}

    if [[ $remove_decision =~ ^[Yy]$ ]]; then
      mv "$temp_file" "$histfile"
      echo "Befehle wurden entfernt."
    else
      echo "Befehle wurden NICHT entfernt."
      rm "$temp_file"
    fi
  else
    echo "Historie hat keine Befehle mit Syntaxfehlern"
  fi

  commands_after=$(wc -l < "$histfile")

  if [ "$commands_before" -ne "$commands_after" ]; then
    echo "Anzahl der Befehle in der Historie von $commands_before Befehlen auf $commands_after reduziert."
  else
    echo "Es wurden keine Befehle entfernt, die Anzahl der Befehle in der history ist immer noch $commands_before."
  fi

  rm "$removed_commands"
fi

#------------------------------------------------------------------

# Funktion zur Überprüfung der Internetverbindung
check_internet() {
  wget -q --spider http://google.com
  return $?
}

# Den Benutzer fragen, ob das System aktualisiert werden soll
echo -ne "\e[1;34m>>\e[0m Möchtest du das System jetzt aktualisieren? (Y/n): "
read update_answer
update_answer=${update_answer:-y}

if [[ $update_answer =~ ^[Yy]$ ]]; then
  echo "System wird aktualisiert..."

  if check_internet; then
    echo "Internetverbindung erkannt. Aktualisierung wird gestartet..."

    sudo nix-channel --update 
    sudo nixos-rebuild switch --upgrade  
  else
    echo "Keine Internetverbindung erkannt. Systemaktualisierung übersprungen."
  fi
fi

#------------------------------------------------------------------------------------------------------------------------------------

# Frage, ob System-Generations-Reinigung durchgeführt werden soll
echo -ne "\e[1;34m>>\e[0m Möchtest du die System-Generations-Reinigung durchführen? (Y/n): "
read clean_generations
clean_generations=${clean_generations:-y}

if [[ $clean_generations =~ ^[Yy]$ ]]; then
  set -euo pipefail

  ## Defaults
  keepGensDef=10; keepDaysDef=30
  keepGens=$keepGensDef; keepDays=$keepDaysDef

  ## Usage
  usage () {
    printf "Usage:\n\t ./trim-generations.sh <keep-gernerations> <keep-days> <profile> \n\n
  (defaults are: Keep-Gens=$keepGensDef Keep-Days=$keepDaysDef Profile=user)\n\n"
    printf "If you enter any parameters, you must enter all three, or none to use defaults.\n"
    printf "Example:\n\t trim-generations.sh 15 10 home-manager\n"
    printf "  this will work on the home-manager profile and keep all generations from the\n"
    printf "last 10 days, and keep at least 15 generations no matter how old.\n"
    printf "\nProfiles available are:\tuser, home-manager, channels, system (root)\n"
    printf "\n-h or --help prints this help text."
  }

  if [ $# -eq 1 ]; then
    if [ $1 = "-h" ]; then
      usage
      exit 1
    fi
    if [ $1 = "--help" ]; then
      usage
      exit 2
    fi
    printf "Dont recognise your option exiting..\n\n"
    usage
    exit 3

  elif [ $# -eq 0 ]; then
    printf "The current defaults are:\n Keep-Gens=$keepGensDef Keep-Days=$keepDaysDef \n\n"
    read -p "Keep these defaults? (y/n):" answer

    case "$answer" in
      [yY1] )
        printf "Using defaults..\n"
        ;;
      [nN0] )
        printf "ok, doing nothing, exiting..\n"
        exit 6
        ;;
      *     )
        printf "%b" "Doing nothing, exiting.."
        exit 7
        ;;
    esac
  fi

  ## Handle parameters (and change if root)
  if [[ $EUID -ne 0 ]]; then
    profile=$(readlink /home/$USER/.nix-profile)
  else
    if [ -d /nix/var/nix/profiles/system ]; then
      profile="/nix/var/nix/profiles/system"
    elif [ -d /nix/var/nix/profiles/default ]; then
      profile="/nix/var/nix/profiles/default"
    else
      echo "Cant find profile for root. Exiting"
      exit 8
    fi
  fi

  if (( $# < 1 )); then
    printf "Keeping default: $keepGensDef generations OR $keepDaysDef days, whichever is more\n"
  elif [[ $# -le 2 ]]; then
    printf "\nError: Not enough arguments.\n\n" >&2
    usage
    exit 1
  elif (( $# > 4)); then
    printf "\nError: Too many arguments.\n\n" >&2
    usage
    exit 2
  else
    if [ $1 -lt 1 ]; then
      printf "using Gen numbers less than 1 not recommended. Setting to min=1\n"
      read -p "is that ok? (y/n): " asnwer
      case "$asnwer" in
        [yY1] )
          printf "ok, continuing..\n"
          ;;
        [nN0] )
          printf "ok, doing nothing, exiting..\n"
          exit 6
          ;;
        *     )
          printf "%b" "Doing nothing, exiting.."
          exit 7
          ;;
      esac
    fi
    if [ $2 -lt 0 ]; then
      printf "using negative days number not recommended. Setting to min=0\n"
      read -p "is that ok? (y/n): " asnwer

      case "$asnwer" in
        [yY1] )
          printf "ok, continuing..\n"
          ;;
        [nN0] )
          printf "ok, doing nothing, exiting..\n"
          exit 6
          ;;
        *     )
          printf "%b" "Doing nothing, exiting.."
          exit 7
          ;;
      esac
    fi

    keepGens=$1; keepDays=$2;
    (( keepGens < 1 )) && keepGens=1
    (( keepDays < 0 )) && keepDays=0

    if [[ $EUID -ne 0 ]]; then
      if [[ $3 == "user" ]] || [[ $3 == "default" ]]; then
        profile=$(readlink /home/$USER/.nix-profile)
      elif [[ $3 == "home-manager" ]]; then
        profile="${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
      elif [[ $3 == "channels" ]]; then
        profile="/nix/var/nix/profiles/per-user/$USER/channels"
      else
        printf "\nError: Do not understand your third argument. Should be one of: (user / home-manager/ channels)\n\n"
        usage
        exit 3
      fi
    else
      if [[ $3 == "system" ]]; then
        profile="/nix/var/nix/profiles/system"
      elif [[ $3 == "user" ]] || [[ $3 == "default" ]]; then
        profile="/nix/var/nix/profiles/default"
      else
        printf "\nError: Do not understand your third argument. Should be one of: (user / system)\n\n"
        usage
        exit 3
      fi
    fi

    printf "OK! \t Keep Gens = $keepGens \t Keep Days = $keepDays\n\n"
  fi

  printf "Operating on profile: \t $profile\n\n"

  ## Runs at the end, to decide whether to delete profiles that match chosen parameters.
  choose () {
    local default="$1"
    local prompt="$2"
    local answer

    read -p "$prompt" answer
    [ -z "$answer" ] && answer="$default"

    case "$answer" in
      [yY1] )
        nix-env --delete-generations -p $profile ${!gens[@]}
        exit 0
        ;;
      [nN0] )
        printf "Ok doing nothing exiting..\n"
        exit 6
        ;;
      *     )
        printf "%b" "Unexpected answer '$answer'!" >&2
        exit 7
        ;;
    esac
  }

  ## Query nix-env for generations list
  IFS=$'\n' nixGens=( $(nix-env --list-generations -p $profile | sed 's:^\s*::; s:\s*$::' | tr '\t' ' ' | tr -s ' ') )
  timeNow=$(date +%s)

  ## Get info on oldest generation
  IFS=' ' read -r -a oldestGenArr <<< "${nixGens[0]}"
  oldestGen=${oldestGenArr[0]}
  oldestDate=${oldestGenArr[1]}
  printf "%-30s %s\n" "oldest generation:" $oldestGen
  printf "%-30s %s\n" "oldest generation created:" $oldestDate
  oldestTime=$(date -d "$oldestDate" +%s)
  oldestElapsedSecs=$((timeNow-oldestTime))
  oldestElapsedMins=$((oldestElapsedSecs/60))
  oldestElapsedHours=$((oldestElapsedMins/60))
  oldestElapsedDays=$((oldestElapsedHours/24))
  printf "%-30s %s\n" "minutes before now:" $oldestElapsedMins
  printf "%-30s %s\n" "hours before now:" $oldestElapsedHours
  printf "%-30s %s\n" "days before now:" $oldestElapsedDays

  ## Get info on current generation
  for i in "${nixGens[@]}"; do
    IFS=' ' read -r -a iGenArr <<< "$i"
    genNumber=${iGenArr[0]}
    genDate=${iGenArr[1]}

    if [[ "$i" =~ current ]]; then
      currentGen=$genNumber
      printf "%-30s %s\n" "current generation:" $currentGen
      currentDate=$genDate
      printf "%-30s %s\n" "current generation created:" $currentDate
      currentTime=$(date -d "$currentDate" +%s)
      currentElapsedSecs=$((timeNow-currentTime))
      currentElapsedMins=$((currentElapsedSecs/60))
      currentElapsedHours=$((currentElapsedMins/60))
      currentElapsedDays=$((currentElapsedHours/24))
      printf "%-30s %s\n" "minutes before now:" $currentElapsedMins
      printf "%-30s %s\n" "hours before now:" $currentElapsedHours
      printf "%-30s %s\n" "days before now:" $currentElapsedDays
    fi
  done

  ## Compare oldest and current generations
  timeBetweenOldestAndCurrent=$((currentTime-oldestTime))
  elapsedDays=$((timeBetweenOldestAndCurrent/60/60/24))
  generationsDiff=$((currentGen-oldestGen))

  ## Figure out what we should do, based on generations and options
  if [[ elapsedDays -le keepDays ]]; then
    printf "All generations are no more than $keepDays days older than current generation. \nOldest gen days difference from current gen: $elapsedDays \n\n\tNothing to do!\n"
    exit 4
  elif [[ generationsDiff -lt keepGens ]]; then
    printf "Oldest generation ($oldestGen) is only $generationsDiff generations behind current ($currentGen). \n\n\t Nothing to do!\n"
    exit 5
  else
    printf "\tSomething to do...\n"
    declare -a gens

    for i in "${nixGens[@]}"; do
      IFS=' ' read -r -a iGenArr <<< "$i"
      genNumber=${iGenArr[0]}
      genDiff=$((currentGen-genNumber))
      genDate=${iGenArr[1]}
      genTime=$(date -d "$genDate" +%s)
      elapsedSecs=$((timeNow-genTime))
      genDaysOld=$((elapsedSecs/60/60/24))

      if [[ genDaysOld -gt keepDays ]] && [[ genDiff -ge keepGens ]]; then
        gens["$genNumber"]="$genDate, $genDaysOld day(s) old"
      fi
    done

    printf "\nFound the following generation(s) to delete:\n"
    for K in "${!gens[@]}"; do
      printf "generation $K \t ${gens[$K]}\n"
    done
    printf "\n"
    choose "y" "Do you want to delete these? [Y/n]: "
  fi

  echo "Systemaktualisierung abgeschlossen."
fi

#--------------------------------------------------------------------------------


# URL des Git-Repositories festlegen
repo_url="git@github.com:tombo0909/data.git" 

echo -ne "\e[1;34m>>\e[0m Möchtest du das Repository aktualisieren? (Y/n): "
read antwort
antwort=${antwort:-y}

if [[ $antwort == "y" || $antwort == "Y" ]]; then
  temp_dir=$(mktemp -d 2>/dev/null)

  echo "Bitte stecken Sie Ihren YubiKey ein."
  while [ $(lsusb | grep -c 'Yubico') -eq 0 ]; do
    echo -ne "Warten auf YubiKey...\r"
    sleep 0.7
    echo -ne "                     \r"
    sleep 0.7
  done
  echo "YubiKey erkannt."


  # Ins lokale Repository wechseln
  cd /home/tom/data

  # Dateien ins lokale Repository kopieren
  cp -r /home/tom/.mozilla/firefox/*.default/sessionstore-backups/* /home/tom/data/firefox/

  # Änderungen committen und pushen
  git add .
  git commit -m "Update data"
  git push
  echo "Data wurde erfolgreich aktualisiert und gepusht."

  cd /home/tom/
else
  echo "Aktualisierung wurde abgebrochen."
fi

exit
