$fn = 64;

// Miniature linear guide rail (profiled) — 12mm W x 8mm H x 100mm L

// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width  = 12.0;  //[6.0:24.0:0.5]
rail_height = 8.0;   //[4.0:16.0:0.5]

hole_d = 3.0;        //[1.5:6.0:0.1]
hole_spacing = 25.0; //[10.0:60.0:0.5]
hole_end_offset = 12.5; //[6.0:30.0:0.5]
hole_count = 4;      //[2:8:1]

edge_chamfer = 0.8;  //[0.3:2.0:0.1]
end_chamfer  = 1.0;  //[0.3:3.0:0.1]

overlap = 0.6;       //[0.2:2.0:0.1]

// Profile details (kept within 12x8 envelope)
top_flat_w = 6.0;    // top land width
side_step_h = 1.2;   // height of side step from bottom
side_step_in = 1.2;  // inset of side step from outer width

race_r = 1.1;        // raceway groove radius
race_depth = 0.55;   // how far groove cuts into side
race_z = 5.2;        // groove center height from bottom (0..rail_height)

function clamp(v, lo, hi) = min(max(v, lo), hi);

// Derived / clamped to ensure valid geometry
top_flat_w_c = clamp(top_flat_w, 0.5, rail_width - 2*edge_chamfer - 0.2);
side_step_h_c = clamp(side_step_h, 0.2, rail_height - 0.8);
side_step_in_c = clamp(side_step_in, 0.2, rail_width/2 - top_flat_w_c/2 - 0.2);

race_r_c = clamp(race_r, 0.4, 2.5);
race_depth_c = clamp(race_depth, 0.1, rail_width/2 - 0.6);
race_z_c = clamp(race_z, race_r_c + 0.4, rail_height - race_r_c - 0.4);

// 2D cross-section (X-Z), extruded along Y
module rail_profile_2d() {
    // Symmetric stepped profile with a top land
    // Points go CCW
    w = rail_width;
    h = rail_height;

    x0 = -w/2;
    x1 = -w/2 + side_step_in_c;
    x2 = -top_flat_w_c/2;
    x3 =  top_flat_w_c/2;
    x4 =  w/2 - side_step_in_c;
    x5 =  w/2;

    z0 = 0;
    z1 = side_step_h_c;
    z2 = h;

    polygon(points=[
        [x0, z0],
        [x5, z0],
        [x5, z1],
        [x4, z1],
        [x3, z2],
        [x2, z2],
        [x1, z1],
        [x0, z1]
    ]);
}

// Main rail solid (before cuts)
module rail_solid() {
    // Extrude along Y so length is rail_length
    rotate([90,0,0])  // make extrusion axis = Y
        linear_extrude(height=rail_length, center=true, convexity=10)
            rail_profile_2d();
}

// Mounting holes (through height, along Z)
module mounting_holes() {
    for (i = [0:hole_count-1]) {
        y = -rail_length/2 + hole_end_offset + i*hole_spacing;
        translate([0, y, 0])
            cylinder(h=rail_height + 2*overlap, r=hole_d/2, center=true);
    }
}

// Raceway grooves (two side grooves running full length)
module raceway_grooves() {
    // Place groove cylinders so they cut into the sides by race_depth_c
    // Cylinder axis along Y (length direction)
    groove_len = rail_length + 2*overlap;

    // Left groove
    translate([-(rail_width/2 - race_depth_c), 0, -rail_height/2 + race_z_c])
        rotate([90,0,0])
            cylinder(h=groove_len, r=race_r_c, center=true);

    // Right groove
    translate([ (rail_width/2 - race_depth_c), 0, -rail_height/2 + race_z_c])
        rotate([90,0,0])
            cylinder(h=groove_len, r=race_r_c, center=true);
}

// Chamfer cuts using long rotated cubes (kept connected; only subtract)
module edge_chamfer_cuts() {
    // Along Y, at 4 vertical edges of the bounding box
    L = rail_length + 2*overlap;
    c = edge_chamfer;

    // Top edges
    translate([ rail_width/2 - c, 0,  rail_height/2 - c])
        rotate([0,45,0]) cube([2*c, L, 2*c], center=true);
    translate([-rail_width/2 + c, 0,  rail_height/2 - c])
        rotate([0,45,0]) cube([2*c, L, 2*c], center=true);

    // Bottom edges
    translate([ rail_width/2 - c, 0, -rail_height/2 + c])
        rotate([0,45,0]) cube([2*c, L, 2*c], center=true);
    translate([-rail_width/2 + c, 0, -rail_height/2 + c])
        rotate([0,45,0]) cube([2*c, L, 2*c], center=true);
}

module end_chamfer_cuts() {
    // Chamfer the ends (at +/-Y)
    c = end_chamfer;
    W = rail_width + 2*overlap;
    H = rail_height + 2*overlap;

    translate([0,  rail_length/2 - c, 0])
        rotate([45,0,0]) cube([W, 2*c, H], center=true);

    translate([0, -rail_length/2 + c, 0])
        rotate([45,0,0]) cube([W, 2*c, H], center=true);
}

module rail() {
    difference() {
        rail_solid();
        mounting_holes();
        raceway_grooves();
        edge_chamfer_cuts();
        end_chamfer_cuts();
    }
}

rail();