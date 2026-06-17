$fn=96;

module pan_head_screw(shaft_d=3.5, length=10, head_d=6.9, head_h=2.5) {
    union() {
        translate([0,0,-length/2])
            cylinder(h=length, d=shaft_d);

        translate([0,0,length/2])
            cylinder(h=head_h, d=head_d);
    }
}

pan_head_screw();