$fn=96;

module pan_head_screw(shaft_d=5.0, length=10.0, head_d=10.0, head_h=3.95) {
    union() {
        translate([0,0,-length/2])
            cylinder(h=length, d=shaft_d);

        translate([0,0,length/2])
            cylinder(h=head_h, d=head_d);
    }
}

pan_head_screw(shaft_d=5.0, length=10.0, head_d=10.0, head_h=3.95);