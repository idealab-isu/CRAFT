// Miniature linear guide rail (profiled) - 12mm W x 8mm H x 100mm L
// One connected solid with mounting holes + countersinks + raceway grooves

$fn = 64;

// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width  = 12.0;  //[6.0:24.0:0.5]
rail_height = 8.0;   //[4.0:16.0:0.5]

mount_hole_diameter = 3.4; //[2.0:6.0:0.1]
mount_hole_count    = 4;   //[2:8:1]
end_margin          = 12.0;//[6.0:24.0:0.5]

edge_chamfer = 0.8; //[0.3:2.0:0.1]
end_chamfer  = 1.0; //[0.5:3.0:0.1]
cut_overlap  = 1.0; //[0.5:2.0:0.1]

// Rail feature parameters (kept proportional; do not change overall W/H/L)
raceway_r = min(1.2, rail_height*0.18);                 // groove radius
raceway_depth = min(0.7, rail_width*0.08);              // groove depth into side
raceway_z = rail_height*0.18;                           // vertical offset from center
top_relief_w = rail_width*0.42;                         // top center relief width
top_relief_d = min(0.6, rail_height*0.10);              // top relief depth
bottom_relief_w = rail_width*0.55;                      // bottom center relief width
bottom_relief_d = min(0.5, rail_height*0.09);           // bottom relief depth

// Countersink (simple conical) for mounting holes
csk_d_top = mount_hole_diameter + 3.0;                  // top diameter
csk_depth = min(2.0, rail_height*0.35);                 // depth from top surface

// Helpers
function clamp(v, lo, hi) = max(lo, min(hi, v));

module rail_body_profiled() {
    // Base block (exact overall dimensions)
    cube([rail_length, rail_width, rail_height], center=true);
}

module mount_hole_cutter() {
    cylinder(h=rail_height + 2*cut_overlap, r=mount_hole_diameter/2, center=true);
}

module countersink_cutter() {
    // Cone from top surface downwards
    // Place so its top is slightly above the top face to guarantee clean subtraction
    translate([0, 0, rail_height/2 - csk_depth/2 + cut_overlap/2])
        cylinder(h=csk_depth + cut_overlap, r1=csk_d_top/2, r2=mount_hole_diameter/2, center=true);
}

module mounting_holes_and_csk() {
    // Evenly spaced holes between end margins
    spacing = (rail_length - 2*end_margin) / (mount_hole_count - 1);
    for (i = [0:mount_hole_count-1]) {
        x = -rail_length/2 + end_margin + i*spacing;
        translate([x, 0, 0]) {
            mount_hole_cutter();
            countersink_cutter();
        }
    }
}

module edge_chamfer_cutter() {
    // Cut small 45-ish chamfers by removing corner strips
    union() {
        // Along Y edges, top and bottom
        translate([0,  rail_width/2 - edge_chamfer/2,  rail_height/2 - edge_chamfer/2])
            cube([rail_length + 2*cut_overlap, edge_chamfer, edge_chamfer], center=true);
        translate([0,  rail_width/2 - edge_chamfer/2, -rail_height/2 + edge_chamfer/2])
            cube([rail_length + 2*cut_overlap, edge_chamfer, edge_chamfer], center=true);
        translate([0, -rail_width/2 + edge_chamfer/2,  rail_height/2 - edge_chamfer/2])
            cube([rail_length + 2*cut_overlap, edge_chamfer, edge_chamfer], center=true);
        translate([0, -rail_width/2 + edge_chamfer/2, -rail_height/2 + edge_chamfer/2])
            cube([rail_length + 2*cut_overlap, edge_chamfer, edge_chamfer], center=true);

        // Along X ends, top and bottom (small strips to soften ends)
        translate([ rail_length/2 - edge_chamfer/2, 0,  rail_height/2 - edge_chamfer/2])
            cube([edge_chamfer, rail_width + 2*cut_overlap, edge_chamfer], center=true);
        translate([ rail_length/2 - edge_chamfer/2, 0, -rail_height/2 + edge_chamfer/2])
            cube([edge_chamfer, rail_width + 2*cut_overlap, edge_chamfer], center=true);
        translate([-rail_length/2 + edge_chamfer/2, 0,  rail_height/2 - edge_chamfer/2])
            cube([edge_chamfer, rail_width + 2*cut_overlap, edge_chamfer], center=true);
        translate([-rail_length/2 + edge_chamfer/2, 0, -rail_height/2 + edge_chamfer/2])
            cube([edge_chamfer, rail_width + 2*cut_overlap, edge_chamfer], center=true);
    }
}

module end_chamfer_cutter() {
    // Remove small cubes at all 8 corners to mimic end chamfers
    union() {
        for (sx = [-1, 1], sy = [-1, 1], sz = [-1, 1]) {
            translate([sx*(rail_length/2 - end_chamfer/2),
                       sy*(rail_width/2  - end_chamfer/2),
                       sz*(rail_height/2 - end_chamfer/2)])
                cube([end_chamfer, end_chamfer, end_chamfer], center=true);
        }
    }
}

module raceway_grooves() {
    // Two longitudinal grooves on the side faces (approximate raceways)
    // Use cylinders along X, positioned so they cut into the side by raceway_depth.
    y_center = rail_width/2 - raceway_depth + raceway_r; // ensures groove intersects side face
    z1 =  raceway_z;
    z2 = -raceway_z;

    union() {
        for (sy = [-1, 1], zz = [z1, z2]) {
            translate([0, sy*y_center, zz])
                rotate([0, 90, 0])
                    cylinder(h=rail_length + 2*cut_overlap, r=raceway_r, center=true);
        }
    }
}

module top_bottom_reliefs() {
    // Small center reliefs to break up the rectangular look (still within 12x8 envelope)
    union() {
        // Top relief
        translate([0, 0, rail_height/2 - top_relief_d/2])
            cube([rail_length + 2*cut_overlap, top_relief_w, top_relief_d + cut_overlap], center=true);

        // Bottom relief
        translate([0, 0, -rail_height/2 + bottom_relief_d/2])
            cube([rail_length + 2*cut_overlap, bottom_relief_w, bottom_relief_d + cut_overlap], center=true);
    }
}

// Final Rail
color("Silver")
difference() {
    rail_body_profiled();

    // Functional features
    mounting_holes_and_csk();

    // Profile details
    raceway_grooves();
    top_bottom_reliefs();

    // Edge softening
    edge_chamfer_cutter();
    end_chamfer_cutter();
}