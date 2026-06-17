$fn = 180;

// HT pipe (approximation)
// "HT 125" interpreted as nominal DN125 with ~125 mm inner diameter.
// Length: 150 mm.
dn_inner = 125;          // mm (inner diameter)
wall = 3.2;              // mm (typical HT wall thickness approximation)
length = 150;            // mm

id = dn_inner;
od = id + 2*wall;

module ht_pipe(id, od, length){
    difference(){
        cylinder(h=length, d=od, center=false);
        translate([0,0,-0.1])
            cylinder(h=length+0.2, d=id, center=false);
    }
}

ht_pipe(id, od, length);