# vquery

A small utility to fetch data from Vega APIs.


## Features

- Automatically prefixes data node URL
- Can use a custom URL if set via environment variable (VEGA_DATA_NODE)
- Requests next page if results don't fit in a single page
- Emits result data in JSON lines format (suitable for piping rows to `grep`, `visidata`, etc.)
- Limit number of pages, customisable by environment variable (VEGA_MAX_PAGES)


## Running it

Run or compile the script yourself with [Fennel](https://fennel-lang.org/). You can also download a binary (which bundles the transpiled output and a Lua runtime into a single excutable) from the release page. Currently the only binary release is for macOS but cross compilation for other systems is theoretically possible, and I may also release the transpiled Lua output in future.


## Usage examples

List markets:

```
% vquery markets
```

Get up to 5 pages of positions:

```
% VEGA_MAX_PAHGES=5 vquery positions
```

View open depsosits in visidata:

```
% vquery deposits | grep STATUS_OPEN | vd
```

See all accounts and their balances on Fairground testnet:

```
VEGA_DATA_NODE=https://api.n07.testnet.vega.xyz vquery accounts
```


## Bonus: zsh aliases

Add these aliases to you `.zshrc` file to enable quickly querying mainnet or Fairground.

This gives you:
- Shorter names, save your fingers!
- Separate aliases `qv` (query Vega) for mainnet and `qf` (query Fairground) for testnet
- Takes a second parameter to filter the output using grep
- Automatically passes the response to Visidata
- Saves the Visidate output (when you exit vd with ctrl-q) to `.last.vega.tsv` or `.last.fairground.tsv` in your home directory

```
function mainnet() {
  vquery "$1" \
    | grep -i "$2" \
    | vd 2&>/dev/null \
    | tee ${3:-~/.last.vega.tsv}
}
alias qv=mainnet
function fairground() {
  vquery "https://api.n07.testnet.vega.xyz/api/v2/$1" \
    | grep -i "$2" \
    | vd 2&>/dev/null \
    | tee ${3:-~/.last.fairground.tsv}
}
alias qf=fairground
```
