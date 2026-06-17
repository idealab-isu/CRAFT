// Threaded heat-set insert (simplified solid with bore + knurl rings)
// Target: 5.8mm OD, 4.6mm long, for 2.5mm screws

outer_diameter_mm = 5.8; //[2.9:11.6:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]
screw_nominal_diameter_mm = 2.5; //[1.25:5:0.05]
internal_thread_pitch_mm = 0.45; //[0.2:0.9:0.01]
bore_minor_diameter_mm = 2.05; //[1.025:4.1:0.05]
bore_major_diameter_mm = 2.5; //[1.25:5:0.05]
lead_in_chamfer_angle_deg = 45; //[20:80:1]
lead_in_chamfer_depth_mm = 0.3; //[0.15:0.6:0.05]
knurl_depth_mm = 0.2; //[0.1:0.4:0.05]
knurl_pitch_mm = 0.6; //[0.3:1.2:0.05]
knurl_ring_count = 6; //[3:12:1]
knurl_ring_width_mm = 0.35; //[0.2:0.8:0.05]
overlap_mm = 0.2; //[0.05:1:0.05]
bore_extra_height_mm = 1.6; //[0.5:3.2:0.1]

$fn = 96;

module threaded_insert() {
    r_outer = outer_diameter_mm/2;
    r_knurl = r_outer + knurl_depth_mm;

    ring_count = max(1, knurl_ring_count);
    ring_pitch = max(0.01, knurl_pitch_mm);
    ring_w = max(0.01, min(knurl_ring_width_mm, ring_pitch));

    // Place rings evenly across the length (guaranteed within ends)
    ring_span = (ring_count-1) * ring_pitch;
    ring_span_eff = min(ring_span, max(0, length_mm - ring_w));
    ring_z0 = -ring_span_eff/2;
    ring_step = (ring_count > 1) ? (ring_span_eff/(ring_count-1)) : 0;

    // Chamfer: compute radial change from angle+depth (OpenSCAD trig uses degrees)
    chamfer_h = max(0, lead_in_chamfer_depth_mm);
    chamfer_dr = chamfer_h * tan(lead_in_chamfer_angle_deg);
    chamfer_r2 = max(0.01, r_outer - chamfer_dr);

    // Safety: ensure bore is smaller than outer radius so geometry remains visible
    bore_r = min(bore_minor_diameter_mm/2, r_outer - 0.05);

    color([0.8, 0.6, 0.2])
    difference() {
        union() {
            // Main body
            cylinder(r=r_outer, h=length_mm, center=true);

            // Knurl rings: overlap into body so everything is one connected solid
            for (i = [0:ring_count-1]) {
                z_i = ring_z0 + i*ring_step;
                translate([0, 0, z_i])
                    cylinder(r=r_knurl, h=ring_w + 2*overlap_mm, center=true);
            }
        }

        // Through bore
        cylinder(r=bore_r, h=length_mm + bore_extra_height_mm, center=true);

        // Lead-in chamfers (subtract)
        if (chamfer_h > 0) {
            translate([0, 0,  length_mm/2 - chamfer_h/2])
                cylinder(r1=r_outer + overlap_mm, r2=chamfer_r2,
                         h=chamfer_h + 2*overlap_mm, center=true);

            translate([0, 0, -length_mm/2 + chamfer_h/2])
                cylinder(r1=chamfer_r2, r2=r_outer + overlap_mm,
                         h=chamfer_h + 2*overlap_mm, center=true);
        }
    }
}

threaded_insert();