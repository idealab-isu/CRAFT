// HT pipe: HT 32, length 1500 mm
// Aligned along Z so front/back/left/right show the pipe length.

$fn = 128;

// Parameters
pipe_length = 1500;          //[750:3000:10]
outer_diameter = 32;         //[16:64:1]
wall_thickness = 2;          //[1:4:0.1]
socket_length = 50;          //[25:100:1]
socket_wall_extra = 1.5;     //[0.5:3:0.1]
chamfer_length = 2;          //[1:6:0.5]
overlap = 1;                 //[0.5:2:0.1]

// Derived
outer_r = outer_diameter/2;
inner_r = max(outer_r - wall_thickness, 0.01);
socket_outer_r = outer_r + socket_wall_extra;

// Z positions (formulas, no arbitrary offsets)
z_main_center   = 0;
z_socket_center = pipe_length/2 - socket_length/2 + overlap/2;

// Connected outer shell (main + socket)
module outer_shell() {
    union() {
        cylinder(h=pipe_length, r=outer_r, center=true);

        // Socket sleeve on +Z end, overlapping into main by "overlap"
        translate([0, 0, z_socket_center])
            cylinder(h=socket_length + overlap, r=socket_outer_r, center=true);
    }
}

// Inner bore (through entire part, including socket)
module inner_bore() {
    cylinder(h=pipe_length + socket_length + 4*overlap, r=inner_r, center=true);
}

// Subtractive chamfers (true chamfer via truncated cones)
module chamfers() {
    // Spigot end (-Z): outer chamfer from outer_r down to (outer_r - chamfer_length)
    translate([0, 0, -pipe_length/2 + chamfer_length/2])
        cylinder(h=chamfer_length + overlap, r1=outer_r, r2=max(outer_r - chamfer_length, 0.01), center=true);

    // Socket end (+Z): outer chamfer on socket OD
    translate([0, 0, pipe_length/2 - chamfer_length/2])
        cylinder(h=chamfer_length + overlap, r1=socket_outer_r, r2=max(socket_outer_r - chamfer_length, 0.01), center=true);
}

// Final solid (one connected body)
difference() {
    outer_shell();
    inner_bore();
    chamfers();
}