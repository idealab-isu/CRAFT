$fn=96;

module heatshrink_sleeve(len=50, od=10, wall=1.2) {
    id = max(0.01, od - 2*wall);
    difference() {
        cylinder(h=len, d=od, center=true);
        cylinder(h=len+0.2, d=id, center=true);
    }
}

module sleeve_with_chamfers(len=50, od=10, wall=1.2, chamfer=1.0) {
    id = max(0.01, od - 2*wall);
    difference() {
        union() {
            cylinder(h=len-2*chamfer, d=od, center=true);
            translate([0,0,(len/2)-(chamfer/2)]) cylinder(h=chamfer, d1=od-2*chamfer, d2=od, center=true);
            translate([0,0,-(len/2)+(chamfer/2)]) cylinder(h=chamfer, d1=od, d2=od-2*chamfer, center=true);
        }
        union() {
            cylinder(h=len-2*chamfer+0.2, d=id, center=true);
            translate([0,0,(len/2)-(chamfer/2)]) cylinder(h=chamfer+0.2, d1=max(0.01,id-2*chamfer), d2=id, center=true);
            translate([0,0,-(len/2)+(chamfer/2)]) cylinder(h=chamfer+0.2, d1=id, d2=max(0.01,id-2*chamfer), center=true);
        }
    }
}

sleeve_with_chamfers(len=60, od=12, wall=1.5, chamfer=1.2);