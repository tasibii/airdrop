source .env

echo Checking storage slot collision...

echo Enter the contract name:
read contract_name

echo Enter the network contract deployed:
read network

echo Enter the latest implementation address:
read latest_logic_address

latest=$(cast storage $latest_logic_address --rpc-url $network --etherscan-api-key $ETHERSCAN_KEY)
upcomming=$(forge inspect $contract_name storage --pretty)

formatted_latest=$(echo "$latest" | awk -F "|" 'NR > 2 { printf "%s: Type(%s) Slot(%s) Offset(%s) Bytes(%s)\n", $2, $3, $4, $5, $6 }' | sed '1d')
formatted_upcomming=$(echo "$upcomming" | awk -F "|" 'NR > 2 { printf "%s: Type(%s) Slot(%s) Offset(%s) Bytes(%s)\n", $2, $3, $4, $5, $6 }')

mkdir -p "./temp"

echo "$formatted_latest" > "./temp/latest.txt"
echo "$formatted_upcomming" > "./temp/upcomming.txt"
tmpDiff=$(diff "./temp/latest.txt" "./temp/upcomming.txt")

if [ ${#tmpDiff} -eq 0 ]; then 
    echo "No storage layout collisions were detected."
else 
    echo "$tmpDiff"
fi 

rm -rf "./temp"