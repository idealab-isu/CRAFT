// Ball bearing 5x8x2.5 (bore x OD x width) - single connected solid

$fn = 180;

// Parameters
bore_diameter_mm = 5.0;          //[2.5:10:0.1]
outer_diameter_mm = 8.0;         //[4:16:0.1]
width_mm = 2.5;                  //[1.25:5:0.05]

race_radial_thickness_mm = 0.6;  //[0.3:1.2:0.05]
ball_diameter_mm = 0.8;          //[0.4:1.6:0.05]
ball_overlap_mm = 0.2;           //[0.05:0.6:0.01]
eps_mm = 0.05;                   //[0.01:0.2:0.01]

// Derived
bore_r = bore_diameter_mm/2;
od_r   = outer_diameter_mm/2;

inner_race_od_r = bore_r + race_radial_thickness_mm;
outer_race_id_r = od_r   - race_radial_thickness_mm;

// Ball path radius (between races)
ball_path_r = (inner_race_od_r + outer_race_id_r)/2;

// Raceway groove radius (slightly larger than ball radius)
groove_r = ball_diameter_mm/2 + 0.05;

// Keep grooves within width
groove_z = 0; // centered

// Ensure at least 1 ball; approximate count by circumference / ball diameter
num_balls = max(6, floor(2*PI*ball_path_r / (ball_diameter_mm*1.15)));

module raceway_groove(r_center, z_center, r_groove) {
    // Torus-like groove made by rotate_extrude of a circle
    translate([0,0,z_center])
        rotate_extrude(angle=360, convexity=10)
            translate([r_center, 0, 0])
                circle(r=r_groove);
}

module bearing_solid() {
    // Build as a single connected solid:
    // - Start from a full ring (OD - bore)
    // - Carve out a central annular pocket to suggest separation between races
    // - Carve raceway grooves
    // - Add balls that overlap into the grooves (so everything is one connected solid)
    difference() {
        union() {
            // Base ring (ensures circular bore/OD)
            difference() {
                cylinder(r=od_r, h=width_mm, center=true);
                cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
            }

            // Balls (connected by overlap into grooves/races)
            for (i = [0:num_balls-1]) {
                rotate([0,0,i*360/num_balls])
                    translate([ball_path_r, 0, 0])
                        sphere(r=ball_diameter_mm/2);
            }
        }

        // Annular pocket between races (visual separation), leaving bridges at balls
        // Pocket radial span around ball path, but not too deep to break outer/inner rings.
        pocket_half_rad = max(ball_diameter_mm*0.55, 0.35);
        difference() {
            cylinder(r=ball_path_r + pocket_half_rad, h=width_mm + 2*eps_mm, center=true);
            cylinder(r=ball_path_r - pocket_half_rad, h=width_mm + 2*eps_mm, center=true);
        }

        // Raceway grooves (subtract), balls remain and overlap into the groove volume
        raceway_groove(ball_path_r, groove_z, groove_r);

        // Slight chamfers on faces (tiny) to look less like a washer
        chamfer = 0.15;
        translate([0,0, width_mm/2 - chamfer/2])
            cylinder(r1=od_r+eps_mm, r2=od_r-chamfer, h=chamfer+eps_mm, center=true);
        translate([0,0,-width_mm/2 + chamfer/2])
            cylinder(r1=od_r-chamfer, r2=od_r+eps_mm, h=chamfer+eps_mm, center=true);

        translate([0,0, width_mm/2 - chamfer/2])
            cylinder(r1=bore_r-chamfer, r2=bore_r+eps_mm, h=chamfer+eps_mm, center=true);
        translate([0,0,-width_mm/2 + chamfer/2])
            cylinder(r1=bore_r+eps_mm, r2=bore_r-chamfer, h=chamfer+eps_mm, center=true);
    }
}

bearing_solid();