// Ball bearing: 5.0mm bore, 9.0mm outer diameter, 3.0mm width
// One connected solid, with visible bore, inner/outer races, and balls.

bore_diameter_mm = 5.0;   //[2.5:10.0:0.1]
outer_diameter_mm = 9.0;  //[4.5:18.0:0.1]
width_mm = 3.0;           //[1.5:6.0:0.1]

overlap_mm = 0.25;        //[0.1:1.0:0.05]
race_radial_thickness_mm = 0.8; //[0.4:1.6:0.05]
race_axial_margin_mm = 0.25;    //[0.1:0.8:0.05]

ball_diameter_mm = 1.2;   //[0.6:2.4:0.05]
ball_count = 7;           //[5:12:1]

$fn = 96;

module ball_bearing() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;

    // Inner/outer race radial boundaries
    inner_race_outer_r = bore_r + race_radial_thickness_mm;
    outer_race_inner_r = outer_r - race_radial_thickness_mm;

    // Ball path radius (center of balls)
    ball_path_r = (inner_race_outer_r + outer_race_inner_r)/2;

    // Axial sizes
    inner_race_h = width_mm - 2*race_axial_margin_mm;
    outer_race_h = width_mm;

    // Small bridge to guarantee ONE connected solid (touches both races)
    // Kept minimal and placed at the ball path.
    bridge_w = max(0.35, ball_diameter_mm*0.25);
    bridge_h = max(0.35, width_mm*0.18);

    union() {
        // OUTER RACE (ring)
        difference() {
            cylinder(r=outer_r, h=outer_race_h, center=true);
            cylinder(r=outer_race_inner_r, h=outer_race_h + 2*overlap_mm, center=true);
        }

        // INNER RACE (ring)
        difference() {
            cylinder(r=inner_race_outer_r, h=inner_race_h, center=true);
            cylinder(r=bore_r, h=inner_race_h + 2*overlap_mm, center=true);
        }

        // BALLS (connected to races via tiny bridge)
        for (i = [0:ball_count-1]) {
            rotate([0, 0, i*360/ball_count]) {
                translate([ball_path_r, 0, 0])
                    sphere(r=ball_diameter_mm/2, $fn=48);
            }
        }

        // CONNECTIVITY BRIDGE (thin radial web at one angle)
        // Ensures the entire model is a single connected solid.
        rotate([0, 0, 0]) {
            translate([ball_path_r, 0, 0])
                cube([ (outer_race_inner_r - inner_race_outer_r) + 2*overlap_mm,
                       bridge_w,
                       bridge_h ],
                     center=true);
        }
    }
}

ball_bearing();