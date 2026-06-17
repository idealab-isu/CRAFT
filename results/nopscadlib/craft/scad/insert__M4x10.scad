// Threaded heat-set insert (visual model)
// Target: 10.0mm OD, 8.0mm long, for 4.0mm screws

outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 8; //[4:16:0.1]
screw_diameter_mm = 4; //[2:8:0.1]
internal_bore_diameter_mm = 3.6; //[2.8:5:0.05]
chamfer_mm = 0.5; //[0.2:1.5:0.05]
knurl_rib_count = 24; //[8:60:1]
knurl_height_mm = 0.6; //[0.2:1.5:0.05]
knurl_rib_width_mm = 1.0; //[0.4:2.5:0.05]
knurl_band_height_mm = 1.2; //[0.4:3:0.05]   // height of the knurl band along Z (matches reference "ring")
rib_overlap_mm = 0.8; //[0.3:2:0.05]
bore_extra_depth_mm = 0.2; //[0.05:1:0.05]

$fn = 128;

module threaded_insert() {
    outer_r = outer_diameter_mm/2;
    bore_r  = internal_bore_diameter_mm/2;

    // Chamfer clamp
    ch = min(chamfer_mm, length_mm/2 - 0.05);
    ch = max(ch, 0.05);

    // Knurl band clamp (keep inside body height)
    band_h = min(knurl_band_height_mm, length_mm - 2*ch - 0.1);
    band_h = max(band_h, 0.1);

    // Rib placement: overlap into body by rib_overlap_mm to guarantee connectivity
    rib_radial_thickness = knurl_height_mm + rib_overlap_mm;
    rib_center_r = outer_r + rib_radial_thickness/2 - rib_overlap_mm;

    color([0.8, 0.6, 0.2])
    difference() {
        union() {
            // Main body
            cylinder(r=outer_r, h=length_mm, center=true);

            // End chamfers (connected; slight overlap into body)
            translate([0, 0,  length_mm/2 - ch/2])
                cylinder(h=ch, r1=outer_r, r2=max(outer_r - ch, 0.01), center=true);

            translate([0, 0, -length_mm/2 + ch/2])
                cylinder(h=ch, r1=max(outer_r - ch, 0.01), r2=outer_r, center=true);

            // Knurl ribs as a centered band around mid-height (matches reference)
            for (i = [0:knurl_rib_count-1]) {
                rotate([0, 0, i*360/knurl_rib_count])
                    translate([rib_center_r, 0, 0])
                        cube([rib_radial_thickness, knurl_rib_width_mm, band_h], center=true);
            }
        }

        // Internal bore (through hole)
        cylinder(r=bore_r, h=length_mm + bore_extra_depth_mm, center=true);
    }
}

threaded_insert();