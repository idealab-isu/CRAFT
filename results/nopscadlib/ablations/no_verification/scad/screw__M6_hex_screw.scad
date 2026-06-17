// Hex head screw (single connected solid)
// Target: 6.0mm shaft diameter, 11.5mm hex head diameter (across flats), head height 4.15mm, 10mm length under head

shaft_diameter_mm      = 6.0;
length_under_head_mm   = 10.0;
head_diameter_mm       = 11.5;   // across flats (use $fn=6)
head_height_mm         = 4.15;

thread_major_diameter_mm = 6.0;  // keep at nominal so dimensions match
thread_length_mm         = 10.0; // represent full under-head length as threaded

tip_length_mm = 1.0;             // small chamfered/pointed tip detail
overlap_mm    = 0.2;

$fn = 96;

module hex_prism_af(af, h, center=false) {
    // For cylinder($fn=6), r is circumradius; across-flats = 2*r*cos(30)
    r = af / (2 * cos(30));
    cylinder(h=h, r=r, $fn=6, center=center);
}

module hex_head_screw() {
    shank_r = shaft_diameter_mm/2;
    thread_r = thread_major_diameter_mm/2;

    // Z reference: underside of head at z=0, head extends +Z, shaft extends -Z
    union() {
        // Hex head
        translate([0, 0, head_height_mm/2])
            hex_prism_af(head_diameter_mm, head_height_mm, center=true);

        // Under-head shaft (thread major diameter representation)
        translate([0, 0, -length_under_head_mm/2 + overlap_mm/2])
            cylinder(h=length_under_head_mm + overlap_mm, r=thread_r, center=true);

        // Tip detail: conical/chamfered end, connected to shaft
        translate([0, 0, -length_under_head_mm + tip_length_mm/2 + overlap_mm/2])
            cylinder(h=tip_length_mm + overlap_mm, r1=thread_r, r2=max(0.01, thread_r*0.15), center=true);
    }
}

hex_head_screw();