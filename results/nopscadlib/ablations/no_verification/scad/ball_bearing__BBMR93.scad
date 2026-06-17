// Ball bearing (single connected solid) with visible races + balls
// Target dimensions: 3.0mm bore, 9.0mm outer diameter, 4.0mm width

bore_diameter_mm = 3.0;   //[1.5:6:0.1]
outer_diameter_mm = 9.0;  //[4.5:18:0.1]
width_mm = 4.0;           //[2:8:0.1]

race_radial_thickness_mm = 1.2;   //[0.6:2.4:0.05]
race_axial_margin_mm = 0.35;      //[0.15:0.8:0.05]

ball_diameter_mm = 1.2;           //[0.6:2.4:0.05]
ball_count = 8;                   //[5:14:1]

bridge_thickness_mm = 0.35;       //[0.2:0.8:0.05]  // web that keeps inner+outer races connected
overlap_mm = 0.15;                //[0.05:0.5:0.05]
eps_mm = 0.05;                    //[0.01:0.2:0.01]

$fn = 128;

module ball_bearing() {
    r_bore  = bore_diameter_mm/2;
    r_outer = outer_diameter_mm/2;

    // Keep races inside the ring
    r_inner_outer = r_bore + race_radial_thickness_mm;      // outer radius of inner race
    r_outer_inner = r_outer - race_radial_thickness_mm;     // inner radius of outer race

    // Ball path between races
    r_ball_center = (r_inner_outer + r_outer_inner)/2;

    // Axial extents
    h_race = max(0, width_mm - 2*race_axial_margin_mm);
    bridge_h = min(bridge_thickness_mm, max(0.2, h_race - 2*eps_mm));

    // Middle gap between races (radial)
    gap_r_inner = r_inner_outer + eps_mm;
    gap_r_outer = r_outer_inner - eps_mm;

    // Visual grooves (kept within material)
    groove_r = min(0.35, race_radial_thickness_mm*0.35);
    groove_z = min(0.30, max(0.15, h_race*0.22));

    // Ball pockets (shallow dimples so the part stays connected)
    pocket_r = ball_diameter_mm/2 + 0.08;
    pocket_depth = min(pocket_r*0.55, race_radial_thickness_mm*0.45);

    // Place pocket centers slightly into each race from the ball centerline
    r_pocket_outer = r_ball_center + (race_radial_thickness_mm/2 - pocket_depth/2);
    r_pocket_inner = r_ball_center - (race_radial_thickness_mm/2 - pocket_depth/2);

    color("DimGray")
    difference() {
        // Base ring: OD and width are exact
        cylinder(r=r_outer, h=width_mm, center=true);

        // Bore: ID is exact
        cylinder(r=r_bore, h=width_mm + 2*eps_mm, center=true);

        // Radial gap between races, but leave a central axial bridge so it's ONE connected solid.
        // Implemented as two annular cuts (top and bottom), leaving bridge at z=0.
        union() {
            for (zsgn = [-1, 1]) {
                translate([0, 0, zsgn*(bridge_h/2 + overlap_mm)])
                    difference() {
                        cylinder(r=gap_r_outer, h=width_mm - bridge_h + 2*eps_mm, center=true);
                        cylinder(r=gap_r_inner, h=width_mm - bridge_h + 4*eps_mm, center=true);
                    }
            }
        }

        // Race grooves (subtle, axial-positioned so they are visible in side view)
        // Outer race groove: cut into the inner face of the outer race
        for (zsgn = [-1, 1]) {
            translate([0, 0, zsgn*groove_z])
                rotate_extrude(angle=360)
                    translate([r_outer_inner + groove_r*0.55, 0, 0])
                        circle(r=groove_r, $fn=64);
        }

        // Inner race groove: cut into the outer face of the inner race
        for (zsgn = [-1, 1]) {
            translate([0, 0, zsgn*groove_z])
                rotate_extrude(angle=360)
                    translate([r_inner_outer - groove_r*0.55, 0, 0])
                        circle(r=groove_r*0.9, $fn=64);
        }

        // Ball pockets: shallow dimples on both races (do NOT remove full balls)
        // This creates visible "balls" impression while keeping a single connected solid.
        for (i = [0:ball_count-1]) {
            ang = i*360/ball_count;

            // Outer race dimples
            rotate([0, 0, ang])
                translate([r_pocket_outer, 0, 0])
                    sphere(r=pocket_r, $fn=64);

            // Inner race dimples
            rotate([0, 0, ang])
                translate([r_pocket_inner, 0, 0])
                    sphere(r=pocket_r, $fn=64);
        }
    }
}

ball_bearing();