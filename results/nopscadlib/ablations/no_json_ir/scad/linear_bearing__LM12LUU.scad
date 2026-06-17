$fn = 128;

// Target dimensions (mm)
outer_diameter = 21.0;   // OD
inner_diameter = 12.0;   // ID (bore)
length         = 57.0;   // overall length

// Small end lips (kept within overall length)
lip_thickness  = 1.0;    // axial thickness per end
lip_extension  = 1.5;    // radial extension beyond OD

// Robust boolean overlap to avoid coincident faces
eps = 0.02;

module linear_bearing() {
    difference() {
        // ONE connected solid: outer body + end lips unioned
        union() {
            // Main outer cylinder spans full length
            cylinder(d=outer_diameter, h=length, center=true);

            // End lips placed at the ends, overlapping slightly into the body
            for (z = [-1, 1]) {
                translate([0, 0, z*(length/2 - lip_thickness/2 + eps)])
                    cylinder(d=outer_diameter + 2*lip_extension,
                             h=lip_thickness + 2*eps,
                             center=true);
            }
        }

        // Through bore (clearly visible in end views)
        cylinder(d=inner_diameter, h=length + 2*lip_thickness + 4*eps, center=true);
    }
}

linear_bearing();