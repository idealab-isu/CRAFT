// Rigid shaft coupling: 5.0mm to 8.0mm bore, 12.5mm OD, 25.0mm long

// Parameters
outer_diameter_mm = 12.5; //[6.25:25:0.1]
length_mm = 25; //[12.5:50:0.1]
bore1_diameter_mm = 5; //[2.5:10:0.1]
bore2_diameter_mm = 8; //[4:16:0.1]
bore1_depth_mm = 12.5; //[6.25:25:0.1]
bore2_depth_mm = 12.5; //[6.25:25:0.1]
overlap_mm = 0.5; //[0.1:2:0.1]

// Shaft Coupling - complete geometry
module shaft_coupling() {
    // Ensure depths don't exceed length
    b1 = min(bore1_depth_mm, length_mm);
    b2 = min(bore2_depth_mm, length_mm);

    // Small epsilon to avoid coplanar/zero-thickness artifacts
    eps = 0.01;

    color("Silver")
    difference() {
        // Body
        cylinder(d=outer_diameter_mm, h=length_mm, center=true, $fn=96);

        // Bore 1 (5mm) from the -Z end inward
        translate([0, 0, -length_mm/2 + b1/2 - overlap_mm/2])
            cylinder(d=bore1_diameter_mm, h=b1 + overlap_mm + eps, center=true, $fn=64);

        // Bore 2 (8mm) from the +Z end inward
        translate([0, 0,  length_mm/2 - b2/2 + overlap_mm/2])
            cylinder(d=bore2_diameter_mm, h=b2 + overlap_mm + eps, center=true, $fn=64);
    }
}

// Assembly
shaft_coupling();