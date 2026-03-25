$fn=128;

cell_h = 35.2;
cell_d = 16.4;

cap_h = 1.2;
cap_d = 5.2;

module battery_cell(h=cell_h, d=cell_d, capHeight=cap_h, capDiameter=cap_d) {
    union() {
        translate([0,0,-h/2])
            cylinder(h=h, d=d);
        translate([0,0,h/2])
            cylinder(h=capHeight, d=capDiameter);
    }
}

battery_cell();