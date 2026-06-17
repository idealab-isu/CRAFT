// Aluminium tooling plate (single connected solid with tooling features)
// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200;  //[100:400:1]
plate_thickness = 10; //[5:20:1]
edge_chamfer_size = 2; //[0:5:1]
corner_radius_value = 8; //[0:20:1]
surface_finish_depth = 0.3; //[0:1:0.1]
engraved_label_depth = 0; //[0:1:0.1]  // kept but unused (no text allowed)

$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_plate_2d(L, W, R){
    R2 = clamp(R, 0, min(L, W)/2);
    if (R2 <= 0)
        square([L, W], center=true);
    else
        offset(r=R2) offset(delta=-R2) square([L, W], center=true);
}

module chamfered_extrude(h, c){
    // Creates a plate with a 45° chamfer around top and bottom edges
    c2 = clamp(c, 0, h/2 - 0.01);
    if (c2 <= 0){
        linear_extrude(height=h, center=true) children();
    } else {
        union(){
            // Middle straight section
            linear_extrude(height=h - 2*c2, center=true) children();

            // Top chamfer
            translate([0,0,(h - 2*c2)/2])
                linear_extrude(height=c2, center=false, scale=0.98)
                    children();

            // Bottom chamfer
            translate([0,0,-(h - 2*c2)/2 - c2])
                linear_extrude(height=c2, center=false, scale=0.98)
                    children();
        }
    }
}

module tooling_plate(){
    L = plate_length;
    W = plate_width;
    T = plate_thickness;

    // Feature sizing derived from dimensions (no arbitrary placement)
    margin = max(12, min(L, W)*0.06);
    hole_d = max(6, min(L, W)*0.04);
    cbore_d = hole_d * 1.8;
    cbore_depth = min(T*0.45, hole_d*0.6);

    // Grid holes (tooling-plate look)
    pitch = max(40, min(L, W)*0.25);
    nx = max(2, floor((L - 2*margin)/pitch) + 1);
    ny = max(2, floor((W - 2*margin)/pitch) + 1);

    // Surface finish shallow pockets (non-through) to add visible detail
    pocket_depth = clamp(surface_finish_depth, 0, T*0.25);
    pocket_margin = margin*0.6;
    pocket_w = max(10, W - 2*pocket_margin);
    pocket_l = max(10, L - 2*pocket_margin);
    pocket_r = clamp(corner_radius_value*0.5, 0, min(pocket_l, pocket_w)/4);

    color([0.75,0.75,0.78])  // aluminium-like
    difference(){
        // Base plate with rounded corners and optional chamfer
        chamfered_extrude(T, edge_chamfer_size)
            rounded_plate_2d(L, W, corner_radius_value);

        // Through holes + counterbores on top face
        for (ix = [0:nx-1])
            for (iy = [0:ny-1]){
                x = -L/2 + margin + (nx==1 ? 0 : ix*(L - 2*margin)/(nx-1));
                y = -W/2 + margin + (ny==1 ? 0 : iy*(W - 2*margin)/(ny-1));

                // Through hole
                translate([x, y, 0])
                    cylinder(h=T + 0.2, d=hole_d, center=true);

                // Counterbore from top (connected subtraction)
                translate([x, y, T/2 - cbore_depth/2 + 0.01])
                    cylinder(h=cbore_depth + 0.02, d=cbore_d, center=true);
            }

        // Shallow surface pockets (top face) to suggest tooling plate finish
        if (pocket_depth > 0){
            translate([0,0, T/2 - pocket_depth/2 + 0.01])
                linear_extrude(height=pocket_depth + 0.02, center=true)
                    offset(r=pocket_r) offset(delta=-pocket_r)
                        square([pocket_l, pocket_w], center=true);

            // Two shallow grooves (top face), positioned by formulas
            groove_w = max(2, min(L, W)*0.01);
            groove_depth = min(pocket_depth, T*0.15);
            gx = (L/2 - margin) * 0.35;
            translate([ gx, 0, T/2 - groove_depth/2 + 0.01])
                cube([groove_w, W - 2*margin, groove_depth + 0.02], center=true);
            translate([-gx, 0, T/2 - groove_depth/2 + 0.01])
                cube([groove_w, W - 2*margin, groove_depth + 0.02], center=true);
        }
    }
}

// Build
tooling_plate();