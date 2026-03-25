// Aluminium tooling plate (single connected solid with visible features)

// Parameters
plate_length = 300; //[150:600:1]
plate_width  = 200; //[100:400:1]
plate_thickness = 12; //[6:24:1]

corner_radius = 10; //[5:20:1]
edge_chamfer  = 1.5; //[0.5:4:0.1]

// Visible distinguishing features (countersunk mounting holes)
hole_d = 8;            //[4:16:0.5]
csk_d  = 16;           //[8:30:0.5]
csk_depth = 3;         //[1:6:0.1]
hole_edge_margin = 25; //[10:60:1]

op_overlap = 0.5; //[0.1:2:0.1]
$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_plate_2d(L, W, R){
    // Robust rounded rectangle using hull of corner circles
    r = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r), sy*(W/2 - r)]) circle(r=r);
    }
}

module plate_body(){
    linear_extrude(height=plate_thickness, center=true, convexity=10)
        rounded_plate_2d(plate_length, plate_width, corner_radius);
}

module top_edge_chamfer(){
    // Chamfer only on the top perimeter (keeps model simple and connected)
    // Implemented as subtracting a slightly smaller rounded plate extruded upward.
    inset = edge_chamfer;
    r2 = max(0.01, corner_radius - inset);
    translate([0, 0, plate_thickness/2 - edge_chamfer/2])
        linear_extrude(height=edge_chamfer + 2*op_overlap, center=true, convexity=10)
            rounded_plate_2d(plate_length - 2*inset, plate_width - 2*inset, r2);
}

module countersunk_hole_at(x, y){
    // Through hole + top countersink (both subtract)
    union() {
        // Through hole
        translate([x, y, 0])
            cylinder(d=hole_d, h=plate_thickness + 2*op_overlap, center=true);

        // Countersink from top face
        translate([x, y, plate_thickness/2 - csk_depth/2])
            cylinder(d1=csk_d, d2=hole_d, h=csk_depth + 2*op_overlap, center=true);
    }
}

module mounting_holes(){
    // 4 holes near corners, positioned by formulas from dimensions
    mx = plate_length/2 - hole_edge_margin;
    my = plate_width/2  - hole_edge_margin;

    // Keep holes inside even if margins are large
    mx2 = clamp(mx, 0, plate_length/2 - corner_radius - hole_d);
    my2 = clamp(my, 0, plate_width/2  - corner_radius - hole_d);

    for (sx = [-1, 1], sy = [-1, 1])
        countersunk_hole_at(sx*mx2, sy*my2);
}

// Final Output (ONE connected solid)
module final_plate(){
    difference(){
        plate_body();

        // Visible features
        mounting_holes();

        // Top chamfer (subtract inner "cap" to create a bevel-like edge)
        top_edge_chamfer();
    }
}

color("Silver") final_plate();