$fn=96;

module pan_head_screw(shaft_d=3.5, length=10, head_d=6.7, head_h=2.2) {
    union() {
        translate([0,0,-length/2])
            cylinder(d=shaft_d, h=length, $fn=96);

        translate([0,0,length/2])
            cylinder(d=head_d, h=head_h, $fn=96);
    }
}

pan_head_screw();