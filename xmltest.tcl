package require tdom

source sheet.tcl

proc getDom {file} {
  set f [open $file r]
  fconfigure $f -encoding utf-8
  set rawdoc [read $f]
  close $f
  return [dom parse [string trim $rawdoc]]
}
 
proc getStrings0 {node strvar} {
  upvar $strvar strings
  if {[$node nodeName] eq "t"} {
    set n [$node firstChild]
    lappend strings [$n nodeValue]
  } else {
    foreach n [$node childNodes] {
      getStrings0 $n strings
    }
  }
}

proc getStrings {dir} {
  set docnode [getDom $dir/xl/sharedStrings.xml]
  set strings {}
  getStrings0 [$docnode documentElement] strings
  return $strings
}

proc dumpCells {sheet sharedStrings} {
  set sheetObj [Sheet new]
  set cells [$sheet getElementsByTagName c]
  foreach c $cells {
    set cellpos [$c getAttribute r]
    if {[$c hasAttribute t]} {
      set celltype [$c getAttribute t]      
    } else {
      set celltype {}
    }
    set v [$c getElementsByTagName v]
    set value {}
    if {[llength $v] > 0} {
      set vv [[$v firstChild] data]
      if {$celltype eq "s"} {
        set value [lindex $sharedStrings $vv]      
      } else {
        set value $vv
      }
    }
#    puts "$cellpos $value"
    $sheetObj setCellValue $cellpos $value
  }
  return $sheetObj
}

set sheetdir test

set sharedStrings [getStrings $sheetdir]
set workbook [getDom $sheetdir/xl/workbook.xml]
set sheets [[$workbook getElementsByTagName sheets] childNodes]

set sheet {}
foreach s $sheets {
  set sheetid [$s getAttribute sheetId]
  lappend sheet [getDom $sheetdir/xl/worksheets/sheet$sheetid.xml]
}

set sheet1 [dumpCells [lindex $sheet 0] $sharedStrings]
set sheet2 [dumpCells [lindex $sheet 1] $sharedStrings]


