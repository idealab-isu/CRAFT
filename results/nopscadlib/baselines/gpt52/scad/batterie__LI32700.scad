$fn=128;

cell_h = 70.2;
cell_d = 32.4;

cap_h = 1.6;
cap_d = 14.0;
button_h = 0.8;
button_d = 6.0;

module battery_cell(h=cell_h, d=cell_d) {
    union() {
        cylinder(h=h, d=d, center=true);
        translate([0,0,h/2 - cap_h/2])
            cylinder(h=cap_h, d=cap_d, center=true);
        translate([0,0,h/2 + button_h/2])
            cylinder(h=button_h, d=button_d, center=true);
    }
}

battery_cell();