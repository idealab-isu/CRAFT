// Hex head screw (single connected solid)
// Specs: shank Ø5.0mm, head Ø9.2mm (across flats), head height 3.65mm, length 10mm

shaft_diameter_mm = 5.0;
head_diameter_mm  = 9.2;   // across flats for $fn=6
head_height_mm    = 3.65;
length_mm         = 10.0;

overlap_mm = 0.2;          // small overlap to guarantee manifold union
$fn = 96;

module hex_head_screw(d_shaft, d_head_af, h_head, L) {
    r_shaft = d_shaft/2;
    r_head  = d_head_af/2;

    union() {
        // Shank: from z=0 to z=L
        translate([0,0,L/2])
            cylinder(h=L, r=r_shaft, center=true);

        // Hex head: sits on top of shank, from z=-h_head to z=0
        translate([0,0,-h_head/2 + overlap_mm/2])
            cylinder(h=h_head + overlap_mm, r=r_head, center=true, $fn=6);
    }
}

hex_head_screw(shaft_diameter_mm, head_diameter_mm, head_height_mm, length_mm);