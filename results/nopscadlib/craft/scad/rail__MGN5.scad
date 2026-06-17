// Miniature linear guide rail (render-friendly)
// Target overall size: 5.0mm wide (X) x 3.6mm tall (Z) x 100mm long (Y)

$fn = 48;

// Parameters
rail_length = 100; //[50:200:1]
rail_width  = 5.0; //[2.5:10:0.1]
rail_height = 3.6; //[1.8:7.2:0.1]

// Mounting holes (counterbored like many miniature rails)
hole_diameter = 2.2; //[1.2:4:0.1]
counterbore_diameter = 3.6; //[2.5:5:0.1]
counterbore_depth = 0.9; //[0.3:1.6:0.05]
num_holes = 4; //[2:10:1]
end_margin = 10; //[5:25:1]

// Linear guide features (raceways/grooves along length)
raceway_depth = 0.55; //[0.2:1.2:0.05]
raceway_radius = 0.85; //[0.4:1.4:0.05]

// Small top relief groove (visual cue)
top_relief_width  = 0.8;  //[0.3:1.6:0.05]
top_relief_depth  = 0.25; //[0.1:0.8:0.05]

// End chamfers
chamfer_depth_y = 1.0;   //[0.5:3:0.1]
chamfer_inset_x = 0.6;   //[0.3:1.5:0.1]
chamfer_inset_z = 0.6;   //[0.3:1.5:0.1]

// Robustness
eps = 0.02;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Clamp feature sizes to fit
cb_d     = clamp(counterbore_diameter, hole_diameter + 0.2, rail_width - 0.2);
cb_depth = clamp(counterbore_depth, 0, rail_height - 0.4);

rw_r = clamp(raceway_radius, 0.25, min(rail_width/2 - 0.35, rail_height/2 - 0.25));
rw_d = clamp(raceway_depth, 0.05, rw_r);

tr_w = clamp(top_relief_width, 0.2, rail_width - 0.4);
tr_d = clamp(top_relief_depth, 0.05, rail_height/2 - 0.2);

module rail_body() {
    cube([rail_width, rail_length, rail_height], center=true);
}

module mounting_holes() {
    hole_h = rail_height + 4*eps;

    for (i = [0:num_holes-1]) {
        y = (num_holes == 1)
            ? 0
            : (-rail_length/2 + end_margin) + (rail_length - 2*end_margin) * (i/(num_holes-1));

        // Through hole
        translate([0, y, 0])
            cylinder(h=hole_h, r=hole_diameter/2, center=true);

        // Counterbore pocket from top face
        translate([0, y, rail_height/2 - cb_depth/2 + eps])
            cylinder(h=cb_depth + 2*eps, r=cb_d/2, center=true);
    }
}

module end_chamfers() {
    // Cut small wedges at both ends, all four top/bottom corners
    module wedge() {
        linear_extrude(height=chamfer_depth_y + 2*eps, center=true)
            polygon(points=[
                [ rail_width/2 + eps,  rail_height/2 + eps],
                [ rail_width/2 - chamfer_inset_x, rail_height/2 + eps],
                [ rail_width/2 + eps,  rail_height/2 - chamfer_inset_z]
            ]);
    }

    for (s = [-1, 1]) { // ends along Y
        translate([0, s*(rail_length/2 - chamfer_depth_y/2), 0])
            for (a = [0, 90, 180, 270])
                rotate([0, 0, a]) wedge();
    }
}

module top_relief() {
    translate([0, 0, rail_height/2 - tr_d/2])
        cube([tr_w, rail_length + 2*eps, tr_d + 2*eps], center=true);
}

module raceways() {
    // Two longitudinal concave raceways on the side faces (cut as long cylinders along Y)
    // Side face at x = ±rail_width/2. For a cylinder of radius rw_r, to get depth rw_d:
    // center_x = face_x - (rw_r - rw_d)
    cx = rail_width/2 - (rw_r - rw_d);

    for (sx = [-1, 1]) {
        translate([sx*cx, 0, 0])
            rotate([90, 0, 0])  // axis along Y
                cylinder(h=rail_length + 4*eps, r=rw_r, center=true);
    }

    // Subtle lower raceways
    cz2 = -rail_height*0.22;
    for (sx = [-1, 1]) {
        translate([sx*cx, 0, cz2])
            rotate([90, 0, 0])
                cylinder(h=rail_length + 4*eps, r=rw_r*0.85, center=true);
    }
}

difference() {
    rail_body();
    mounting_holes();
    end_chamfers();
    top_relief();
    raceways();
}