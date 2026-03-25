// Linear bearing (LM12UU-style simplified)
// Target: 12.0mm bore, 21.0mm outer diameter, 30.0mm length
// FIX: Ensure end rings/flanges are physically attached (no gaps/floating parts)
// by overlapping them 1–2mm into the main body and union()ing everything.

bore_diameter_mm  = 12.0;  // ID
outer_diameter_mm = 21.0;  // OD
length_mm         = 30.0;  // overall length

// Small clearance for the through-bore cut
eps_mm = 0.15;

// Simple end details typical of LMxxUU bearings (shallow grooves)
groove_depth_mm = 0.6;   // radial depth into OD
groove_width_mm = 1.6;   // axial width of groove
end_land_mm     = 2.0;   // distance from each end to groove start

// End ring/flange (visual detail) - must be attached
ring_radial_thickness_mm = 1.2;  // how much larger than OD radius
ring_height_mm           = 2.0;  // axial thickness of ring
overlap_mm               = 1.2;  // 1–2mm overlap into main body to guarantee connection

$fn = 128;

module linear_bearing_12_21_30() {
    r_out = outer_diameter_mm/2;
    r_in  = bore_diameter_mm/2;

    // Ring dimensions
    r_ring_out = r_out + ring_radial_thickness_mm;

    // Place rings so they intersect the main body by overlap_mm
    // Main body spans z = [-length/2, +length/2] (center=true)
    // Ring center should be at: +/- (length/2 - ring_height/2 + overlap)
    z_ring = (length_mm/2 - ring_height_mm/2 + overlap_mm);

    difference() {
        union() {
            // Main outer sleeve
            cylinder(r=r_out, h=length_mm, center=true);

            // Top & bottom end rings/flanges (ATTACHED via overlap)
            for (side = [-1, 1]) {
                translate([0, 0, side * z_ring])
                    cylinder(r=r_ring_out, h=ring_height_mm, center=true);
            }
        }

        // Through bore (cuts through everything)
        cylinder(r=r_in + eps_mm, h=length_mm + 2*ring_height_mm + 4*eps_mm, center=true);

        // Shallow grooves near both ends (cosmetic)
        // Implemented as a ring-shaped removal (annulus), not a full OD wipeout.
        for (side = [-1, 1]) {
            z_groove = side * (length_mm/2 - end_land_mm - groove_width_mm/2);

            translate([0, 0, z_groove])
                difference() {
                    // Outer boundary of removed annulus
                    cylinder(r=r_out + 2*eps_mm, h=groove_width_mm + 2*eps_mm, center=true);
                    // Inner boundary leaves material up to (r_out - groove_depth)
                    cylinder(r=r_out - groove_depth_mm, h=groove_width_mm + 4*eps_mm, center=true);
                }
        }
    }
}

linear_bearing_12_21_30();