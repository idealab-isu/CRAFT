$fn = 128;

// Parameters (mm)
pipe_length = 1500;                 //[750:3000:1]
outer_diameter = 90;                //[45:180:1]
wall_thickness = 3.2;               //[1.6:6.4:0.1]

// Typical HT socket/bell end (approx.)
socket_length = 70;                 //[35:140:1]
socket_outer_diameter = 98;         //[90:120:1]
socket_wall_extra = 1.2;            //[0.5:3:0.1]   // socket wall slightly thicker than pipe
stop_ring_length = 8;               //[4:20:1]      // internal stop ring length
stop_ring_radial = 2.0;             //[1:5:0.1]     // how much the bore tightens at the stop

// Edge details
lead_in_length = 12;                //[4:30:1]      // insertion lead-in inside socket
lead_in_radial = 1.5;               //[0.5:4:0.1]
spigot_chamfer_length = 2;          //[1:6:0.5]
spigot_chamfer_radial = 1.5;        //[0.5:4:0.1]

// Robust boolean overlap
overlap = 1;                        //[0.5:2:0.1]

// Derived
R_pipe_o = outer_diameter/2;
R_pipe_i = R_pipe_o - wall_thickness;

R_sock_o = socket_outer_diameter/2;
R_sock_i = R_pipe_i + socket_wall_extra;

z_min = -pipe_length/2;
z_max =  pipe_length/2;

// Socket placement: socket occupies the last socket_length at +Z end
z_sock_center = z_max - socket_length/2 + overlap/2;

// Spigot chamfer at -Z end (outer)
z_spigot_chamfer_center = z_min + spigot_chamfer_length/2 - overlap/2;

// Internal stop ring near the socket mouth (at the start of socket region)
z_stop_center = (z_max - socket_length) + stop_ring_length/2;

// Internal lead-in chamfer at socket mouth (+Z end)
z_leadin_center = z_max - lead_in_length/2;

module outer_solid() {
    union() {
        // Main pipe OD
        cylinder(h=pipe_length, r=R_pipe_o, center=true);

        // Socket/bell OD (connected, overlaps slightly)
        translate([0,0,z_sock_center])
            cylinder(h=socket_length + overlap, r=R_sock_o, center=true);
    }
}

module inner_void() {
    union() {
        // Main bore through entire length
        cylinder(h=pipe_length + 2*overlap, r=R_pipe_i, center=true);

        // Socket enlarged bore (so socket has thicker wall)
        translate([0,0,z_sock_center])
            cylinder(h=socket_length + 2*overlap, r=R_sock_i, center=true);

        // Internal stop ring: reduce bore locally (creates shoulder)
        translate([0,0,z_stop_center])
            cylinder(h=stop_ring_length + 2*overlap, r=R_sock_i - stop_ring_radial, center=true);

        // Lead-in at socket mouth: flare from socket bore to slightly larger at the mouth
        translate([0,0,z_leadin_center])
            cylinder(h=lead_in_length + 2*overlap,
                     r1=R_sock_i + lead_in_radial,
                     r2=R_sock_i,
                     center=true);
    }
}

module spigot_outer_chamfer_cut() {
    // Cut a small outer chamfer at the spigot end (-Z)
    translate([0,0,z_spigot_chamfer_center])
        cylinder(h=spigot_chamfer_length + 2*overlap,
                 r1=R_pipe_o + spigot_chamfer_radial,
                 r2=R_pipe_o,
                 center=true);
}

module final_pipe_model() {
    difference() {
        // Outer connected solid
        outer_solid();

        // Hollowing + socket internal features
        inner_void();

        // Outer spigot chamfer
        spigot_outer_chamfer_cut();
    }
}

color("Silver") final_pipe_model();