// Threaded heat-set insert (simplified solid with bore + external knurl)
// Target: 18.0mm OD, 16.0mm long, for 8.0mm screws

outer_diameter_mm = 18; //[9:36:0.1]
length_mm = 16; //[8:32:0.1]
screw_diameter_mm = 8; //[4:16:0.05]
bore_clearance_mm = 0.4; //[0.1:1.0:0.05]

lead_in_chamfer_depth_mm = 1; //[0.5:2:0.05]
end_chamfer_depth_mm = 0.5; //[0.2:1.5:0.05]

knurl_depth_mm = 0.5; //[0.2:1.2:0.05]
knurl_count = 24; //[8:64:1]
knurl_flat_width_mm = 1.2; //[0.6:2.4:0.05]

eps = 0.05;

$fn = 128;

module threaded_insert() {
    outer_r = outer_diameter_mm/2;
    bore_r  = (screw_diameter_mm + bore_clearance_mm)/2;

    // Ensure knurls protrude OUTWARD and overlap INTO the body for a single connected solid
    knurl_radial_len = knurl_depth_mm;
    knurl_center_r   = outer_r + knurl_radial_len/2 - eps; // overlap into body by eps

    // Bore/chamfer cutters extend beyond part to avoid coplanar artifacts
    bore_h = length_mm + 2*(lead_in_chamfer_depth_mm + end_chamfer_depth_mm) + 6*eps;

    color("Gold")
    difference() {
        union() {
            // Main body
            cylinder(r=outer_r, h=length_mm, center=true);

            // External knurl ribs (protrude outward)
            for (i = [0:knurl_count-1]) {
                rotate([0, 0, i*360/knurl_count])
                    translate([knurl_center_r, 0, 0])
                        cube([knurl_radial_len, knurl_flat_width_mm, length_mm + 2*eps], center=true);
            }
        }

        // Through bore
        cylinder(r=bore_r, h=bore_h, center=true);

        // Lead-in chamfer (top)
        translate([0, 0, length_mm/2 - lead_in_chamfer_depth_mm/2 + eps])
            cylinder(
                r1=bore_r + lead_in_chamfer_depth_mm,
                r2=bore_r,
                h=lead_in_chamfer_depth_mm + 4*eps,
                center=true
            );

        // End chamfer (bottom)
        translate([0, 0, -length_mm/2 + end_chamfer_depth_mm/2 - eps])
            cylinder(
                r1=bore_r + end_chamfer_depth_mm,
                r2=bore_r,
                h=end_chamfer_depth_mm + 4*eps,
                center=true
            );
    }
}

threaded_insert();