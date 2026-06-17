$fn = 96;

// "D" connector: a D-shaped body with a centered through-hole and two mounting ears with screw holes.

body_thickness = 12;
body_radius = 14;          // radius for the rounded side
flat_width = 22;           // width across the flat side to the farthest point on the curve
ear_radius = 6;
ear_offset = 22;           // distance from center to ear centers along X
ear_thickness = body_thickness;

main_hole_d = 10;          // central connector hole
ear_hole_d  = 3.6;         // mounting screw holes

module d_profile(r=14, flat_w=22){
    // D shape: circle clipped by a vertical line to create a flat side.
    // Circle centered at origin; flat side at x = -(flat_w - r)
    intersection() {
        circle(r=r);
        translate([-(flat_w - r), -r]) square([flat_w, 2*r], center=false);
    }
}

module d_body(){
    linear_extrude(height=body_thickness)
        d_profile(r=body_radius, flat_w=flat_width);
}

module ear(){
    cylinder(h=ear_thickness, r=ear_radius);
}

difference() {
    union() {
        // Main D body
        d_body();

        // Mounting ears (left/right)
        translate([ ear_offset, 0, 0]) ear();
        translate([-ear_offset, 0, 0]) ear();
    }

    // Central through-hole
    translate([0, 0, -1])
        cylinder(h=body_thickness+2, d=main_hole_d);

    // Ear screw holes
    translate([ ear_offset, 0, -1])
        cylinder(h=ear_thickness+2, d=ear_hole_d);
    translate([-ear_offset, 0, -1])
        cylinder(h=ear_thickness+2, d=ear_hole_d);
}