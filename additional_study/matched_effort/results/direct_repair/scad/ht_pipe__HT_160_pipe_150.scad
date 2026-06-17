$fn = 180;

// HT pipe (approximation)
// "HT 160" interpreted as nominal OD ~160 mm
// "150 mm" interpreted as pipe length
od = 160;          // outer diameter (mm)
wall = 4.7;        // typical HT/SML-like wall thickness approximation (mm)
id = od - 2*wall;  // inner diameter (mm)
len = 150;         // length (mm)

module ht_pipe(od, id, len){
    difference(){
        cylinder(h=len, d=od);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=id);
    }
}

ht_pipe(od, id, len);