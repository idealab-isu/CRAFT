$fn=128;

module pan_head_screw(d_shaft=6.0, length=10.0, d_head=12.0, head_h=4.75) {
    union() {
        // Shaft
        cylinder(h=length, d=d_shaft);

        // Pan head (approximated as a short frustum + dome cap)
        translate([0,0,length]) {
            union() {
                // Slight taper from shaft to head diameter
                cylinder(h=head_h*0.55, d1=d_shaft*1.05, d2=d_head);

                // Rounded top (spherical cap)
                translate([0,0,head_h*0.55])
                intersection() {
                    // Sphere sized to give a gentle dome
                    sphere(d=d_head);
                    // Keep only the upper portion to form a cap
                    translate([0,0,0])
                    cylinder(h=head_h*0.45, d=d_head);
                }
            }
        }
    }
}

pan_head_screw(d_shaft=6.0, length=10.0, d_head=12.0, head_h=4.75);