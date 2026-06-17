$fn = 120;

// Parameters (mm)
shaft_d = 5.0;
length = 10.0;

head_d = 9.5;
head_h = 2.75;

// Small edge break/chamfers
tip_chamfer_h = 0.6;
tip_chamfer_d = 1.2;

head_edge_round = 0.35; // subtle rounding at head rim

module dome_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft with slight chamfer at tip
        difference() {
            cylinder(d=shaft_d, h=length);
            // tip chamfer
            translate([0,0,-0.01])
                cylinder(d1=shaft_d + tip_chamfer_d, d2=shaft_d - 0.2, h=tip_chamfer_h + 0.02);
        }

        // Dome head (spherical cap) blended to a short cylindrical skirt
        translate([0,0,length]) {
            // Cylindrical skirt for clean join
            skirt_h = min(0.35, head_h*0.25);
            union() {
                cylinder(d=head_d, h=skirt_h);

                // Spherical cap for dome
                cap_h = head_h - skirt_h;
                // Sphere radius chosen so that cap height = cap_h and base radius = head_d/2
                a = head_d/2;
                h = cap_h;
                R = (a*a + h*h) / (2*h);

                // Place sphere so that cap base is at z=skirt_h and top at z=head_h
                translate([0,0,skirt_h + (h - R)])
                    intersection() {
                        sphere(r=R);
                        translate([0,0,R - h])
                            cylinder(r=a, h=h);
                    }

                // Slight rounding at rim (optional)
                if (head_edge_round > 0) {
                    difference() {
                        // nothing to add; just a tiny bevel by subtracting a torus-like ring approximation
                        // Use a conical cut to soften the edge
                        translate([0,0,0])
                            cylinder(d1=head_d + 2*head_edge_round, d2=head_d - 0.2, h=head_edge_round);
                    }
                }
            }
        }
    }
}

dome_head_screw(shaft_d, length, head_d, head_h);