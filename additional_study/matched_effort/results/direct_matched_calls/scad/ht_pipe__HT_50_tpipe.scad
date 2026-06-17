$fn=128;

// HT 50 T-pipe (approximate dimensions, renderable)
// Units: mm

// ---- Parameters ----
od_main = 50;          // outer diameter of main pipe
wall = 1.8;            // wall thickness
id_main = od_main - 2*wall;

socket_od = 56;        // outer diameter of sockets (slightly larger)
socket_wall = 2.2;
socket_id = socket_od - 2*socket_wall;

run_socket_len = 35;   // socket length on each end of run
run_body_len = 40;     // straight body length between sockets (center section)

branch_socket_len = 35; // socket length on branch
branch_body_len = 20;   // body length from run OD to branch socket start

fillet_r = 6;          // blending radius at intersection (approx)

// ---- Helpers ----
module pipe_segment(od, id, h) {
    difference() {
        cylinder(d=od, h=h);
        translate([0,0,-0.2]) cylinder(d=id, h=h+0.4);
    }
}

module socket_segment(od, id, h, leadin=2) {
    // simple socket with slight lead-in chamfer
    difference() {
        union() {
            cylinder(d=od, h=h);
            // outer chamfer
            translate([0,0,0]) cylinder(d1=od, d2=od-2*leadin, h=leadin);
        }
        union() {
            translate([0,0,-0.2]) cylinder(d=id, h=h+0.4);
            // inner lead-in
            translate([0,0,0]) cylinder(d1=id+2*leadin, d2=id, h=leadin);
        }
    }
}

module t_body_solid() {
    // Run: left socket + body + right socket
    run_total = run_socket_len + run_body_len + run_socket_len;

    // Place run along X axis, centered at origin
    rotate([0,90,0]) translate([0,0,-run_total/2]) union() {
        // left socket
        socket_segment(socket_od, socket_id, run_socket_len);
        // run body
        translate([0,0,run_socket_len]) cylinder(d=od_main, h=run_body_len);
        // right socket
        translate([0,0,run_socket_len+run_body_len]) socket_segment(socket_od, socket_id, run_socket_len);
    }

    // Branch: from top of run (Y+) along Y axis
    // Start branch at run outer surface (approx), then body, then socket
    translate([0, od_main/2 - fillet_r/2, 0]) rotate([-90,0,0]) union() {
        // short body from intersection to socket
        cylinder(d=od_main, h=branch_body_len);
        translate([0,0,branch_body_len]) socket_segment(socket_od, socket_id, branch_socket_len);
    }

    // Blend lump at intersection (approximate fillet)
    hull() {
        // small cylinders around intersection to create a smooth-ish blend
        rotate([0,90,0]) cylinder(d=od_main, h=fillet_r, center=true);
        translate([0, od_main/2 - fillet_r/2, 0]) rotate([-90,0,0]) cylinder(d=od_main, h=fillet_r, center=true);
    }
}

module t_body_hollow() {
    // Hollow out run and branch with internal bores
    run_total = run_socket_len + run_body_len + run_socket_len;

    // Run bore
    rotate([0,90,0]) translate([0,0,-run_total/2 - 1]) cylinder(d=id_main, h=run_total+2);

    // Branch bore
    translate([0, od_main/2 - fillet_r/2, 0]) rotate([-90,0,0]) translate([0,0,-1])
        cylinder(d=id_main, h=branch_body_len + branch_socket_len + 2);

    // Slightly larger bore inside sockets (to match socket_id)
    // Run sockets
    rotate([0,90,0]) translate([0,0,-run_total/2 - 1]) cylinder(d=socket_id, h=run_socket_len+2);
    rotate([0,90,0]) translate([0,0,run_total/2 - run_socket_len - 1]) cylinder(d=socket_id, h=run_socket_len+2);

    // Branch socket
    translate([0, od_main/2 - fillet_r/2, 0]) rotate([-90,0,0]) translate([0,0,branch_body_len - 1])
        cylinder(d=socket_id, h=branch_socket_len+2);
}

// ---- Model ----
difference() {
    t_body_solid();
    t_body_hollow();
}