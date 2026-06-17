// Long linear bearing (single connected solid)
// Target: 8.0mm bore, 15.0mm OD, 45.0mm length

$fn = 128;

// Key dimensions
bore_diameter_mm  = 8.0;   // through-bore
outer_diameter_mm = 15.0;  // outer diameter
length_mm         = 45.0;  // overall length

// Optional detailing
bore_clearance_mm = 0.10;  // small clearance on bore
end_chamfer_mm    = 0.60;  // outer end chamfer size
eps_mm            = 0.02;

module long_linear_bearing() {
    r_out = outer_diameter_mm/2;
    r_in  = (bore_diameter_mm + bore_clearance_mm)/2;

    // Outer body with simple end chamfers, and a true through-bore
    difference() {
        // Outer shape (connected single body)
        union() {
            // Main cylinder
            cylinder(r=r_out, h=length_mm, center=true);

            // Add slight end chamfer volumes (then subtract inner to keep bore clean)
            // Implemented by adding short frustums at both ends
            translate([0, 0,  length_mm/2 - end_chamfer_mm/2])
                cylinder(r1=r_out - end_chamfer_mm, r2=r_out, h=end_chamfer_mm, center=true);
            translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
                cylinder(r1=r_out, r2=r_out - end_chamfer_mm, h=end_chamfer_mm, center=true);
        }

        // Through bore along full length
        cylinder(r=r_in, h=length_mm + 2*eps_mm, center=true);
    }
}

long_linear_bearing();