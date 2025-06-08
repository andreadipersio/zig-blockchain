# Zig Blockchain

This is a toy project to play with [Zig Programming Language](https://ziglang.org/) and have fun with Blockchain.

### Disclaimer
I have limited experience with Zig and even less experience with Blockchain.

## Usage

### Pre requisite
Get yourself [Zig >= 0.9.1](https://ziglang.org/download/).

I can't have this running properly on Windows.

### Have fun with the blockchain

```
> zig build run
```

```
==================
= Zig Blockchain =
==================
Commands:
  list       - list all the blocks
  new <data> - store data in a new block
  last       - get the last block
  get <i>    - get block at index i, starting from 0.
  quit       - quit
  ?
```

Let's create some blocks with some data

```
> new "hello world"
=== Block
  data: "hello world"
  hash: 00008f59b1349d545f7366539fb101c559a135de963514f42f6ea89083d26a90
  prev_hash: 00000551fb3e39f4f36d2121a6043c71999059f733ab13561539ebfe57f85961
> new "foobar"
=== Block
  data: "foobar"
  hash: 00008421e3c5676e634f1cfe4f427dd24043179df679fe7c72889659e2fb99d8
  prev_hash: 00008f59b1349d545f7366539fb101c559a135de963514f42f6ea89083d26a90
```

Let's see all our blocks, including block 0 which get automatically created at startup.

```
> list
Index: 0
=== Genesis Block
  data: Genesis
  hash: 00000551fb3e39f4f36d2121a6043c71999059f733ab13561539ebfe57f85961

Index: 1
=== Block
  data: "hello world"
  hash: 00008f59b1349d545f7366539fb101c559a135de963514f42f6ea89083d26a90
  prev_hash: 00000551fb3e39f4f36d2121a6043c71999059f733ab13561539ebfe57f85961

Index: 2
=== Block
  data: "foobar"
  hash: 00008421e3c5676e634f1cfe4f427dd24043179df679fe7c72889659e2fb99d8
  prev_hash: 00008f59b1349d545f7366539fb101c559a135de963514f42f6ea89083d26a90
```

### Run tests

```
> zig test .\src\blockchain.zig

Test [0/2] test "it creates a blockchain genesis bloTest [0/2] test "it creates a blockchain genesis block"... OK
Test [1/2] test "it appends a block to the blockchaTest [1/2] test "it appends a block to the blockchain"... OK
```
