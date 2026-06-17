// Linear bearing block for 8.0mm shaft
// Overall block size: 42.0mm x 36.0mm x 20.0mm
// Fast-render version: removes minkowski(), uses 2D offset + linear_extrude for rounded outer edges

$fn = 48;

// Parameters
block_L = 42.0; //[21.0:84.0:0.5]
block_W = 36.0; //[18.0:72.0:0.5]
block_H = 20.0; //[10.0:40.0:0.5]

shaft_d = 8.0; //[4.0:16.0:0.1]
bore_d  = 8.2; //[8.0:9.0:0.05]   // clearance for 8mm shaft

// Bore runs along X, centered in Y, centered in Z by default
bore_axis_offset_Z = block_H/2; //[6.0:14.0:0.5]

mount_hole_d = 4.5; //[3.0:6.0:0.1]
mount_hole_edge_margin_L = 6.0; //[3.0:12.0:0.5]
mount_hole_edge_margin_W = 6.0; //[3.0:12.0:0.5]

counterbore_d = 8.5; //[6.5:12.0:0.1]
counterbore_depth = 3.0; //[1.0:6.0:0.5]

chamfer_bore = 0.8; //[0.0:2.0:0.1]

grease_port_d = 3.0; //[1.5:5.0:0.1]
grease_port_depth = 8.0; //[4.0:16.0:0.5]

bearing_relief_d = 15.0; //[10.0:22.0:0.5]
bearing_relief_depth = 2.0; //[0.0:4.0:0.1]

edge_fillet_r = 1.0; //[0.0:3.0:0.1]

overlap = 0.8; //[0.2:2.0:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep bore axis inside the block
bore_Z = clamp(bore_axis_offset_Z, bore_d/2 + 0.5, block_H - (bore_d/2 + 0.5));

// --- Subtractive features ---

// Through bore for 8mm shaft (along X)
module shaft_bore() {
    translate([0, 0, bore_Z - block_H/2])
        rotate([0, 90, 0])
            cylinder(h=block_L + 2*overlap, r=bore_d/2, center=true);
}

// Lead-in chamfers at both ends of the bore (conical frustums)
module bore_chamfers() {
    if (chamfer_bore > 0) {
        translate([-block_L/2 + chamfer_bore/2, 0, bore_Z - block_H/2])
            rotate([0, 90, 0])
                cylinder(h=chamfer_bore + overlap,
                         r1=bore_d/2 + chamfer_bore,
                         r2=bore_d/2,
                         center=true);

        translate([ block_L/2 - chamfer_bore/2, 0, bore_Z - block_H/2])
            rotate([0, 90, 0])
                cylinder(h=chamfer_bore + overlap,
                         r1=bore_d/2,
                         r2=bore_d/2 + chamfer_bore,
                         center=true);
    }
}

// Mounting holes (through Z)
module mount_hole_at(x, y) {
    translate([x, y, 0])
        cylinder(h=block_H + 2*overlap, r=mount_hole_d/2, center=true);
}

// Counterbores from top face (Z+)
module counterbore_at(x, y) {
    translate([x, y, block_H/2 - counterbore_depth/2])
        cylinder(h=counterbore_depth + overlap, r=counterbore_d/2, center=true);
}

// Grease port from top face downwards (Z+)
module grease_port() {
    translate([0, 0, block_H/2 - grease_port_depth/2])
        cylinder(h=grease_port_depth + overlap, r=grease_port_d/2, center=true);
}

// Shallow bearing relief pocket on the top face centered over the bore
module bearing_relief_pocket() {
    translate([0, 0, block_H/2 - bearing_relief_depth/2])
        cylinder(h=bearing_relief_depth + overlap, r=bearing_relief_d/2, center=true);
}

module subtractive_features() {
    shaft_bore();
    bore_chamfers();

    x1 = -block_L/2 + mount_hole_edge_margin_L;
    x2 =  block_L/2 - mount_hole_edge_margin_L;
    y1 = -block_W/2 + mount_hole_edge_margin_W;
    y2 =  block_W/2 - mount_hole_edge_margin_W;

    mount_hole_at(x1, y1);
    mount_hole_at(x2, y1);
    mount_hole_at(x1, y2);
    mount_hole_at(x2, y2);

    if (counterbore_depth > 0) {
        counterbore_at(x1, y1);
        counterbore_at(x2, y1);
        counterbore_at(x1, y2);
        counterbore_at(x2, y2);
    }

    if (grease_port_depth > 0)
        grease_port();

    if (bearing_relief_depth > 0)
        bearing_relief_pocket();
}

// --- Main body (fast rounded outer edges via 2D offset) ---
module outer_block() {
    r = clamp(edge_fillet_r, 0, min(block_L, block_W)/2 - 0.01);

    if (r <= 0) {
        cube([block_L, block_W, block_H], center=true);
    } else {
        // Rounded vertical edges only (no expensive 3D fillets)
        linear_extrude(height=block_H, center=true, convexity=10)
            offset(r=r)
                square([block_L - 2*r, block_W - 2*r], center=true);
    }
}

// Final (one connected solid)
difference() {
    outer_block();
    subtractive_features();
}