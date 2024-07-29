#!/bin/bash
#tagcode=13

filetose=/home/tombo09/Skripte/system-skript/print-path-tag.sh
dirtose=/home/tombo09/Skripte/system-skript/print-path-tag-dir.sh

$($filetose 14)
fusermount -u ~/iphone && rmdir ~/iphone
$($filetose 12)
