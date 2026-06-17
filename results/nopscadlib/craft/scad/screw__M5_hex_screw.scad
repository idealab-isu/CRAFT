// Hex head screw (single connected solid)
// Target: 5.0mm shaft diameter, 9.2mm hex head diameter (across corners), head height 3.65mm, 10mm long

shaft_diameter_mm = 5.0;   // M5 major diameter
length_mm         = 10.0;  // under-head length
head_diameter_mm  = 9.2;   // across corners
head_height_mm    = 3.65;

overlap_mm = 0.2;          // small overlap to guarantee watertight union

$fn = 96;

// Hex polygon with given across-corners diameter
module hex2d_across_corners(d_ac) {
    r = d_ac/2; // circumradius
    polygon(points=[ for (i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

// Simple external thread approximation (helical ridge) to resemble threading
module approx_threaded_shaft(d_major, L) {
    pitch = 0.8;                 // typical M5 coarse pitch
    turns = L / pitch;
    ridge_h = 0.35;              // radial height of ridge
    ridge_w = 0.55;              // thickness of ridge (mm)
    core_d  = d_major - 2*ridge_h;

    union() {
        // Core cylinder
        cylinder(h=L, r=core_d/2, center=false);

        // Helical ridge
        linear_extrude(height=L, twist=turns*360, slices=max(ceil(turns*24), 60), center=false)
            translate([core_d/2, 0, 0])
                square([ridge_h, ridge_w], center=true);
    }
}

module hex_head_screw() {
    union() {
        // Shaft: from z=0 down to z=-length_mm
        translate([0, 0, -length_mm])
            approx_threaded_shaft(shaft_diameter_mm, length_mm);

        // Hex head: from z=0 up to z=head_height_mm
        translate([0, 0, -overlap_mm])
            linear_extrude(height=head_height_mm + overlap_mm, center=false)
                hex2d_across_corners(head_diameter_mm);

        // Small under-head fillet/washer-like transition (very small, not a big washer)
        // Ensures a clean connection between head and shaft
        transition_h = 0.6;
        transition_r1 = shaft_diameter_mm/2;
        transition_r2 = max(shaft_diameter_mm/2, (head_diameter_mm/2)*0.55);
        translate([0, 0, -transition_h])
            cylinder(h=transition_h + overlap_mm, r1=transition_r2, r2=transition_r1, center=false);
    }
}

hex_head_screw();