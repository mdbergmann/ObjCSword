# ObjCSword
Objective-C wrapper of SWORD library

Notes on compiling:

1. cd into dependencies and unpack `icu.tar.gz` and `clucene.tar.gz`.
2. in dependencies make a checkout of the SWORD sources
3. create a symlink to the SWORD source folder, like: `ln -s <your_sword_src_folder> sword`.
Because the project is expecting SWORD sources under a `sword` symlink.
