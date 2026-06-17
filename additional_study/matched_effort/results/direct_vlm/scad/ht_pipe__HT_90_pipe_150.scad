$fn = 128;

// HT 90° pipe, nominal 150 mm (approx. DN150)
// Simple parametric elbow: outer/inner diameters, bend radius, and socket ends.

dn = 150;                 // nominal diameter (mm)
wall = 4.5;               // wall thickness (mm) - typical-ish for HT
od = 160;                 // outer diameter (mm) - approximate for DN150 HT
id = od - 2*wall;         // inner diameter (mm)

bend_angle = 90;          // degrees
bend_radius = 225;        // centerline radius (mm) - typical long radius elbow
socket_len = 60;          // socket length at each end (mm)
socket_od = od + 8;       // socket outer diameter (mm)
socket_id = od + 0.6;     // socket inner diameter (mm) - clearance for spigot
chamfer = 2;              // small chamfer (mm)

module torus_segment(angle=90, R=200, r=10) {
    rotate_extrude(angle=angle, convexity=10)
        translate([R, 0, 0])
            circle(r=r);
}

module elbow_shell(angle=90, R=200, od=160, id=151) {
    difference() {
        torus_segment(angle=angle, R=R, r=od/2);
        torus_segment(angle=angle, R=R, r=id/2);
    }
}

module socket_end(od_socket, id_socket, od_pipe, id_pipe, len=60, chamfer=2) {
    // Socket is a short thickened sleeve with a slight lead-in chamfer.
    difference() {
        union() {
            cylinder(h=len, d=od_socket);
            // lead-in chamfer (outer)
            if (chamfer > 0)
                translate([0,0,0])
                    cylinder(h=chamfer, d1=od_socket, d2=od_socket-2*chamfer);
        }
        // bore for spigot (slightly larger than pipe OD)
        translate([0,0,-0.01])
            cylinder(h=len+0.02, d=id_socket);

        // ensure continuity with pipe wall (remove any overlap inside)
        translate([0,0,-0.01])
            cylinder(h=len+0.02, d=od_pipe);
    }
}

module spigot_stub(od_pipe, id_pipe, len=60, chamfer=2) {
    difference() {
        cylinder(h=len, d=od_pipe);
        translate([0,0,-0.01])
            cylinder(h=len+0.02, d=id_pipe);

        // small outer chamfer at end
        if (chamfer > 0)
            translate([0,0,len-chamfer])
                cylinder(h=chamfer+0.01, d1=od_pipe, d2=od_pipe-2*chamfer);
    }
}

module ht_90_elbow_dn150() {
    // Build elbow centered at origin with ends aligned to X and Y axes.
    // Torus segment lies in XY plane, swept around Z.
    // Start tangent along +X at angle 0, end tangent along +Y at angle 90.

    union() {
        // Main elbow
        elbow_shell(angle=bend_angle, R=bend_radius, od=od, id=id);

        // End A at angle 0: tangent along +Y? Actually at angle 0, centerline point is (R,0),
        // tangent is +Y. We'll attach socket along +Y.
        translate([bend_radius, 0, 0])
            rotate([90,0,0])  // align cylinder axis to +Y
                socket_end(socket_od, socket_id, od, id, socket_len, chamfer);

        // End B at angle 90: centerline point is (0,R), tangent is -X. Attach spigot along -X.
        translate([0, bend_radius, 0])
            rotate([0,90,0])  // align cylinder axis to +X, then we will flip
                rotate([0,0,180])
                    spigot_stub(od, id, socket_len, chamfer);
    }
}

ht_90_elbow_dn150();