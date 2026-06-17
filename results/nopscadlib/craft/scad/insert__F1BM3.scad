// Threaded heat-set insert (M3), OD 5.8mm, L 4.6mm
// One connected solid: cylindrical body + external ribs + lead-in chamfers + internal bore + helical thread cut.

$fn = 128;

// Parameters
outer_diameter = 5.8;                 //[2.9:11.6:0.1]
length = 4.6;                         //[2.3:9.2:0.1]
screw_diameter = 3.0;                 //[1.5:6:0.1]
bore_clearance = 0.15;                //[-0.2:0.6:0.05]
lead_in_chamfer_height = 0.4;         //[0.2:0.8:0.05]
lead_in_chamfer_angle_deg = 45;       //[20:70:1]
eps = 0.02;                           //[0.01:0.2:0.01]

// External retention ribs
knurl_count = 18;                     //[8:30:1]
knurl_depth = 0.25;                   //[0.1:0.6:0.05]
knurl_band_h = 3.2;                   //[1.0:4.6:0.1]
knurl_overlap = 0.15;                 // overlap into body for watertight union

// Internal thread approximation (helical cut)
thread_pitch = 0.5;                   //[0.35:0.8:0.01]
thread_depth = 0.28;                  //[0.15:0.45:0.01]
thread_profile_w = 0.35;              //[0.2:0.6:0.01]
thread_start_taper = 0.6;             //[0.0:1.5:0.05]

// Derived
outer_r = outer_diameter/2;
bore_d = screw_diameter + bore_clearance;
bore_r = bore_d/2;

// OpenSCAD trig uses degrees; keep explicit
chamfer_dr = lead_in_chamfer_height * tan(lead_in_chamfer_angle_deg);

function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module insert_body() {
    dr = clamp(chamfer_dr, 0, outer_r - 0.2);

    // Ensure the middle section height is non-negative
    mid_h = max(length - 2*lead_in_chamfer_height, 0.01);

    union() {
        // Middle cylinder
        cylinder(h=mid_h, r=outer_r, center=true);

        // Top chamfer (connected with slight overlap)
        translate([0,0, (mid_h/2 + lead_in_chamfer_height/2 - eps)])
            cylinder(h=lead_in_chamfer_height + 2*eps, r1=outer_r - dr, r2=outer_r, center=true);

        // Bottom chamfer (connected with slight overlap)
        translate([0,0, -(mid_h/2 + lead_in_chamfer_height/2 - eps)])
            cylinder(h=lead_in_chamfer_height + 2*eps, r1=outer_r, r2=outer_r - dr, center=true);
    }
}

module external_knurl() {
    band_h = min(knurl_band_h, max(length - 2*lead_in_chamfer_height, 0.5));
    band_h = max(band_h, 0.5);

    rib_w = (2*PI*outer_r)/knurl_count * 0.55;

    // Centered band; ribs overlap into body so union is watertight
    for (i = [0:knurl_count-1]) {
        rotate([0,0, i*360/knurl_count])
            translate([outer_r + knurl_depth/2 - knurl_overlap, 0, 0])
                cube([knurl_depth, rib_w, band_h], center=true);
    }
}

module internal_cutter() {
    // Straight bore
    cylinder(h=length + 4*eps, r=bore_r, center=true);

    // Helical groove cutter (subtracted)
    minor_r = max(bore_r - thread_depth, 0.2);
    helix_r = minor_r + thread_depth*0.55;
    turns = (length + 4*eps) / thread_pitch;

    translate([0,0, -(length/2 + 2*eps)])
        linear_extrude(
            height=length + 4*eps,
            twist=turns*360,
            slices=max(ceil(turns*80), 160),
            convexity=10
        )
            translate([helix_r, 0, 0])
                square([thread_depth*2.2, thread_profile_w], center=true);

    // No-thread zones at ends (remove the groove there by over-cutting the groove region)
    // Implemented by subtracting a large cylinder in those zones as part of the cutter union.
    // (This effectively clears the thread near ends, leaving a lead-in.)
    if (thread_start_taper > 0) {
        translate([0,0, (length/2 - thread_start_taper/2)])
            cylinder(h=thread_start_taper + 4*eps, r=bore_r + thread_depth*3.0, center=true);

        translate([0,0, -(length/2 - thread_start_taper/2)])
            cylinder(h=thread_start_taper + 4*eps, r=bore_r + thread_depth*3.0, center=true);
    }

    // Internal lead-in chamfers (both ends)
    translate([0,0, (length/2 - lead_in_chamfer_height/2)])
        cylinder(h=lead_in_chamfer_height + 4*eps, r1=bore_r + lead_in_chamfer_height, r2=bore_r, center=true);

    translate([0,0, -(length/2 - lead_in_chamfer_height/2)])
        cylinder(h=lead_in_chamfer_height + 4*eps, r1=bore_r, r2=bore_r + lead_in_chamfer_height, center=true);
}

module threaded_insert() {
    color([0.8, 0.6, 0.2])
    difference() {
        union() {
            insert_body();
            external_knurl();
        }
        internal_cutter();
    }
}

threaded_insert();