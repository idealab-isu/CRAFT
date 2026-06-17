$fn = 96;

// Miniature linear guide rail
// Overall: 20.0mm wide (X), 17.5mm tall (Z), 100mm long (Y)

rail_w = 20.0;
rail_h = 17.5;
rail_l = 100.0;

// Profile details (tunable)
top_w = 12.0;          // top plateau width
top_h = 3.0;           // top plateau height
side_chamfer = 2.0;    // chamfer size on outer edges
groove_depth = 2.2;    // side groove depth
groove_h = 5.0;        // side groove height
groove_z = 7.0;        // groove bottom Z from base

// Mounting holes (along Y, drilled in Z)
hole_d = 4.2;          // through hole diameter
csk_d = 7.8;           // counterbore diameter
csk_h = 2.2;           // counterbore depth
end_margin = 12.0;     // distance from ends to first/last hole
hole_pitch = 25.0;     // spacing along length

eps = 0.02;

module rail_profile_2d() {
    // Outer profile in X-Z plane (z from 0..rail_h)
    difference() {
        polygon(points=[
            [-rail_w/2 + side_chamfer, 0],
            [ rail_w/2 - side_chamfer, 0],
            [ rail_w/2, side_chamfer],
            [ rail_w/2, rail_h - side_chamfer],
            [ rail_w/2 - side_chamfer, rail_h],
            [ rail_w/2 - (rail_w - top_w)/2, rail_h],
            [ rail_w/2 - (rail_w - top_w)/2, rail_h - top_h],
            [-rail_w/2 + (rail_w - top_w)/2, rail_h - top_h],
            [-rail_w/2 + (rail_w - top_w)/2, rail_h],
            [-rail_w/2 + side_chamfer, rail_h],
            [-rail_w/2, rail_h - side_chamfer],
            [-rail_w/2, side_chamfer]
        ]);

        // Side grooves (both sides), rectangular cuts
        for (sx = [-1, 1]) {
            translate([sx*(rail_w/2 - groove_depth/2), groove_z + groove_h/2])
                square([groove_depth, groove_h], center=true);
        }
    }
}

module rail_body() {
    // Extrude along Y; keep rail spanning Y=[0..rail_l]
    rotate([-90, 0, 0])
        linear_extrude(height=rail_l, center=false, convexity=10)
            rail_profile_2d();
}

module mounting_holes() {
    // Through holes + counterbores from top, drilled along -Z
    for (y = [end_margin : hole_pitch : rail_l - end_margin + eps]) {
        // Through hole (Z axis)
        translate([0, y, -1])
            cylinder(d=hole_d, h=rail_h + 2, center=false);

        // Counterbore from top
        translate([0, y, rail_h - csk_h])
            cylinder(d=csk_d, h=csk_h + 1, center=false);
    }
}

difference() {
    rail_body();
    mounting_holes();
}