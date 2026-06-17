// Threaded heat-set insert (simplified solid model)
// Target: 4.0mm OD, 4.6mm long, for M2.5 screws

$fn = 96;

// Parameters
outer_diameter_mm = 4.0;                 //[2.0:8.0:0.1]
length_mm = 4.6;                         //[2.3:9.2:0.1]
screw_nominal_diameter_mm = 2.5;         //[1.25:5.0:0.05]

internal_minor_diameter_mm = 2.05;       //[1.0:4.1:0.05]
internal_major_diameter_mm = 2.5;        //[1.25:5.0:0.05]

lead_in_chamfer_height_mm = 0.4;         //[0.2:0.8:0.05]
knurl_depth_mm = 0.25;                   //[0.1:0.5:0.01]
knurl_pitch_mm = 0.6;                    //[0.3:1.2:0.05]
knurl_count = 8;                         //[3:20:1]
knurl_ring_height_mm = 0.25;             //[0.15:0.6:0.01]

overlap_mm = 0.2;                        //[0.05:1.0:0.05]

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

module threaded_insert() {
    od = outer_diameter_mm;
    L  = length_mm;

    // Keep bore valid
    bore_d = clamp(internal_minor_diameter_mm, 0.2, od - 0.4);

    // Ensure chamfer doesn't exceed half-length
    chamfer_h = clamp(lead_in_chamfer_height_mm, 0, L/2 - 0.01);

    // Knurl placement within length
    ring_h = clamp(knurl_ring_height_mm, 0.05, L);
    pitch  = max(knurl_pitch_mm, ring_h + 0.01);
    n      = max(knurl_count, 0);

    difference() {
        // ONE connected solid: union of body + knurl rings
        union() {
            // Main body
            cylinder(d=od, h=L, center=true);

            // Knurl rings (slight overlap into body to guarantee connectivity)
            for (i = [0:n-1]) {
                z0 = -L/2 + pitch/2 + i*pitch;
                if (abs(z0) <= (L/2 - ring_h/2))
                    translate([0, 0, z0])
                        cylinder(d=od + 2*knurl_depth_mm, h=ring_h + overlap_mm, center=true);
            }
        }

        // Internal bore (through)
        cylinder(d=bore_d, h=L + 2*overlap_mm, center=true);

        // Lead-in chamfers (both ends) as conical enlargements of the bore
        if (chamfer_h > 0) {
            translate([0, 0,  L/2 - chamfer_h/2])
                cylinder(d1=bore_d, d2=internal_major_diameter_mm, h=chamfer_h + overlap_mm, center=true);
            translate([0, 0, -L/2 + chamfer_h/2])
                cylinder(d1=internal_major_diameter_mm, d2=bore_d, h=chamfer_h + overlap_mm, center=true);
        }
    }
}

threaded_insert();