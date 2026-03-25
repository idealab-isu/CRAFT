$fn=64;

axial = [5.21, 2.72, 0];

module axial_marker(v=[0,0,0], shaft_d=0.6, head_d=1.4, head_h=0.8, shaft_h=2.0) {
    translate(v)
    union() {
        cylinder(d=shaft_d, h=shaft_h, center=true);
        translate([0,0,shaft_h/2 + head_h/2])
            cylinder(d=head_d, h=head_h, center=true);
    }
}

axial_marker(axial);