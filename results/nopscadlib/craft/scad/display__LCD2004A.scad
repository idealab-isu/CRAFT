$fn = 64;

// LCD 2004A-like module (approx) 97.0 x 39.5 mm
// One connected solid, no floating parts, all translations derived from dimensions.

overlap_mm = 0.8;

// -------------------- Parameters --------------------
module_width_mm  = 97.0;   // X
module_height_mm = 39.5;   // Y

pcb_thickness_mm = 1.6;

// Front bezel/frame
bezel_thickness_mm = 3.0;          // raised front frame thickness
bezel_frame_margin_x_mm = 4.0;     // frame border from PCB edge
bezel_frame_margin_y_mm = 3.0;

// Viewing aperture (window)
aperture_width_mm  = 76.0;
aperture_height_mm = 25.0;
aperture_offset_x_mm = 0.0;
aperture_offset_y_mm = 0.0;

// Recessed "black mask" around window (gives recognizable LCD look)
mask_margin_mm = 3.0;
mask_recess_mm = 0.9;

// Glass
display_glass_thickness_mm = 1.6;
display_glass_margin_mm = 1.2;

// Mounting holes
mount_hole_diameter_mm = 3.2;
mount_hole_edge_margin_x_mm = 3.5;
mount_hole_edge_margin_y_mm = 3.5;

// Back standoffs/bosses (kept connected to PCB)
standoff_diameter_mm = 7.0;
standoff_height_mm   = 4.0;

// Pin header (16-pin) on back, near bottom edge (-Y)
pin_header_pitch_mm = 2.54;
pin_header_pins = 16;
pin_header_body_width_mm  = 6.0;   // Y
pin_header_body_height_mm = 8.5;   // Z
pin_header_body_length_extra_mm = 2.0; // X extra beyond pin span
pin_header_edge_clearance_y_mm = 4.0;  // distance from PCB bottom edge to header body edge
pin_header_overhang_below_pcb_mm = 3.0;

// Individual pins (visual detail)
pin_square_mm = 0.7;
pin_len_below_header_mm = 3.0;
pin_len_into_pcb_mm = 1.2;

// Back controller/COB area (common on these modules)
controller_width_mm  = 32.0;
controller_height_mm = 18.0;
controller_thickness_mm = 2.6;
controller_edge_clearance_x_mm = 10.0; // from right edge inward
controller_offset_y_mm = 0.0;

// Small back components (adds PCB detail)
chip1_size = [12.0, 8.0, 2.0];
chip2_size = [10.0, 6.0, 1.8];
cap_size   = [6.0, 3.0, 3.0];

// -------------------- Derived Z planes --------------------
pcb_z0 = 0;
pcb_top_z    = pcb_z0 + pcb_thickness_mm/2;
pcb_bottom_z = pcb_z0 - pcb_thickness_mm/2;

// Bezel sits on top of PCB with slight overlap
bezel_center_z = pcb_top_z + bezel_thickness_mm/2 - overlap_mm;

// Mask is a recessed plate inside bezel opening (still connected)
mask_thickness_mm = mask_recess_mm + overlap_mm; // ensure it intersects bezel
mask_center_z = (pcb_top_z + bezel_thickness_mm) - mask_thickness_mm/2 - overlap_mm;

// Glass sits behind bezel opening, slightly below bezel top, intersects mask for connectivity
glass_center_z = (pcb_top_z + bezel_thickness_mm) - display_glass_thickness_mm/2 - (mask_recess_mm/2) - overlap_mm;

// Back standoffs connect to PCB bottom
standoff_center_z = pcb_bottom_z - standoff_height_mm/2 + overlap_mm;

// Header placement (derived from PCB bottom edge)
header_len_x = (pin_header_pins - 1) * pin_header_pitch_mm + pin_header_body_length_extra_mm;
header_center_y = -module_height_mm/2 + pin_header_edge_clearance_y_mm + pin_header_body_width_mm/2;
header_center_z = pcb_bottom_z - pin_header_overhang_below_pcb_mm + pin_header_body_height_mm/2 + overlap_mm;

// Pins placement
pin_center_z = header_center_z - pin_header_body_height_mm/2 - pin_len_below_header_mm/2 + overlap_mm;

// Controller placement (derived from right edge)
controller_center_x = module_width_mm/2 - controller_edge_clearance_x_mm - controller_width_mm/2;
controller_center_z = pcb_bottom_z - controller_thickness_mm/2 + overlap_mm;

// -------------------- Helpers --------------------
module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
    // Minkowski rounded rectangle prism (kept light)
    // size is final size; r is corner radius
    sx = size[0]; sy = size[1]; sz = size[2];
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
        minkowski() {
            cube([max(0.01, sx-2*r), max(0.01, sy-2*r), sz], center=true);
            cylinder(r=r, h=0.01, center=true);
        }
}

// -------------------- Geometry --------------------
module pcb_with_holes() {
    difference() {
        cube([module_width_mm, module_height_mm, pcb_thickness_mm], center=true);

        // mounting holes through PCB
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(module_width_mm/2 - mount_hole_edge_margin_x_mm),
                sy*(module_height_mm/2 - mount_hole_edge_margin_y_mm),
                0
            ])
            cylinder(h=pcb_thickness_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
        }
    }
}

module bezel_frame_with_window() {
    bezel_w = module_width_mm  - 2*bezel_frame_margin_x_mm;
    bezel_h = module_height_mm - 2*bezel_frame_margin_y_mm;

    difference() {
        translate([0, 0, bezel_center_z])
            rounded_rect_prism([bezel_w, bezel_h, bezel_thickness_mm], r=1.2, center=true);

        // viewing aperture cutout through bezel
        translate([aperture_offset_x_mm, aperture_offset_y_mm, bezel_center_z])
            cube([aperture_width_mm, aperture_height_mm, bezel_thickness_mm + 2*overlap_mm], center=true);
    }
}

module recessed_mask_plate() {
    // A plate under the bezel with a larger opening, creating a "bezel recess" look.
    // It intersects the bezel (connectivity) and provides recognizable LCD window depth.
    mask_outer_w = (module_width_mm  - 2*bezel_frame_margin_x_mm) - 2*overlap_mm;
    mask_outer_h = (module_height_mm - 2*bezel_frame_margin_y_mm) - 2*overlap_mm;

    mask_open_w = aperture_width_mm  + 2*mask_margin_mm;
    mask_open_h = aperture_height_mm + 2*mask_margin_mm;

    difference() {
        translate([0, 0, mask_center_z])
            cube([mask_outer_w, mask_outer_h, mask_thickness_mm], center=true);

        translate([aperture_offset_x_mm, aperture_offset_y_mm, mask_center_z])
            cube([mask_open_w, mask_open_h, mask_thickness_mm + 2*overlap_mm], center=true);
    }
}

module display_glass() {
    // Slightly larger than aperture, sits behind it
    translate([aperture_offset_x_mm, aperture_offset_y_mm, glass_center_z])
        cube([
            aperture_width_mm + 2*display_glass_margin_mm,
            aperture_height_mm + 2*display_glass_margin_mm,
            display_glass_thickness_mm
        ], center=true);
}

module standoffs() {
    // Back-side bosses around mounting holes (connected to PCB)
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([
            sx*(module_width_mm/2 - mount_hole_edge_margin_x_mm),
            sy*(module_height_mm/2 - mount_hole_edge_margin_y_mm),
            standoff_center_z
        ])
        difference() {
            cylinder(h=standoff_height_mm, r=standoff_diameter_mm/2, center=true);
            // clearance hole (not through PCB, just boss)
            cylinder(h=standoff_height_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
        }
    }
}

module pin_header_body_and_pins() {
    // Header body
    translate([0, header_center_y, header_center_z])
        cube([header_len_x, pin_header_body_width_mm, pin_header_body_height_mm], center=true);

    // Pins (visual detail), ensured to intersect header body and extend toward PCB
    pin_span_x = (pin_header_pins - 1) * pin_header_pitch_mm;
    x0 = -pin_span_x/2;

    for (i = [0:pin_header_pins-1]) {
        px = x0 + i*pin_header_pitch_mm;

        // Pin below header
        translate([px, header_center_y, pin_center_z])
            cube([pin_square_mm, pin_square_mm, pin_len_below_header_mm], center=true);

        // Pin stub into PCB (connects header to PCB visually)
        // Place so top of stub slightly intersects PCB bottom.
        stub_center_z = pcb_bottom_z + pin_len_into_pcb_mm/2 - overlap_mm;
        translate([px, header_center_y, stub_center_z])
            cube([pin_square_mm, pin_square_mm, pin_len_into_pcb_mm], center=true);
    }
}

module controller_and_components() {
    // Controller blob (COB/IC area)
    translate([controller_center_x, controller_offset_y_mm, controller_center_z])
        rounded_rect_prism([controller_width_mm, controller_height_mm, controller_thickness_mm], r=1.0, center=true);

    // A couple of small components near controller (all connected to PCB by overlap)
    comp_z = pcb_bottom_z - chip1_size[2]/2 + overlap_mm;

    // Chip 1
    translate([
        controller_center_x - controller_width_mm/2 + chip1_size[0]/2 + 3.0,
        controller_offset_y_mm + controller_height_mm/2 + chip1_size[1]/2 + 2.0,
        comp_z
    ])
    cube(chip1_size, center=true);

    // Chip 2
    translate([
        controller_center_x - controller_width_mm/2 + chip2_size[0]/2 + 6.0,
        controller_offset_y_mm - controller_height_mm/2 - chip2_size[1]/2 - 2.0,
        pcb_bottom_z - chip2_size[2]/2 + overlap_mm
    ])
    cube(chip2_size, center=true);

    // Capacitor block near header
    translate([
        -module_width_mm/2 + cap_size[0]/2 + 8.0,
        header_center_y + pin_header_body_width_mm/2 + cap_size[1]/2 + 2.0,
        pcb_bottom_z - cap_size[2]/2 + overlap_mm
    ])
    cube(cap_size, center=true);
}

// -------------------- Assembly (ONE connected solid) --------------------
module assembly() {
    union() {
        pcb_with_holes();
        bezel_frame_with_window();
        recessed_mask_plate();
        display_glass();
        standoffs();
        pin_header_body_and_pins();
        controller_and_components();
    }
}

assembly();