// Hex head screw (single connected solid)
// Requested: 5.0mm shaft diameter, 9.2mm head diameter, 3.65mm head height, 10mm long

shaft_diameter_mm = 5.0;
length_mm         = 10.0;   // length under head
head_diameter_mm  = 9.2;    // across corners for $fn=6 cylinder
head_height_mm    = 3.65;

overlap_mm        = 0.2;    // small overlap to guarantee manifold union
$fn               = 64;

module hex_head_screw(d=5.0, L=10.0, head_d=9.2, head_h=3.65, overlap=0.2) {
    union() {
        // Shaft: from z=0 to z=L
        translate([0,0,L/2])
            cylinder(h=L, r=d/2, center=true);

        // Hex head: sits on top of shaft, from z=L to z=L+head_h
        translate([0,0,L + head_h/2 - overlap/2])
            cylinder(h=head_h + overlap, r=head_d/2, $fn=6, center=true);
    }
}

hex_head_screw(
    d=shaft_diameter_mm,
    L=length_mm,
    head_d=head_diameter_mm,
    head_h=head_height_mm,
    overlap=overlap_mm
);