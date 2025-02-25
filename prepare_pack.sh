# Download the client jar from mojang to extract assets
wget -O client.jar https://launcher.mojang.com/v1/objects/37fd3c903861eeff3bc24b71eed48f828b5269c8/client.jar
unzip -o client.jar "assets/minecraft/*" -d extracted/

# Set input field seperator to space for our while loop
IFS=' '

# Copy textures defined in required_files.txt over to the pack
while read -r p || [ -n "$p" ]; do
  read -rafilesToCopy<<< "$p"
  echo "extracted/${filesToCopy[0]} build/${filesToCopy[1]}"
  mkdir -p "build/${filesToCopy[1]}"
  cp "extracted/${filesToCopy[0]}" "build/${filesToCopy[1]}"
done <required_files.txt

# Set our input field seperator back to new line
IFS=$'\n'

# Create required sprites with Imagemagick
convert -append extracted/assets/minecraft/textures/particle/sweep_*.png -define png:format=png8 build/textures/geyser/particle/sweep_attack.png

# Clean-up files
rm client.jar
rm -r extracted

# Copy over the src files
cp -r src/* build/

# Copy over the static files
cp LICENSE build/
cp mojang.md build/
cp README.md build/

# One-line our JSON files if the script is called with -jc (./prepare_pack.sh -jc)
if [[ ${1} == "-jc" ]]
then
  for i in $(find . -type f -name "*.json")
  do
    # Note that we must use a temp file, as awk does not support in-place editting
    awk -v ORS= 'BEGIN {FS = OFS = "\""}/^[[:blank:]]*$/ {next}{for (i=1; i<=NF; i+=2) gsub(/[[:space:]]/,"",$i);sub("\r$", "")} 1' ${i} > tmp && mv tmp ${i}
  done
fi
