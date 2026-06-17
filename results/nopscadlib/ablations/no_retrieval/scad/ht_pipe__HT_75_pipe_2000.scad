// HT pipe: HT 75, length 2000 mm
// Model axis: X (length). This makes front/back/left/right show the long pipe consistently.

pipe_length = 2000; //[1000:4000:10]
outer_diameter = 75; //[50:150:1]
wall_thickness = 2.7; //[1.35:5.4:0.1]
socket_length = 60; //[30:120:1]
socket_wall_extra = 1.8; //[0.8:4:0.1]
socket_inner_clearance = 0.6; //[0.2:1.5:0.1]
chamfer_length = 2; //[1:6:0.5]
chamfer_radial = 1.5; //[0.5:4:0.5]
overlap = 1; //[0.5:2:0.5]

$fn = 128;

outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;

// Socket outer radius (thickened end)
socket_outer_r = outer_r + socket_wall_extra;

// Socket bore radius (slightly larger than pipe OD for insertion clearance)
socket_bore_r = outer_r + socket_inner_clearance/2;

// Positions along X
x_min = -pipe_length/2;
x_max =  pipe_length/2;

// Socket is on +X end
socket_center_x = x_max - socket_length/2 + overlap;

// Chamfers at both ends (simple conical cuts)
spigot_chamfer_center_x = x_min + chamfer_length/2 - overlap;
socket_chamfer_center_x = x_max - chamfer_length/2 + overlap;

module pipe_outer() {
    // Main pipe outer cylinder along X
    rotate([0, 90, 0])
        cylinder(h=pipe_length, r=outer_r, center=true);
}

module socket_outer() {
    // Outer thickened socket sleeve on +X end, connected with overlap
    translate([socket_center_x, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=socket_length, r=socket_outer_r, center=true);
}

module inner_bore() {
    // Through-bore for the whole pipe
    rotate([0, 90, 0])
        cylinder(h=pipe_length + 2*overlap, r=inner_r, center=true);
}

module socket_bore() {
    // Enlarged bore inside socket region
    translate([socket_center_x, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=socket_length + 2*overlap, r=socket_bore_r, center=true);
}

module chamfer_spigot_cut() {
    // Cut a small outer chamfer at -X end
    translate([spigot_chamfer_center_x, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=chamfer_length, r1=outer_r + chamfer_radial, r2=0, center=true);
}

module chamfer_socket_outer_cut() {
    // Cut a small outer chamfer at +X end (on socket OD)
    translate([socket_chamfer_center_x, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=chamfer_length, r1=socket_outer_r + chamfer_radial, r2=0, center=true);
}

module final_model() {
    difference() {
        union() {
            pipe_outer();
            socket_outer();
        }
        inner_bore();
        socket_bore();
        chamfer_spigot_cut();
        chamfer_socket_outer_cut();
    }
}

final_model();