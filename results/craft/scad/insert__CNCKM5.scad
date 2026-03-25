// Threaded heat-set insert (approx. knurled OD), 5.8mm OD, 7.1mm long, for 5.0mm screws

// Parameters
screw_diameter_mm = 5;                 //[2.5:10:0.1]
inner_thread_pitch_mm = 0.8;           //[0.4:1.6:0.05]  // (visual only if you later add true threads)
outer_diameter_mm = 5.8;              //[2.9:11.6:0.1]
length_mm = 7.1;                      //[3.55:14.2:0.1]

// For an M5 screw, a typical insert internal thread minor diameter is ~4.1-4.3mm.
// Use a slightly larger "modeled clearance" so the hole is clearly visible in renders.
inner_clearance_diameter_mm = 4.4;    //[3.8:5.8:0.05]

end_chamfer_mm = 0.35;               //[0.15:0.8:0.05]
lead_in_taper_length_mm = 0.9;        //[0.4:1.6:0.05]
taper_tip_diameter_mm = 5.0;          //[4.6:5.7:0.05]

// Knurl / serration approximation (diamond knurl via crossed helical grooves)
knurl_depth_mm = 0.25;               //[0.1:0.6:0.05]
knurl_pitch_mm = 1.0;                //[0.6:1.6:0.05]
knurl_start_z_margin_mm = 0.6;       //[0.0:1.5:0.05]  // keep ends cleaner

$fn = 96;

// ---- Helpers ----
module helical_groove(r_mid, depth, pitch, h, turns, twist_deg, z0, w=0.55) {
    // A thin rectangular cutter extruded with twist to form a helical groove.
    // Positioned so it intersects the cylinder surface.
    translate([0, 0, z0])
        linear_extrude(height=h, twist=twist_deg, slices=max(24, ceil(h*24)), center=false)
            translate([r_mid, 0, 0])
                square([depth*2, w], center=true);
}

// ---- Geometry ----
module insert_outer() {
    // Build as a single connected solid (union of body + end features)
    union() {
        // Main cylindrical body
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);

        // Bottom installation taper (slightly smaller tip)
        translate([0, 0, -length_mm/2 + lead_in_taper_length_mm/2])
            cylinder(r1=outer_diameter_mm/2, r2=taper_tip_diameter_mm/2,
                     h=lead_in_taper_length_mm, center=true);

        // Top lead-in chamfer
        translate([0, 0, length_mm/2 - end_chamfer_mm/2])
            cylinder(r1=outer_diameter_mm/2, r2=max(0.01, outer_diameter_mm/2 - end_chamfer_mm),
                     h=end_chamfer_mm, center=true);

        // Bottom chamfer (small) to avoid a sharp edge
        translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
            cylinder(r1=max(0.01, outer_diameter_mm/2 - end_chamfer_mm), r2=outer_diameter_mm/2,
                     h=end_chamfer_mm, center=true);
    }
}

module insert_knurled_outer() {
    // Diamond knurl approximation by subtracting two sets of helical grooves
    // from the outer body.
    r_mid = outer_diameter_mm/2 - knurl_depth_mm/2;
    knurl_h = max(0.01, length_mm - 2*knurl_start_z_margin_mm);
    turns = knurl_h / knurl_pitch_mm;
    twist = 360 * turns;

    difference() {
        insert_outer();

        // Keep cutters long enough to fully cut through the knurl region
        // and slightly beyond to avoid end artifacts.
        z0 = -knurl_h/2 - 0.2;

        // Right-hand helix grooves
        translate([0, 0, 0])
            for (a = [0 : 360/12 : 359])  // 12 angular repeats for a fuller knurl look
                rotate([0, 0, a])
                    translate([0, 0, -knurl_h/2 + 0])
                        helical_groove(r_mid=r_mid, depth=knurl_depth_mm, pitch=knurl_pitch_mm,
                                      h=knurl_h, turns=turns, twist_deg=+twist,
                                      z0=0, w=0.55);

        // Left-hand helix grooves (crossing to form diamond knurl)
        translate([0, 0, 0])
            for (a = [0 : 360/12 : 359])
                rotate([0, 0, a + 360/24]) // offset half-step
                    translate([0, 0, -knurl_h/2 + 0])
                        helical_groove(r_mid=r_mid, depth=knurl_depth_mm, pitch=knurl_pitch_mm,
                                      h=knurl_h, turns=turns, twist_deg=-twist,
                                      z0=0, w=0.55);
    }
}

module internal_hole() {
    // Through-hole (clearly visible in all orthographic views)
    // Slightly longer than body to guarantee a clean cut.
    cylinder(r=inner_clearance_diameter_mm/2, h=length_mm + 2, center=true);
}

module threaded_insert() {
    difference() {
        insert_knurled_outer();
        internal_hole();
    }
}

// ---- Output ----
threaded_insert();