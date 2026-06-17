$fn = 64;

// =====================
// Parameters (mm)
// =====================
module_length = 71.3;   // overall PCB length (X)
module_width  = 24.3;   // overall PCB width  (Y)
module_thickness = 1.6; // PCB thickness (Z)

mount_hole_diameter = 3.2;
mount_hole_edge_margin_x = 2.5;
mount_hole_edge_margin_y = 2.5;

lcd_window_length = 64.0;
lcd_window_width  = 14.0;
lcd_window_offset_y = 2.0;

bezel_outer_length = 68.0;
bezel_outer_width  = 18.0;
bezel_height = 3.0;
bezel_wall = 2.0;

// LCD "glass" slab (visual bulk like 1602A)
glass_length = 66.0;
glass_width  = 16.0;
glass_height = 2.2;

// 1x16 header (typical 1602A)
pins = 16;
pin_pitch = 2.54;
pin_d = 0.64;          // square-ish pin approximated as cylinder
pin_len = 3.0;         // protrusion below PCB
pin_embed = 0.8;       // embed into header body for connection

header_body_length = (pins - 1) * pin_pitch + 2.0; // small end margins
header_body_width  = 5.0;
header_body_height = 3.0;

// Place header along top edge (Y+), near left (X-), like common 1602A
header_edge_margin_x = 3.0;
header_edge_margin_y = 2.0;

// Connectivity overlap (ensures one connected solid)
connect_overlap = 0.6;

// =====================
// Helpers
// =====================
module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
    // Minkowski is heavier; keep simple with hull of cylinders
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, min(x,y)/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
    hull() {
        for (sx = [-1,1], sy = [-1,1])
            translate([sx*(x/2-rr), sy*(y/2-rr), 0])
                cylinder(r=rr, h=z, center=true);
    }
}

// =====================
// Parts
// =====================
module pcb() {
    color([0.0, 0.4, 0.2])
        cube([module_length, module_width, module_thickness], center=true);
}

module bezel_with_window() {
    // Bezel is a frame (hole through it), but still a solid part.
    // It is placed to overlap into PCB slightly to ensure connectivity.
    color([0.75, 0.75, 0.77])
    difference() {
        cube([bezel_outer_length, bezel_outer_width, bezel_height], center=true);

        // Inner opening (window) goes fully through bezel
        cube([bezel_outer_length - 2*bezel_wall,
              bezel_outer_width  - 2*bezel_wall,
              bezel_height + 2], center=true);

        // Slightly larger "view" opening aligned to LCD window (optional shaping)
        translate([0, 0, 0])
            cube([lcd_window_length, lcd_window_width, bezel_height + 2], center=true);
    }
}

module lcd_glass() {
    // Solid slab behind bezel opening (typical 1602A bulk)
    color([0.55, 0.55, 0.58])
        cube([glass_length, glass_width, glass_height], center=true);
}

module header_1x16() {
    // Header body + pins as one connected solid
    union() {
        color([0.1, 0.1, 0.6])
            cube([header_body_length, header_body_width, header_body_height], center=true);

        // Pins: extend downward; embed slightly into header body for connection
        for (i = [0:pins-1]) {
            x = -((pins-1)*pin_pitch)/2 + i*pin_pitch;
            translate([x, 0, -(header_body_height/2 + pin_len/2 - pin_embed)])
                color([0.75, 0.65, 0.2])
                    cylinder(h=pin_len, r=pin_d/2, center=true);
        }
    }
}

module mounting_holes_cut() {
    // Through-holes in PCB only
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(module_length/2 - mount_hole_edge_margin_x),
                   sy*(module_width/2  - mount_hole_edge_margin_y),
                   0])
            cylinder(h=module_thickness + 2, r=mount_hole_diameter/2, center=true);
    }
}

// =====================
// Complete connected model
// =====================
module complete_model() {
    // Z placement:
    // PCB centered at Z=0.
    // Bezel sits on top of PCB and overlaps into it by connect_overlap.
    bezel_z = module_thickness/2 + bezel_height/2 - connect_overlap;

    // Glass sits under bezel opening, on top of PCB, overlaps into PCB slightly.
    glass_z = module_thickness/2 + glass_height/2 - connect_overlap;

    // Header sits on top of PCB near top edge; overlaps into PCB.
    header_z = module_thickness/2 + header_body_height/2 - connect_overlap;

    // Header XY placement: near left, near top edge
    header_x = -module_length/2 + header_edge_margin_x + header_body_length/2 - connect_overlap;
    header_y =  module_width/2  - header_edge_margin_y - header_body_width/2 + connect_overlap;

    union() {
        // PCB with mounting holes (difference keeps it a solid with holes)
        difference() {
            pcb();
            mounting_holes_cut();
        }

        // Bezel frame (connected via overlap into PCB)
        translate([0, lcd_window_offset_y, bezel_z])
            bezel_with_window();

        // LCD glass slab (connected via overlap into PCB)
        translate([0, lcd_window_offset_y, glass_z])
            lcd_glass();

        // 1x16 header (connected via overlap into PCB)
        translate([header_x, header_y, header_z])
            header_1x16();
    }
}

complete_model();