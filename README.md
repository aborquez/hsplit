# hsplit

Same as `hadd`, but instead of merging root files, it splits them.

## Usage

* To split the root file into a `N` number of files. Only the first file have more entries to complete the total.
```
$ ./hsplit.sh --F <number of files> <input root file>
```
E.G.
```
$ ./hsplit.sh --F 4 recsisD_76.root
```

* To split the root file into files with same number of entries. Only the first file will more entries to complete the total.
```
$ ./hsplit.sh --E <number of entries per file> <input root file>
```
E.G.
```
$ ./hsplit.sh --E 350000 recsisD_76.root
```

* To split the root file into `N` files with an optimal number of entries, based on an initial number of entries. All output files will have the same number of entries.
```
./hsplit.sh --B <initial number of entries per file> <input root file>
```
E.G.
```
$ ./hsplit.sh --B 350000 recsisD_76.root
```

## Issues

* It creates output files in the dir where script is being executed
* Don't know how to edit/modify the tree name


