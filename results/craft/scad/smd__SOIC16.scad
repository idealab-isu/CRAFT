// SMD package: exact overall dimensions [9.90, 3.90, 1.25] (L x W x H)
// One connected solid (dot is fused to body). No floating parts.

// Parameters
body_length = 9.90;
body_width  = 3.90;
body_height = 1.25;

notch_length = 1.20;
notch_width  = 1.00;
notch_depth  = 0.35;

dot_radius = 0.35;
dot_height = 0.15;
dot_edge_offset = 0.80;

chamfer_size = 0.35;

// Small overlap to guarantee manifold connectivity in unions/differences
eps = 0.02;

// Main body
module main_body() {
    cube([body_length, body_width, body_height], center=true);
}

// Marking notch (subtracted from top surface, near one corner)
module marking_notch() {
    translate([
        -body_length/2 + notch_length/2,
         body_width/2  - notch_width/2,
         body_height/2 - notch_depth/2 + eps
    ])
    cube([notch_length, notch_width, notch_depth + 2*eps], center=true);
}

// Single corner chamfer (subtracted wedge at +X edge)
module edge_chamfer() {
    translate([body_length/2 - chamfer_size/2, 0, body_height/2 - chamfer_size/2])
        rotate([0, 45, 0])
            cube([chamfer_size, body_width + 2*eps, chamfer_size + 2*eps], center=true);
}

// Pin-1 dot (added on top, fused into body by eps)
module pin1_dot() {
    translate([
        -body_length/2 + dot_edge_offset,
         body_width/2  - dot_edge_offset,
         body_height/2 + dot_height/2 - eps
    ])
    cylinder(r=dot_radius, h=dot_height + 2*eps, center=true, $fn=48);
}

// Final SMD package (single connected solid)
module smd_complete() {
    union() {
        difference() {
            main_body();
            marking_notch();
            edge_chamfer();
        }
        pin1_dot();
    }
}

smd_complete();