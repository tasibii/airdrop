source .env
source .env.debug

# Read script
echo Which script do you want to run?
read script

echo Enter the network to which you want to folk:
read network

# example: cast calldata 'deploySample()'
echo Enter calldata of target function:
read calldata

# Read script options
echo Enter script options, or press enter if none:
read opts

# Run the script
echo Running Script: $script...

forge script $script \
    --sig 'run(bytes)' $(eval "$calldata") \
    -f $network \
    -vvvv \
    --etherscan-api-key $network \
    --private-key $DEPLOYER_KEY \
    $opts