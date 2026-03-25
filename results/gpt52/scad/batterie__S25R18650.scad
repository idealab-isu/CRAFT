$fn=128;

module battery_cell(height=65.0, diameter=18.3, button_h=1.2, button_d=6.0, neg_recess_h=0.6, neg_recess_d=8.0) {
    r = diameter/2;

    difference() {
        union() {
            cylinder(h=height, r=r, center=true);
            translate([0,0,height/2]) cylinder(h=button_h, r=button_d/2, center=false);
        }
        translate([0,0,-height/2 - 0.001]) cylinder(h=neg_recess_h + 0.002, r=neg_recess_d/2, center=false);
    }
}

battery_cell();