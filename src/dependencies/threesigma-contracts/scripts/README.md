## Installation
There is a requirement file for each Python script with the script's name concatenated with *Requirements.txt*. It is recommended to use a Python virtual enviroment to run solidity code that runs any scripts.

## Usage
This scripts are automatically used by the solidity contracts present in this repo. The scripts are called by the *ffi* function present in the foundry [Cheatcodes](https://book.getfoundry.sh/cheatcodes/ffi.html?highlight=ffi#ffi)


- MerkleTreeProvider.py - There is a conflict in the python packages *pysha3* and *sha3*, since the name of the imported module is *sha3* for both packages. The package needed for this script is *pysha3*, therefore the *sha3* package can't be installed.
