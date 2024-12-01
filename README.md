# Playground
Algo Trading playground in OCaml

## TCP server address via WSL 

- Run `ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1`


## NinjaTrader Time series format

### Daily Bars Format

`yyyyMMdd;open price;high price;low price;close price;volume`

### Minute Bars Format

`yyyyMMdd HHmmss;open price;high price;low price;close price;volume`

### Tick Format (Second Granularity)

`yyyyMMdd HHmmss;price;volume`

### Tick Format (Sub Second Granularity)

`yyyyMMdd HHmmss fffffff;price;volume`
