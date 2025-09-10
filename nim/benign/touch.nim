import os
import times
import strenc
import threadpool

# COMPILE: nim --threads:on -d:release c touch.nim

proc TouchFile(file: string) =
  {.gcsafe.}:
    var f = open(file, fmAppend)
    f.write(" ")
    #echo "Written 1 byte to file: " & file
    f.close()
    let size = getFileSize(file)
    var f2 = open(file, fmRead)
    var buff = newSeq[byte](size)
    discard f2.readBytes(buff,0,size) # just to ensure we have permissions
    #echo "Read " & $size & " bytes from file: " & file
    let newData = buff[0 ..< buff.len - 1]
    writeFile(file,newData)
    #echo "File Wrote - - - " & $size & " bytes: " & file

proc fileWalk(path: string){.thread.} =
  for kind, path in walkDir(path):
    case kind:
    of pcFile:
      echo "File: ", path
      spawn TouchFile(path)
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

main()

echo "Done."