$fn=96;

module pan_head_screw(shaft_d=3.0, length=10.0, head_d=5.5, head_h=2.0) {
    union() {
        translate([0,0,-length/2])
            cylinder(h=length, d=shaft_d);

        translate([0,0,length/2])
            cylinder(h=head_h, d=head_d);

        translate([0,0,length/2 + head_h])
            scale([1,1,0.6])
                sphere(d=head_d);
    }
}

pan_head_screw();