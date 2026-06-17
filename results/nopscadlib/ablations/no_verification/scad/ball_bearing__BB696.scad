// Ball bearing (single connected solid) with visible balls/races/shields
// Target dimensions: 6.0mm bore, 16.0mm outer diameter, 5.0mm width

bore_diameter_mm = 6;          //[3:12:0.1]
outer_diameter_mm = 16;        //[8:32:0.1]
width_mm = 5;                  //[2.5:10:0.1]

// Visual/detail parameters (kept within the envelope)
race_radial_thickness_mm = 1.6;    //[0.8:3.2:0.1]
race_axial_thickness_mm  = 1.2;    //[0.6:2.4:0.1]
shield_thickness_mm      = 0.4;    //[0.2:1:0.05]
shield_radial_overlap_mm = 0.6;    //[0.2:1.5:0.05]
ball_diameter_mm         = 3;      //[1.5:5:0.1]
ball_count               = 7;      //[5:12:1]

// Small overlap to guarantee ONE connected solid
connect_overlap_mm = 0.25;         //[0.05:0.6:0.05]
eps_mm = 0.02;

$fn = 128;

module ball_bearing_connected() {
    // Radii
    r_bore = bore_diameter_mm/2;
    r_od   = outer_diameter_mm/2;

    // Inner/outer race radial extents
    r_inner_race_outer = r_bore + race_radial_thickness_mm;
    r_outer_race_inner = r_od   - race_radial_thickness_mm;

    // Ball track radius (center of balls) derived from geometry
    r_track = (r_inner_race_outer + r_outer_race_inner)/2;

    // Keep balls inside the bearing envelope (avoid protruding past OD/ID)
    ball_r = min(ball_diameter_mm/2,
                 (r_outer_race_inner - r_inner_race_outer)/2 - eps_mm);

    // Axial placement of shields (near faces)
    z_shield = width_mm/2 - shield_thickness_mm/2 - eps_mm;

    // Connector ring: thin internal bridge that touches both races and balls
    // Ensure it is inside the cavity and not visible from outside.
    r_conn_inner = r_inner_race_outer - connect_overlap_mm;
    r_conn_outer = r_outer_race_inner + connect_overlap_mm;
    h_conn = min(race_axial_thickness_mm, width_mm - 2*shield_thickness_mm) * 0.6;

    // Small radial "spokes" that connect each ball to the connector ring
    // (guarantees balls are not floating even if tolerances change).
    spoke_w = max(0.35, connect_overlap_mm*1.2);
    spoke_h = max(ball_r*0.9, h_conn); // overlap in Z with connector ring

    union() {
        // OUTER RACE (ring)
        difference() {
            cylinder(r=r_od, h=width_mm, center=true);
            cylinder(r=r_outer_race_inner, h=width_mm + 2*eps_mm, center=true);
        }

        // INNER RACE (ring)
        difference() {
            cylinder(r=r_inner_race_outer, h=width_mm, center=true);
            cylinder(r=r_bore, h=width_mm + 2*eps_mm, center=true);
        }

        // SHIELDS (two thin rings)
        for (s = [-1, 1]) {
            translate([0, 0, s*z_shield])
                difference() {
                    cylinder(r=r_outer_race_inner + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
                    cylinder(r=r_inner_race_outer - shield_radial_overlap_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
                }
        }

        // BALLS + SPOKES (connected to connector ring)
        for (i = [0:ball_count-1]) {
            rotate([0, 0, i*360/ball_count]) {
                // Ball
                translate([r_track, 0, 0])
                    sphere(r=ball_r, $fn=64);

                // Spoke: overlaps ball and connector ring
                // Place centered at r_track, spanning radially across the connector ring thickness.
                translate([r_track, 0, 0])
                    cube([ (r_conn_outer - r_conn_inner) + 2*connect_overlap_mm,
                           spoke_w,
                           spoke_h ],
                         center=true);
            }
        }

        // CONNECTOR RING (internal, ensures single connected solid)
        difference() {
            cylinder(r=r_conn_outer, h=h_conn, center=true);
            cylinder(r=r_conn_inner, h=h_conn + 2*eps_mm, center=true);
        }
    }
}

ball_bearing_connected();