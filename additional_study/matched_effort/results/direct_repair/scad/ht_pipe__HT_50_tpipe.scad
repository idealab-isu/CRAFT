$fn=128;

// HT 50 T-pipe (approximate dimensions)
// Main run: DN50 (OD 50mm), socket ends
// Branch: DN50 (OD 50mm), socket end
// Includes simple socket lips and internal bore

// ---------- Parameters ----------
od = 50;                 // outer diameter of pipe
wall = 1.8;              // wall thickness
id = od - 2*wall;        // inner diameter

run_len = 160;           // overall length of main run (end to end)
branch_len = 90;         // overall length of branch (from centerline outward)

socket_len = 35;         // socket depth
socket_od = 56;          // socket outer diameter (slightly larger)
socket_id = od + 0.6;    // socket inner diameter (clearance for spigot)
lip_len = 3;             // small lip at socket mouth
lip_od = socket_od + 2;  // lip outer diameter

center_bulge_len = 40;   // length of central body around intersection
center_bulge_od = 60;    // outer diameter of central body

// ---------- Helpers ----------
module tube(len, od_, id_) {
    difference() {
        cylinder(h=len, d=od_, center=true);
        cylinder(h=len+0.2, d=id_, center=true);
    }
}

module socket_along_x(sign=1) {
    // sign: +1 right end, -1 left end
    translate([sign*(run_len/2 - socket_len/2), 0, 0])
        rotate([0,90,0])
            tube(socket_len, socket_od, socket_id);

    // lip
    translate([sign*(run_len/2 - lip_len/2), 0, 0])
        rotate([0,90,0])
            tube(lip_len, lip_od, socket_id);
}

module socket_along_y() {
    translate([0, branch_len/2 - socket_len/2, 0])
        rotate([-90,0,0])
            tube(socket_len, socket_od, socket_id);

    translate([0, branch_len/2 - lip_len/2, 0])
        rotate([-90,0,0])
            tube(lip_len, lip_od, socket_id);
}

// ---------- Model ----------
difference() {
    union() {
        // Main run pipe body (spigot section between sockets)
        rotate([0,90,0])
            tube(run_len - 2*socket_len, od, id);

        // Branch pipe body (spigot section between center and socket)
        translate([0, (branch_len - socket_len)/2, 0])
            rotate([-90,0,0])
                tube(branch_len - socket_len, od, id);

        // Central bulge body
        tube(center_bulge_len, center_bulge_od, id);

        // Sockets on main run ends
        socket_along_x(+1);
        socket_along_x(-1);

        // Socket on branch end
        socket_along_y();
    }

    // Ensure continuous internal bore through intersection (carve a smooth cross)
    union() {
        // Main bore
        rotate([0,90,0])
            cylinder(h=run_len + 2, d=id, center=true);

        // Branch bore
        translate([0, branch_len/2, 0])
            rotate([-90,0,0])
                cylinder(h=branch_len + 2, d=id, center=true);

        // Slightly larger blending cavity at center to avoid thin artifacts
        sphere(d=id + 2);
    }
}