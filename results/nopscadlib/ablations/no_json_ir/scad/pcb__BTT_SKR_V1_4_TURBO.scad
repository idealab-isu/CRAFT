$fn = 64;

// =====================
// Mainboard parameters
// =====================
pcb_length = 110.0;
pcb_width  = 85.0;
pcb_thickness = 1.6;

corner_radius = 5.0;

mounting_hole_diameter = 3.0;
mounting_hole_offset   = 5.0;

// Small overlap to guarantee one connected solid
overlap = 0.4;

// Helper: rounded rectangle 2D
module rounded_rect_2d(L, W, R) {
    // Use minkowski for robust rounded corners
    minkowski() {
        square([L - 2*R, W - 2*R], center=true);
        circle(r=R);
    }
}

// PCB with holes (solid board)
module pcb_body() {
    difference() {
        linear_extrude(height=pcb_thickness, center=false)
            rounded_rect_2d(pcb_length, pcb_width, corner_radius);

        // Mounting holes (through)
        for (x = [-pcb_length/2 + mounting_hole_offset, pcb_length/2 - mounting_hole_offset])
            for (y = [-pcb_width/2 + mounting_hole_offset, pcb_width/2 - mounting_hole_offset])
                translate([x, y, pcb_thickness/2])
                    cylinder(h=pcb_thickness + 2, d=mounting_hole_diameter, center=true);
    }
}

// Generic component placed on top surface, guaranteed connected by overlap
module comp_box(cx, cy, sx, sy, sz) {
    translate([cx, cy, pcb_thickness + sz/2 - overlap/2])
        cube([sx, sy, sz], center=true);
}

// Generic component placed on bottom surface, guaranteed connected by overlap
module comp_box_bottom(cx, cy, sx, sy, sz) {
    translate([cx, cy, -sz/2 + overlap/2])
        cube([sx, sy, sz], center=true);
}

// A simple "heatsink" block with fins (still one solid)
module heatsink_with_fins(cx, cy, base_x, base_y, base_z, fin_count, fin_t, fin_h) {
    union() {
        // Base
        comp_box(cx, cy, base_x, base_y, base_z);

        // Fins on top of base
        fin_pitch = base_x / fin_count;
        for (i = [0:fin_count-1]) {
            fin_x = fin_t;
            fin_y = base_y - 1.0;
            fin_z = fin_h;

            // Place fins across base_x, centered
            x0 = cx - base_x/2 + fin_pitch/2 + i*fin_pitch;

            // Z: sit on top of base with overlap
            translate([x0, cy, pcb_thickness + base_z - overlap/2 + fin_z/2])
                cube([fin_x, fin_y, fin_z], center=true);
        }
    }
}

// A simple edge connector that protrudes beyond PCB edge but remains connected
module edge_connector_right(cy, body_x, body_y, body_z, lip_x, lip_z) {
    union() {
        // Main body: straddles the right edge slightly to ensure connection
        translate([pcb_length/2 - body_x/2 + overlap, cy, pcb_thickness + body_z/2 - overlap/2])
            cube([body_x, body_y, body_z], center=true);

        // Small lip protruding outward (still connected)
        translate([pcb_length/2 + lip_x/2 - overlap, cy, pcb_thickness + lip_z/2 - overlap/2])
            cube([lip_x, body_y*0.9, lip_z], center=true);
    }
}

// A simple edge connector on left edge
module edge_connector_left(cy, body_x, body_y, body_z, lip_x, lip_z) {
    union() {
        translate([-pcb_length/2 + body_x/2 - overlap, cy, pcb_thickness + body_z/2 - overlap/2])
            cube([body_x, body_y, body_z], center=true);

        translate([-pcb_length/2 - lip_x/2 + overlap, cy, pcb_thickness + lip_z/2 - overlap/2])
            cube([lip_x, body_y*0.9, lip_z], center=true);
    }
}

// Screw terminal block near an edge (connected)
module screw_terminal(cx, cy, sx, sy, sz, post_d, post_h, post_spacing) {
    union() {
        comp_box(cx, cy, sx, sy, sz);

        // Two "wire entry" posts on top
        for (dx = [-post_spacing/2, post_spacing/2]) {
            translate([cx + dx, cy, pcb_thickness + sz - overlap/2 + post_h/2])
                cylinder(h=post_h, d=post_d, center=true);
        }
    }
}

// =====================
// Assembly
// =====================
module mainboard_assembly() {
    union() {
        // PCB
        pcb_body();

        // Major IC (MCU) center-ish
        comp_box(0, 0, 18, 18, 2.2);

        // Stepper driver modules / chips (row)
        driver_y = pcb_width*0.18;
        for (i = [-1.5, -0.5, 0.5, 1.5]) {
            comp_box(i*14, driver_y, 10, 10, 2.0);
        }

        // Power MOSFET area with heatsink
        heatsink_with_fins(
            cx = -pcb_length*0.22,
            cy = -pcb_width*0.18,
            base_x = 22, base_y = 18, base_z = 4.0,
            fin_count = 7, fin_t = 1.2, fin_h = 6.0
        );

        // Another heatsink block
        heatsink_with_fins(
            cx = pcb_length*0.18,
            cy = -pcb_width*0.20,
            base_x = 18, base_y = 16, base_z = 3.5,
            fin_count = 6, fin_t = 1.1, fin_h = 5.0
        );

        // Right edge connectors (e.g., endstops / LCD)
        edge_connector_right(cy = pcb_width*0.22, body_x=14, body_y=12, body_z=9, lip_x=6, lip_z=7);
        edge_connector_right(cy = 0,              body_x=14, body_y=12, body_z=9, lip_x=6, lip_z=7);
        edge_connector_right(cy = -pcb_width*0.22,body_x=14, body_y=12, body_z=9, lip_x=6, lip_z=7);

        // Left edge connector (e.g., USB / SD)
        edge_connector_left(cy = pcb_width*0.05, body_x=16, body_y=14, body_z=8, lip_x=7, lip_z=6);

        // Top edge screw terminals (power / bed / hotend)
        term_y = pcb_width/2 - 10;
        screw_terminal(cx = -pcb_length*0.25, cy = term_y, sx=22, sy=14, sz=10, post_d=5.2, post_h=4.0, post_spacing=10);
        screw_terminal(cx = 0,                cy = term_y, sx=22, sy=14, sz=10, post_d=5.2, post_h=4.0, post_spacing=10);
        screw_terminal(cx = pcb_length*0.25,  cy = term_y, sx=22, sy=14, sz=10, post_d=5.2, post_h=4.0, post_spacing=10);

        // Bottom-side components (soldered headers / regulators) to show back features
        comp_box_bottom(-pcb_length*0.15, -pcb_width*0.05, 14, 10, 3.0);
        comp_box_bottom( pcb_length*0.10,  pcb_width*0.10, 12,  8, 2.6);

        // A long pin header along bottom edge (connected)
        header_len = pcb_length*0.55;
        header_w   = 6;
        header_h   = 6;
        translate([0, -pcb_width/2 + header_w/2 - overlap, pcb_thickness + header_h/2 - overlap/2])
            cube([header_len, header_w, header_h], center=true);
    }
}

mainboard_assembly();