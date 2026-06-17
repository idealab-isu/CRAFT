$fn = 64;

// Parameters (mm)
pcb_length = 40.0;
pcb_width  = 16.0;
pcb_thickness = 1.6;

corner_radius = 2.0;

hole_diameter = 2.0;
hole_offset   = 3.0;

connector_cutout_width = 5.0;
connector_cutout_depth = 1.0;

// Small overlap to avoid coincident faces in booleans
eps = 0.02;

// 2D rounded rectangle (centered)
module rounded_rect_2d(L, W, R) {
    // Clamp radius to valid range
    r = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r), sy*(W/2 - r)])
                circle(r=r);
    }
}

// Main PCB solid with holes and edge cutouts (ONE connected solid)
module pcb() {
    difference() {
        // PCB body (3D)
        linear_extrude(height=pcb_thickness, center=true, convexity=10)
            rounded_rect_2d(pcb_length, pcb_width, corner_radius);

        // Mounting holes (through)
        for (x = [-pcb_length/2 + hole_offset, pcb_length/2 - hole_offset])
            for (y = [-pcb_width/2 + hole_offset, pcb_width/2 - hole_offset])
                translate([x, y, 0])
                    cylinder(h=pcb_thickness + 2*eps, d=hole_diameter, center=true);

        // Edge connector cutouts (notches) - subtract from left and right edges
        for (sx = [-1, 1]) {
            translate([sx*(pcb_length/2 - connector_cutout_depth/2), 0, 0])
                cube([connector_cutout_depth + 2*eps,
                      connector_cutout_width,
                      pcb_thickness + 2*eps], center=true);
        }
    }
}

pcb();