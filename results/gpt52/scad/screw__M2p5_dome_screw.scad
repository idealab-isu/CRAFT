$fn=96;

module dome_head_screw(shaft_d=2.5, length=10, head_d=5.35, head_h=1.6) {
    union() {
        translate([0,0,-length/2])
            cylinder(h=length, d=shaft_d);

        translate([0,0,length/2])
            intersection() {
                translate([0,0,head_h/2])
                    cylinder(h=head_h, d=head_d);
                translate([0,0,head_h])
                    sphere(d=head_d);
            }
    }
}

dome_head_screw();