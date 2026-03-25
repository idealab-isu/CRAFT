// Flanged ball bearing (single connected solid, no clipping/cutaway)
// Target dims: 3.0mm bore, 8.0mm OD, 3.0mm width, 9.5mm flange OD

$fn = 160;

// Parameters
bore_diameter_mm = 3.0;                 //[1.5:6.0:0.1]
outer_diameter_mm = 8.0;                //[4.0:16.0:0.1]
width_mm = 3.0;                         //[1.5:6.0:0.1]
flange_outer_diameter_mm = 9.5;         //[6.0:19.0:0.1]
flange_width_mm = 0.6;                  //[0.3:1.2:0.05]

// Visual/internal features (kept within envelope)
outer_race_rim_thickness_mm = 0.8;      //[0.4:1.6:0.05]
inner_race_hub_thickness_mm = 0.9;      //[0.45:1.8:0.05]
race_chamfer_mm = 0.25;                 //[0.1:0.6:0.05]
ball_diameter_mm = 1.2;                 //[0.6:2.4:0.05]
num_balls = 8;                          //[5:14:1]
cage_thickness_mm = 0.35;               //[0.2:0.8:0.05]

// Cutaway disabled to avoid missing quadrants/sections
cutaway_angle_deg = 0;                  //[0:180:1]  // 0 = no cutaway

eps = 0.02;

// Derived radii
R_bore   = bore_diameter_mm/2;
R_outer  = outer_diameter_mm/2;
R_flange = flange_outer_diameter_mm/2;

R_outer_inner = R_outer - outer_race_rim_thickness_mm;
R_inner_outer = R_bore + inner_race_hub_thickness_mm;

R_ball = ball_diameter_mm/2;

// Ball path radius (auto-fit between races)
function clamp(x, a, b) = min(max(x, a), b);
R_ball_center_nom = (R_outer_inner + R_inner_outer)/2;
R_ball_center = clamp(R_ball_center_nom,
                      R_inner_outer + R_ball + 0.08,
                      R_outer_inner - R_ball - 0.08);

// Groove size (visual)
groove_r = ball_diameter_mm * 0.52;

// Axial positions (flange on one face, connected with overlap)
overlap_mm = 0.15;
z_flange = -width_mm/2 + flange_width_mm/2;

// --- Helpers ---
module chamfered_ring(r_out, r_in, h, chamfer) {
    // Ring with simple outer chamfers (kept within r_out)
    difference() {
        union() {
            cylinder(r=r_out, h=h, center=true);

            // outer chamfers (top/bottom)
            translate([0,0, h/2 - chamfer/2])
                cylinder(r1=r_out, r2=r_out - chamfer, h=chamfer, center=true);
            translate([0,0,-h/2 + chamfer/2])
                cylinder(r1=r_out, r2=r_out - chamfer, h=chamfer, center=true);
        }
        cylinder(r=r_in, h=h + 2*eps, center=true);
    }
}

module race_groove_cut(r_center, z_center=0) {
    // Toroidal groove approximation
    translate([0,0,z_center])
        rotate_extrude(angle=360, convexity=10)
            translate([r_center, 0, 0])
                circle(r=groove_r, $fn=96);
}

module balls() {
    for (i=[0:num_balls-1]) {
        rotate([0,0,i*360/num_balls])
            translate([R_ball_center, 0, 0])
                sphere(r=R_ball, $fn=64);
    }
}

module cage_ring() {
    // Thin cage ring with ball pockets (visual)
    r_cage_mid = R_ball_center;
    r_cage_out = min(R_outer_inner - 0.10, r_cage_mid + R_ball + cage_thickness_mm);
    r_cage_in  = max(R_inner_outer + 0.10, r_cage_mid - R_ball - cage_thickness_mm);

    h_cage = min(width_mm - 0.50, ball_diameter_mm + 0.25);
    h_cage_ok = max(0.45, h_cage);

    difference() {
        cylinder(r=r_cage_out, h=h_cage_ok, center=true);
        cylinder(r=r_cage_in,  h=h_cage_ok + 2*eps, center=true);

        // pockets for balls
        for (i=[0:num_balls-1]) {
            rotate([0,0,i*360/num_balls])
                translate([R_ball_center, 0, 0])
                    cylinder(r=R_ball*1.06, h=h_cage_ok + 2*eps, center=true);
        }
    }
}

// --- Main solid ---
module flanged_bearing_solid() {
    difference() {
        union() {
            // Outer race body (OD = 8, width = 3)
            chamfered_ring(R_outer, R_outer_inner, width_mm, race_chamfer_mm);

            // Flange (OD = 9.5, thickness = flange_width), connected with overlap
            translate([0,0,z_flange])
                cylinder(r=R_flange, h=flange_width_mm + overlap_mm, center=true);

            // Inner race (around bore)
            chamfered_ring(R_inner_outer, R_bore, width_mm, race_chamfer_mm);

            // Balls + cage (kept inside envelope)
            balls();
            cage_ring();
        }

        // Bore hole (ID = 3.0) through entire part
        cylinder(r=R_bore, h=width_mm + flange_width_mm + 6, center=true);

        // Ball grooves (cut into both races for visual realism)
        race_groove_cut(R_ball_center, 0);
    }
}

flanged_bearing_solid();