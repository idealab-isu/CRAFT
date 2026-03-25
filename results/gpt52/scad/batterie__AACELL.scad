$fn=128;

cell_h = 50.5;
cell_d = 14.5;

cap_h = 1.2;
cap_d = 5.5;

ring_h = 0.6;
ring_d = 8.0;

module battery_cell(h=cell_h, d=cell_d) {
    union() {
        translate([0,0,-h/2])
            cylinder(h=h, d=d);

        translate([0,0,h/2 - cap_h])
            cylinder(h=cap_h, d=cap_d);

        translate([0,0,h/2 - ring_h])
            difference() {
                cylinder(h=ring_h, d=ring_d);
                translate([0,0,-0.01])
                    cylinder(h=ring_h+0.02, d=cap_d+0.6);
            }
    }
}

battery_cell();