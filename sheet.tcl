oo::class create Cell {
  variable value
  variable type
  variable mergeOrigin
  constructor {_value} {
    my setValue $_value
    set mergeOrigin {}
  }
  method getValue {} {return $value}
  method setValue {_val} {
    set value $_val
    if {[string is digit $value]} {
      set type n
    } else {
      set type s
    }
  }
  method getType {} { return $type }
  method getOrigin {} { return $mergeOrigin }
  method setOrigin {origin} { set mergeOrigin $origin}
}

oo::class create Sheet {
  variable table
  variable width
  variable height
  variable char2Rownum
  constructor {} {
    set table [list [list [Cell new {}]]]
    set width 1
    set height 1
    set alpha ABCDEFGHIJKLMNOPQRSTUVWXYZ
    set char2Rownum [dict create]
    for {set i 0} {$i < [string length $alpha]} {incr i} {
      dict set char2Rownum [string index $alpha $i] $i
    }
  }
  method setWidth {w} {
    if {$width < $w} {
      for {set r 0} {$r < $height} {incr r} {
        for {set i $width} {$i < $w} {incr i} {
          lset table $r $i [Cell new {}]
        }
      }
    } elseif {$width > $w} {
      for {set r 0} {$r < $height} {incr r} {
        lset table $r [lreplace $table $w $width]
      } 
    }
    set width $w
  }
  method setHeight {h} {
    if {$height < $h} {
      for {set r $height} {$r < $h} {incr r} {
        set val {}
        for {set i 0} {$i < $width} {incr i} {
          lappend val [Cell new {}]
        }
        lset table $r $val
      }
    } elseif {$height > $r} {
      set table [lreplace $table $r $height]
    }
    set height $h
  }
  method getTable {} {return $table}
  method getIndex {ind} {
    regexp {([A-Za-z]+)([0-9]+)} $ind dummy colchar rownum
    set colchar [string toupper $colchar]
    if {[string length $colchar] == 1} {
      set colnum [dict get $char2Rownum $colchar]
    } else {
      set colnum0 [dict get $char2Rownum [string index $colchar 0]]      
      set colnum1 [dict get $char2Rownum [string index $colchar 1]]
      set colnum [expr ($colnum0+1)*26+$colnum1]
    }
    incr rownum -1
    return [list $rownum $colnum]
  }
  method getIndexRegion {indr} {
    set inds [split $indr :]
    set ind0 [my getIndex [lindex $inds 0]]
    set ind1 [my getIndex [lindex $inds 1]]
    return [list $ind0 $ind1]
  }
  method getCell {ind} {
    set rc [my getIndex $ind]
    return [lindex $table [lindex $rc 0] [lindex $rc 1]]
  }
  method setCell {ind val} {
    set rc [my getIndex $ind]
    set row [lindex $rc 0]
    set col [lindex $rc 1]
    if {$row >= $height} {
      my setHeight [expr $row+1]
    }
    if {$col >= $width} {
      my setWidth [expr $col+1]
    }
    lset table $row $col $val
  }
  method checkCell {ind} {
    set rc [my getIndex $ind]
    set row [lindex $rc 0]
    set col [lindex $rc 1]
    if {$row >= $height} {
      my setHeight [expr $row+1]
    }
    if {$col >= $width} {
      my setWidth [expr $col+1]
    }
    return [lindex $table $row $col]
  }
  method setCellValue {ind val} {
    set cell [my checkCell $ind]
    $cell setValue $val
  }
  method getCellValue {ind} {
    return [[my getCell $ind] getValue]
  }
  method maxColWidth {n} {
    set w 0
    for {set i 0} {$i < $height} {incr i} {
      set wid [string length [[lindex $table $i $n] getValue]]
      if {$wid > $w} {
        set w $wid
      }
    }
    return $wid
  }
  method maxColWidths {} {
    set w {}
    for {set i 0} {$i < $width} {incr i} {
      lappend w [my maxColWidth $i]
    }
    return $w
  }
  method size {} {
    return [list $height $width]
  }
  method print {} {
    set w [my maxColWidths]
    for {set row 0} {$row < $height} {incr row} {
      set x {}
      for {set col 0} {$col < $width} {incr col} {
        set fmt [format {%%%ds } [lindex $w $col]]
        set x [string cat $x [format $fmt [[lindex $table $row $col] getValue]]]
      }
      puts $x
    }
  }
}
