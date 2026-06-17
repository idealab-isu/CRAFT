$fn = 96;

// IEC C14 inlet module (ATX style) with panel cutout 40.0mm x 27.0mm
cutout_width  = 40.0;
cutout_height = 27.0;

// Panel (kept as part of ONE connected solid)
panel_thickness = 1.5;
panel_margin    = 12.0;

// IEC body behind panel
iec_body_depth   = 28.0;
iec_body_extra_w = 6.0;
iec_body_extra_h = 6.0;

// Front bezel / flange
bezel_thickness = 2.2;
bezel_overhang  = 3.0;   // per side beyond cutout
bezel_chamfer   = 1.2;   // chamfer size (visual)

// Inlet cavity + features (approximate IEC C14 look)
inlet_face_w = 34.0;
inlet_face_h = 24.0;
inlet_depth  = 12.0;     // deeper so it reads as a socket

// Inner "throat" step (gives recognizable C14 recessed shape)
throat_w     = 30.0;
throat_h     = 20.0;
throat_depth = 8.0;

// Pin openings (approx)
pin_slot_w       = 6.2;
pin_slot_h       = 3.2;
pin_slot_pitch_x = 14.0; // L-N spacing

earth_w = 4.2;
earth_h = 3.2;

// Positioning of pins within inlet opening (from top edge of inlet opening)
pin_z_from_top   = 7.0;
earth_z_from_top = 16.0;

// Side latch notches (visual)
latch_notch_w     = 2.2;
latch_notch_h     = 7.0;
latch_notch_depth = 3.2;

// Optional rear module block (kept connected)
mod_block_w = 30.0;
mod_block_h = 18.0;
mod_block_d = 12.0;
mod_offset_y = 0.0;

// Screw dimples (front)
screw_hole_diameter = 3.2;
screw_hole_pitch_x  = 36.0;
screw_dimple_depth  = 0.8;

// Small overlap to guarantee connectivity / avoid coplanar artifacts
overlap = 0.6;

module panel_solid(){
    cube([cutout_width + 2*panel_margin,
          cutout_height + 2*panel_margin,
          panel_thickness], center=true);
}

module bezel_and_body(){
    // Panel centered at z=0. Front is +Z, back is -Z.
    union(){
        // Rear body (connected through overlap into panel)
        translate([0,0, -(panel_thickness/2 + iec_body_depth/2 - overlap)])
            cube([cutout_width + iec_body_extra_w,
                  cutout_height + iec_body_extra_h,
                  iec_body_depth], center=true);

        // Front bezel (flange)
        translate([0,0, +(panel_thickness/2 + bezel_thickness/2 - overlap)])
            cube([cutout_width + 2*bezel_overhang,
                  cutout_height + 2*bezel_overhang,
                  bezel_thickness], center=true);

        // Rear module block (connected to rear body)
        translate([0, mod_offset_y,
                   -(panel_thickness/2 + iec_body_depth - overlap + mod_block_d/2)])
            cube([mod_block_w, mod_block_h, mod_block_d], center=true);
    }
}

module panel_cutout_void(){
    // Panel cutout (40x27) only through panel thickness
    cube([cutout_width, cutout_height, panel_thickness + 2*overlap], center=true);
}

module inlet_cavity(){
    // Main inlet cavity starts just inside the front bezel and goes inward
    z_start = panel_thickness/2 + bezel_thickness - overlap; // just behind front face
    translate([0,0, z_start - inlet_depth/2])
        cube([inlet_face_w, inlet_face_h, inlet_depth], center=true);

    // Inner throat step (deeper, smaller rectangle) to resemble C14 recess
    translate([0,0, z_start - throat_depth/2 - (inlet_depth - throat_depth) + overlap])
        cube([throat_w, throat_h, throat_depth + overlap], center=true);
}

module inlet_rim_chamfer(){
    // Beveled rim: subtract a tapered frustum-like cut at the very front
    // Use linear_extrude with scale to create a chamfered entrance.
    z_front_center = panel_thickness/2 + bezel_thickness/2 - overlap/2;
    translate([0,0, z_front_center])
        linear_extrude(height=bezel_thickness + overlap, center=true, scale=0.88)
            square([inlet_face_w + 2*bezel_chamfer,
                    inlet_face_h + 2*bezel_chamfer], center=true);
}

module pin_openings(){
    // Cut pin slots into the back wall of the inlet cavity (not through entire body)
    z_start = panel_thickness/2 + bezel_thickness - overlap;

    // Place pins near the back of the inlet cavity so they read as openings
    pin_depth = inlet_depth * 0.55;
    z_pin_center = z_start - inlet_depth + pin_depth/2 + overlap;

    y_pin = (inlet_face_h/2 - pin_z_from_top);
    y_earth = (inlet_face_h/2 - earth_z_from_top);

    // L and N
    for (sx = [-pin_slot_pitch_x/2, pin_slot_pitch_x/2]){
        translate([sx, y_pin, z_pin_center])
            cube([pin_slot_w, pin_slot_h, pin_depth + 2*overlap], center=true);
    }

    // Earth (center, lower)
    translate([0, y_earth, z_pin_center])
        cube([earth_w, earth_h, pin_depth + 2*overlap], center=true);
}

module latch_notches(){
    // Side latch notches inside inlet cavity (visual)
    z_start = panel_thickness/2 + bezel_thickness - overlap;

    nd = latch_notch_depth;
    z_notch_center = z_start - nd/2 - overlap;

    // Put notches roughly mid-height of inlet opening
    y0 = 0;

    translate([0,0, z_notch_center]){
        for (sx = [-1, 1]){
            translate([sx*(inlet_face_w/2 - latch_notch_w/2), y0, 0])
                cube([latch_notch_w, latch_notch_h, nd + 2*overlap], center=true);
        }
    }
}

module screw_dimples(){
    // Shallow dimples on front bezel (do NOT go through -> keeps one solid)
    z_dimple_center = panel_thickness/2 + bezel_thickness - screw_dimple_depth/2;
    for (sx = [-screw_hole_pitch_x/2, screw_hole_pitch_x/2]){
        translate([sx, 0, z_dimple_center])
            cylinder(d=screw_hole_diameter, h=screw_dimple_depth + overlap, center=true);
    }
}

module iec_inlet_module(){
    difference(){
        // One connected solid base
        union(){
            panel_solid();
            bezel_and_body();
        }

        // Cut features
        panel_cutout_void();
        inlet_cavity();
        inlet_rim_chamfer();
        pin_openings();
        latch_notches();
        screw_dimples();
    }
}

iec_inlet_module();