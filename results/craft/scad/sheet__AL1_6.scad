// Aluminium tooling plate (single connected solid) - render-safe version (no minkowski)

// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200;  //[100:400:1]
plate_thickness = 12; //[6:24:1]

edge_chamfer = 1;   //[0:4:0.5]   // visual chamfer amount
corner_radius = 6;  //[0:20:1]

mount_hole_diameter = 10; //[4:20:0.5]
mount_hole_edge_offset_x = 25; //[10:80:1]
mount_hole_edge_offset_y = 25; //[10:80:1]

hole_overlap = 1;   //[0.5:2:0.5]
marking_depth = 0.3; //[0.1:1:0.1]
marking_margin = 15; //[5:40:1]

$fn = 48;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep radii/offsets valid so geometry never disappears
cr = clamp(corner_radius, 0, min(plate_length, plate_width)/2 - 0.01);
ch = clamp(edge_chamfer, 0, plate_thickness/2 - 0.01);

// 2D rounded rectangle using offset (fast) then extrude
module rounded_rect_2d(len, wid, rad) {
    if (rad <= 0) {
        square([len, wid], center=true);
    } else {
        // offset() rounds corners; shrink then expand to keep outer size
        offset(r=rad)
            offset(delta=-rad)
                square([len, wid], center=true);
    }
}

module plate_3d(len, wid, thick, rad) {
    linear_extrude(height=thick, center=true)
        rounded_rect_2d(len, wid, rad);
}

module mounting_holes() {
    hx = plate_length/2 - mount_hole_edge_offset_x;
    hy = plate_width/2  - mount_hole_edge_offset_y;

    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*hx, sy*hy, 0])
            cylinder(d=mount_hole_diameter, h=plate_thickness + 2*hole_overlap, center=true);
}

module surface_marking_cut() {
    // shallow pocket on top face
    translate([0, 0, plate_thickness/2 - marking_depth/2])
        cube([plate_length - 2*marking_margin,
              plate_width  - 2*marking_margin,
              marking_depth], center=true);
}

module chamfer_cut() {
    // subtract a slightly larger plate from top and bottom to create a chamfer-like bevel
    if (ch > 0) {
        // Top bevel
        translate([0, 0, plate_thickness/2 - ch/2])
            linear_extrude(height=ch, center=true)
                offset(delta=ch)
                    rounded_rect_2d(plate_length, plate_width, cr);

        // Bottom bevel
        translate([0, 0, -plate_thickness/2 + ch/2])
            linear_extrude(height=ch, center=true)
                offset(delta=ch)
                    rounded_rect_2d(plate_length, plate_width, cr);
    }
}

module complete_model() {
    difference() {
        plate_3d(plate_length, plate_width, plate_thickness, cr);
        mounting_holes();
        surface_marking_cut();
        chamfer_cut();
    }
}

// Final output
color("Silver") complete_model();