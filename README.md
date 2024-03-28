# vquery

A small utility to fetch data from [Vega](https://vega.xyz/) APIs.


## Features

- Automatically prefixes data node URL
- Can use a custom URL if set via environment variable (VEGA_DATA_NODE)
- Requests more pages of data automatically if results don't fit in a single page
- Emits result data in JSON lines format (suitable for piping rows to `grep`, `visidata`, etc.)
- Limit number of pages, customisable by environment variable (VEGA_MAX_PAGES)
- Emits results as they arrive for multi-page queries


## Running it

For the impatient Mac user (h/t @edd):

```
brew install saulpw/vd/visidata; brew install fennel; brew install luarocks; luarocks install dkjson; make; ./vquery markets | vd
```

Run or compile the script yourself with [Fennel](https://fennel-lang.org/). It requires the [dkjson]([http://dkolf.de/dkjson-lua/](https://luarocks.org/modules/dhkolf/dkjson)) library, which can be installed with [Luarocks](https://luarocks.org/) or probably some other way if you prefer.

You can also download a binary (which bundles the transpiled output and a Lua runtime into a single excutable) from the [release](https://github.com/barnabee/vquery/releases/latest) page. Currently the only binary release is for macOS but [cross compilation for other systems is theoretically possible](https://wiki.fennel-lang.org/Distribution#binary-executable), and I may also release the transpiled Lua output in future.

On a Mac, running `make install` will compile the binary and copy it to `~/Library/bin`, at least if you have Fennel and Lua installed via [Homebrew](https://brew.sh).


## Usage examples

List markets:

```
% vquery markets
```

Get up to 5 pages of positions:

```
% VEGA_MAX_PAHGES=5 vquery positions
```

View open depsosits in [Visidata](https://www.visidata.org/):

```
% vquery deposits | grep STATUS_OPEN | vd
```

See all accounts and their balances on Fairground testnet:

```
% VEGA_DATA_NODE=https://api.n07.testnet.vega.xyz vquery accounts
```


## Bonus: zsh aliases

Add these aliases to you `.zshrc` file to enable quickly querying mainnet or Fairground.

This gives you:
- Shorter names, save your fingers!
- Separate aliases `qv` (query Vega) for mainnet and `qf` (query Fairground) for testnet
- Takes a second parameter to filter the output using grep
- Automatically passes the response to [Visidata](https://www.visidata.org/)
- Saves the Visidata output (when you exit vd with ctrl-q) to a file specified with the 3rd argument, or `.last.vega.tsv` or `.last.fairground.tsv` in your home directory if no file is specified

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
