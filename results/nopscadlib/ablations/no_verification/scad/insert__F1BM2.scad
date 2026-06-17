// Threaded heat-set insert (simplified solid model)
// Target: 4.0mm OD, 3.6mm long, for 2.0mm screws

$fn = 96;

// Parameters
outer_diameter_mm = 4;                 //[2:8:0.1]
length_mm = 3.6;                       //[1.8:7.2:0.1]
screw_nominal_diameter_mm = 2;         //[1:4:0.1]
top_chamfer_height_mm = 0.3;           //[0.15:0.6:0.05]
bottom_chamfer_height_mm = 0.3;        //[0.15:0.6:0.05]
knurl_depth_mm = 0.2;                  //[0.1:0.4:0.05]
knurl_pitch_mm = 0.6;                  //[0.3:1.2:0.05]
bore_minor_diameter_mm = 1.6;          //[0.8:3.2:0.05]
rib_count = 6;                         //[3:12:1]
rib_height_mm = 0.35;                  //[0.2:0.7:0.05]
overlap_mm = 0.2;                      //[0.05:0.6:0.05]

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module threaded_insert() {
    outer_r = outer_diameter_mm/2;

    // Keep bore safely inside outer wall
    bore_r  = min(bore_minor_diameter_mm/2, outer_r - 0.35);

    // Chamfers must be positive and not exceed half length
    top_ch  = clamp(top_chamfer_height_mm, 0.01, length_mm/2 - 0.01);
    bot_ch  = clamp(bottom_chamfer_height_mm, 0.01, length_mm/2 - 0.01);

    // Ribs must fit between chamfers
    usable_h = max(0.01, length_mm - top_ch - bot_ch);
    rib_step = max(knurl_pitch_mm, rib_height_mm + 0.01);
    max_ribs = max(1, floor((usable_h + 1e-6) / rib_step));
    ribs_n   = min(rib_count, max_ribs);

    // Center ribs within usable region so they never float outside the body
    ribs_span = ribs_n * rib_step;
    ribs_z0   = (-length_mm/2 + bot_ch) + (usable_h - ribs_span)/2 + rib_step/2;

    color([0.8, 0.6, 0.2])
    difference() {
        union() {
            // Main body
            cylinder(r=outer_r, h=length_mm, center=true);

            // Chamfers: overlap slightly into body to ensure watertight union
            translate([0, 0,  length_mm/2 - top_ch/2])
                cylinder(r1=outer_r, r2=max(outer_r - top_ch, 0.01),
                         h=top_ch + overlap_mm, center=true);

            translate([0, 0, -length_mm/2 + bot_ch/2])
                cylinder(r1=max(outer_r - bot_ch, 0.01), r2=outer_r,
                         h=bot_ch + overlap_mm, center=true);

            // Outer ribs/knurls (rings), fully within usable region
            for (i = [0:ribs_n-1]) {
                z = ribs_z0 + i*rib_step;
                translate([0, 0, z])
                    cylinder(r=outer_r + knurl_depth_mm,
                             h=rib_height_mm + overlap_mm, center=true);
            }
        }

        // Through bore
        cylinder(r=bore_r, h=length_mm + 2*overlap_mm, center=true);
    }
}

threaded_insert();