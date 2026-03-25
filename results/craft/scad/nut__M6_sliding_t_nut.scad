// T-slot nut for 6.0mm screws, 8.0mm across flats hex, 6.6mm thick
// One connected solid (single manifold). No floating parts.

// Parameters
screw_thread_diameter_mm = 6.0; //[3.0:12.0:0.1]
across_flats_mm = 8.0;          //[4.0:16.0:0.1]
thickness_mm = 6.6;             //[3.3:13.2:0.1]

t_slot_nut_length_mm = 16.0;    //[8.0:32.0:0.5]
t_slot_nut_width_mm  = 12.0;    //[6.0:24.0:0.5]

wing_thickness_mm = 2.0;        //[1.0:4.0:0.1]
wing_height_mm    = 2.2;        //[1.0:4.0:0.1]
wing_length_mm    = 14.0;       //[6.0:28.0:0.5]
wing_overlap_mm   = 1.0;        //[0.5:2.0:0.1]

corner_chamfer_mm = 0.3;        //[0.0:1.5:0.1]

// Thread modeling (cosmetic internal thread; prints as a helical groove)
thread_pitch_mm = 1.0;          //[0.5:2.0:0.05]   // M6 coarse = 1.0
thread_depth_mm = 0.35;         //[0.1:0.6:0.05]   // groove depth (radial)
thread_clearance_mm = 0.20;     //[0.0:0.5:0.05]   // extra radius for print fit
thread_fn = 96;                 //[48:192]         // smoothness

hex_clearance_mm = 0.0;         //[0.0:0.5:0.05]

// Derived
function hex_R_from_AF(af) = af / (2*cos(30)); // circumradius for $fn=6 cylinder

module chamfered_block(size=[10,10,10], chamfer=0.3, center=true) {
    c = max(0, chamfer);
    if (c <= 0) {
        cube(size, center=center);
    } else {
        minkowski() {
            cube([max(0.01, size[0]-2*c), max(0.01, size[1]-2*c), max(0.01, size[2]-2*c)], center=center);
            sphere(r=c, $fn=24);
        }
    }
}

// Internal "thread" cutter: a helical triangular groove subtracted from a pilot hole.
// This is a printable approximation (not a standards-perfect ISO profile).
module internal_thread_cutter(d_nom=6.0, pitch=1.0, depth=0.35, clearance=0.2, h=6.6, fn=96) {
    // Pilot radius (minor-ish) and groove geometry
    r_pilot = d_nom/2 + clearance;          // base radius for hole
    r_outer = r_pilot + depth;              // max radius reached by groove
    turns = h / pitch;
    twist_deg = -360 * turns;               // internal thread direction

    // Pilot hole (ensures through-hole and defines base diameter)
    cylinder(h=h + 0.4, r=r_pilot, center=true, $fn=fn);

    // Helical groove (triangular-ish) around the pilot hole
    // Use linear_extrude with twist; the 2D profile is a small triangle at radius r_pilot.
    linear_extrude(height=h + 0.4, center=true, twist=twist_deg, slices=max(ceil(turns*24), 24), convexity=10)
        translate([r_pilot, 0, 0])
            polygon(points=[
                [0, -pitch*0.28],
                [depth, 0],
                [0,  pitch*0.28]
            ]);
}

module tslot_nut() {
    difference() {
        union() {
            // Main rectangular body
            chamfered_block([t_slot_nut_length_mm, t_slot_nut_width_mm, thickness_mm], corner_chamfer_mm, center=true);

            // Retention wings (connected via overlap)
            wing_z = -thickness_mm/2 + wing_height_mm/2; // sits on bottom
            wing_y_pos =  t_slot_nut_width_mm/2 + wing_thickness_mm/2 - wing_overlap_mm;
            wing_y_neg = -t_slot_nut_width_mm/2 - wing_thickness_mm/2 + wing_overlap_mm;

            translate([0, wing_y_pos, wing_z])
                chamfered_block([wing_length_mm, wing_thickness_mm, wing_height_mm], corner_chamfer_mm, center=true);

            translate([0, wing_y_neg, wing_z])
                chamfered_block([wing_length_mm, wing_thickness_mm, wing_height_mm], corner_chamfer_mm, center=true);

            // Hex feature (8mm across flats) spanning full thickness for verifiable AF
            // Slight overlap into body to ensure manifold union.
            hex_h = thickness_mm;
            hex_overlap = 0.2;
            hex_z = 0; // centered; union with body fully
            translate([0, 0, hex_z])
                rotate([0, 0, 30])
                    cylinder(h=hex_h + 2*hex_overlap,
                             r=hex_R_from_AF(across_flats_mm + hex_clearance_mm),
                             center=true, $fn=6);
        }

        // Threaded hole (modeled as pilot hole + helical groove subtraction)
        internal_thread_cutter(
            d_nom=screw_thread_diameter_mm,
            pitch=thread_pitch_mm,
            depth=thread_depth_mm,
            clearance=thread_clearance_mm,
            h=thickness_mm,
            fn=thread_fn
        );

        // Lead-in chamfers (conical) to help start the screw
        lead_h = max(0.01, corner_chamfer_mm*2);
        lead_r1 = screw_thread_diameter_mm/2 + thread_clearance_mm;
        lead_r2 = lead_r1 + corner_chamfer_mm*2;

        translate([0, 0,  thickness_mm/2 - lead_h/2])
            cylinder(h=lead_h, r1=lead_r2, r2=lead_r1, center=true, $fn=thread_fn);

        translate([0, 0, -thickness_mm/2 + lead_h/2])
            cylinder(h=lead_h, r1=lead_r1, r2=lead_r2, center=true, $fn=thread_fn);
    }
}

tslot_nut();