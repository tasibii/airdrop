# Boundry template

This is a template for a Foundry project.

## Installation



To install with [Foundry](https://github.com/foundry-rs/foundry):

```
forge install [user]/[repo]
```

## Local development

This project uses [Foundry](https://github.com/foundry-rs/foundry) as the development framework.

### Dependencies

```
forge install
```

### Compilation

```
forge build
```

### Testing

```
forge test
```

### Contract deployment

Please create a `.env` file before deployment. An example can be found in `.env.template`.

#### Dryrun

```
./run.sh
```

Interacting with the shell
```
Which script do you want to run?
>>script/SampleDeploy.s.sol

Enter the network to which you want to folk:
>>fuji

Enter calldata of target function:
>>cast calldata 'deploySample()'


Enter script options, or press enter if none:
>>[enter]
```


### Live

```
./run.sh
```

Interacting with the shell
```
Which script do you want to run?
>>script/SampleDeploy.s.sol

Enter the network to which you want to folk:
>>fuji

Enter calldata of target function:
>>cast calldata 'deploySample()'

Enter script options, or press enter if none:
>>--broadcast --verify
```