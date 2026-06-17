// Standalone Linear Bearing (LM10UU-like proportions)
// Target dimensions: 10.0mm bore, 19.0mm outer diameter, 29.0mm length

bore_diameter_mm  = 10.0;  //[5.0:20.0:0.1]
outer_diameter_mm = 19.0;  //[10.0:38.0:0.1]
length_mm         = 29.0;  //[15.0:58.0:0.1]

// Small modeling tolerance for clean boolean ops (does not change nominal dims)
eps_mm = 0.05; //[0.01:0.2:0.01]

// Typical outer shell details (purely cosmetic, still one connected solid)
end_band_len_mm   = 2.0;  //[0.5:5.0:0.1]   // narrow bands near ends
end_band_depth_mm = 0.35; //[0.1:1.0:0.05]  // how much the bands are recessed
mid_groove_len_mm = 2.0;  //[0.5:6.0:0.1]   // center groove length
mid_groove_depth_mm = 0.45; //[0.1:1.2:0.05]

$fn = 128;

module linear_bearing_10x19x29() {
    r_out  = outer_diameter_mm/2;
    r_bore = bore_diameter_mm/2;

    // Clamp decorative features so they never exceed the bearing length
    band_len = min(end_band_len_mm, length_mm/2 - 0.2);
    groove_len = min(mid_groove_len_mm, length_mm - 2*band_len - 0.4);

    difference() {
        // Outer shell (solid)
        cylinder(r=r_out, h=length_mm, center=true);

        // Through bore
        cylinder(r=r_bore, h=length_mm + 2*eps_mm, center=true);

        // Decorative recessed end bands (do not create separate parts)
        if (band_len > 0) {
            for (s = [-1, 1]) {
                translate([0, 0, s*(length_mm/2 - band_len/2)])
                    cylinder(r=r_out + eps_mm, h=band_len + 2*eps_mm, center=true);
                // Re-add by subtracting a slightly smaller cylinder to create a step
                // (implemented as a "ring recess" by subtracting only the outer skin)
                translate([0, 0, s*(length_mm/2 - band_len/2)])
                    cylinder(r=r_out - end_band_depth_mm, h=band_len + 2*eps_mm, center=true);
            }
        }

        // Decorative center groove
        if (groove_len > 0) {
            translate([0, 0, 0])
                cylinder(r=r_out - mid_groove_depth_mm, h=groove_len + 2*eps_mm, center=true);
        }
    }
}

linear_bearing_10x19x29();