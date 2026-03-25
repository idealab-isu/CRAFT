$fn=96;

module battery_cell(height=44.5, diameter=10.5, cap_h=1.2, cap_d=5.0, button_h=0.6, button_d=3.5) {
    r = diameter/2;
    union() {
        translate([0,0,-height/2])
            cylinder(h=height, r=r);

        translate([0,0,height/2 - cap_h])
            cylinder(h=cap_h, r=cap_d/2);

        translate([0,0,height/2])
            cylinder(h=button_h, r=button_d/2);
    }
}

battery_cell();