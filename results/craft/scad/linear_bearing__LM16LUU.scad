// Long linear bearing (LM16LUU-style) — 16mm bore, 28mm OD, 70mm length
// One connected solid, no side protrusions.

// Parameters
bore_diameter_mm  = 16;  //[8:32:0.5]
outer_diameter_mm = 28;  //[14:56:0.5]
length_mm         = 70;  //[35:140:1]

// Cosmetic grooves (typical LM..UU end grooves)
groove_depth_mm   = 0.8; //[0.4:1.6:0.1]
groove_length_mm  = 6;   //[3:12:0.5]
groove_spacing_mm = 46;  //[20:100:1]

// Robust boolean overlap
overlap_mm        = 1;   //[0.5:2:0.1]

$fn = 128;

module linear_bearing() {
    difference() {
        // Outer casing
        cylinder(d=outer_diameter_mm, h=length_mm, center=true);

        // Inner bore (through)
        cylinder(d=bore_diameter_mm, h=length_mm + 2*overlap_mm, center=true);

        // Two shallow external grooves near ends (implemented as subtractive rings)
        for (z = [groove_spacing_mm/2, -groove_spacing_mm/2]) {
            translate([0, 0, z])
                cylinder(d=outer_diameter_mm - 2*groove_depth_mm,
                         h=groove_length_mm,
                         center=true);
        }
    }
}

linear_bearing();