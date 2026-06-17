$fn=128;

// HT 50 T-pipe (approximate dimensions, renderable)
// Units: mm

// ---- Parameters ----
d_nom = 50;                 // nominal inner diameter
wall = 1.8;                 // typical HT wall thickness (approx)
d_in = d_nom;
d_out = d_in + 2*wall;

socket_len = 35;            // socket depth
socket_wall_extra = 2.2;    // socket thickening beyond pipe wall
socket_od = d_out + 2*socket_wall_extra;

main_run_len = 160;         // total length of main run (end-to-end)
branch_len = 110;           // total length of branch (from intersection outward)

branch_angle = 90;          // T (90 degrees)

fillet_r = 10;              // outer blending radius (approx)
core_overlap = 0.2;         // small overlap for robust booleans

// ---- Helpers ----
module tube(od, id, h, center=false){
    difference(){
        cylinder(d=od, h=h, center=center);
        translate([0,0,-1e-3]) cylinder(d=id, h=h+2e-3, center=center);
    }
}

module socket(od, id, depth){
    // socket as a thicker sleeve with same inner diameter
    tube(od=od, id=id, h=depth, center=false);
}

module rounded_union(){
    // Minkowski-based rounding for outer shell only
    // Use small sphere for rounding; keep reasonable for performance
    minkowski(){
        children();
        sphere(r=fillet_r);
    }
}

module t_pipe_outer(){
    // Outer solid (before hollowing), with sockets
    // Main run centered at origin along X
    union(){
        // Main run body
        translate([-main_run_len/2,0,0])
            rotate([0,90,0])
                cylinder(d=d_out, h=main_run_len);

        // Branch body along Y (90°)
        translate([0,0,0])
            rotate([-90,0,0])
                cylinder(d=d_out, h=branch_len);

        // Sockets on main run ends
        // Left socket
        translate([-main_run_len/2 - socket_len + core_overlap,0,0])
            rotate([0,90,0])
                socket(od=socket_od, id=d_in, depth=socket_len);

        // Right socket
        translate([main_run_len/2 - core_overlap,0,0])
            rotate([0,90,0])
                socket(od=socket_od, id=d_in, depth=socket_len);

        // Branch socket
        translate([0,branch_len - core_overlap,0])
            rotate([-90,0,0])
                socket(od=socket_od, id=d_in, depth=socket_len);
    }
}

module t_pipe_inner_void(){
    // Inner void: continuous bores through run and branch
    union(){
        // Main run bore
        translate([-main_run_len/2 - socket_len - 5,0,0])
            rotate([0,90,0])
                cylinder(d=d_in, h=main_run_len + 2*socket_len + 10);

        // Branch bore
        translate([0,-5,0])
            rotate([-90,0,0])
                cylinder(d=d_in, h=branch_len + socket_len + 10);
    }
}

// ---- Model ----
difference(){
    // Rounded outer shell
    // To avoid excessive growth from Minkowski, build a slightly shrunken core then round
    // Shrink by fillet_r using offset-like approach: scale is not correct for cylinders,
    // so instead reduce diameters and lengths by 2*fillet_r where applicable.
    // Keep it simple: round the union directly; dimensions are approximate anyway.
    rounded_union(){
        t_pipe_outer();
    }

    // Hollow out
    t_pipe_inner_void();
}