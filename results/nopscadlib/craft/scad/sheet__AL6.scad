// Aluminium tooling plate (single connected solid with distinguishing features)

// Parameters
plate_length = 300; //[150:600:1]
plate_width  = 200; //[100:400:1]
plate_thickness = 10; //[5:20:1]

edge_chamfer_size = 1; //[0:5:1]          // small edge break typical of tooling plate
corner_radius_value = 6; //[0:20:1]       // rounded corners
surface_marking_depth = 0.3; //[0:1:0.1]  // shallow pocket (not text) to distinguish top face

// Hole pattern (typical fixturing grid)
hole_d = 10; //[4:20:1]
hole_pitch = 50; //[25:100:1]
hole_edge_margin = 25; //[10:60:1]
countersink_d = 18; //[0:30:1]
countersink_depth = 2; //[0:6:0.5]

// Quality
$fn = 64;

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded rectangle 2D
module rounded_rect_2d(L, W, R) {
    r = clamp(R, 0, min(L, W)/2);
    if (r <= 0)
        square([L, W], center=true);
    else
        offset(r=r) offset(delta=-r) square([L, W], center=true);
}

// Main tooling plate module
module tooling_plate() {
    // Derived safe values
    r = clamp(corner_radius_value, 0, min(plate_length, plate_width)/2);
    cham = clamp(edge_chamfer_size, 0, plate_thickness/2);
    mark_d = clamp(surface_marking_depth, 0, plate_thickness - 0.2);

    // Hole grid counts (ensure at least 1 position if space allows)
    usable_L = plate_length - 2*hole_edge_margin;
    usable_W = plate_width  - 2*hole_edge_margin;
    nx = max(1, floor(usable_L / hole_pitch) + 1);
    ny = max(1, floor(usable_W / hole_pitch) + 1);

    // Center the grid within margins
    grid_span_x = (nx - 1) * hole_pitch;
    grid_span_y = (ny - 1) * hole_pitch;
    x0 = -grid_span_x/2;
    y0 = -grid_span_y/2;

    color("Silver")
    difference() {
        // Base plate with rounded corners
        linear_extrude(height=plate_thickness, center=true)
            rounded_rect_2d(plate_length, plate_width, r);

        // Edge chamfer (45°) around top perimeter
        if (cham > 0) {
            translate([0, 0, plate_thickness/2 - cham/2])
                linear_extrude(height=cham, center=true, scale=[
                    (plate_length - 2*cham)/plate_length,
                    (plate_width  - 2*cham)/plate_width
                ])
                    rounded_rect_2d(plate_length, plate_width, max(0, r - cham));
        }

        // Shallow rectangular pocket on top face (distinguishing feature, no text)
        if (mark_d > 0) {
            pocket_L = plate_length * 0.55;
            pocket_W = plate_width  * 0.25;
            pocket_R = min(r, min(pocket_L, pocket_W)/6);

            translate([0, 0, plate_thickness/2 - mark_d/2])
                linear_extrude(height=mark_d, center=true)
                    rounded_rect_2d(pocket_L, pocket_W, pocket_R);
        }

        // Through holes + optional countersink on top
        for (ix = [0:nx-1])
            for (iy = [0:ny-1]) {
                x = x0 + ix * hole_pitch;
                y = y0 + iy * hole_pitch;

                // Through hole
                translate([x, y, 0])
                    cylinder(d=hole_d, h=plate_thickness + 0.4, center=true);

                // Countersink (shallow counterbore) on top face
                if (countersink_d > hole_d && countersink_depth > 0) {
                    translate([x, y, plate_thickness/2 - countersink_depth/2])
                        cylinder(d=countersink_d, h=countersink_depth + 0.2, center=true);
                }
            }
    }
}

// Assemble
tooling_plate();