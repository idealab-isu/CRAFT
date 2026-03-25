// Flanged ball bearing (single connected solid, with visible 3.0mm through-bore)
// Specs: 3.0mm bore, 10.0mm OD, 4.0mm width, 11.5mm flange OD

$fn = 160;

// Parameters
bore_diameter_mm = 3.0;                 //[1.5:6.0:0.1]
outer_diameter_mm = 10.0;              //[5.0:20.0:0.1]
width_mm = 4.0;                        //[2.0:8.0:0.1]
flange_outer_diameter_mm = 11.5;       //[5.75:23.0:0.1]
flange_width_mm = 0.8;                 //[0.4:1.6:0.05]

outer_race_rim_thickness_mm = 1.0;     //[0.5:2.0:0.05]
inner_race_hub_thickness_mm = 1.0;     //[0.5:2.0:0.05]

annulus_clearance_mm = 0.25;           //[0.05:0.6:0.01]
annulus_axial_inset_mm = 0.35;         //[0.1:0.8:0.01]

ball_diameter_mm = 1.2;                //[0.6:2.4:0.05]
ball_count = 8;                        //[5:14:1]

chamfer_mm = 0.15;                     //[0.05:0.3:0.01]
eps_mm = 0.06;                         //[0.01:0.5:0.01]

// Connectivity bridges (keeps model ONE connected solid)
bridge_thickness_mm = 0.30;            //[0.1:0.6:0.01]
bridge_width_mm = 0.70;                //[0.2:1.5:0.05]
bridge_count = 3;                      //[1:6:1]

// Derived radii
bore_r = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;
flange_r = flange_outer_diameter_mm/2;

inner_race_outer_r = bore_r + inner_race_hub_thickness_mm;
outer_race_inner_r = outer_r - outer_race_rim_thickness_mm;

// Ball path radius (kept inside annulus)
ball_path_r = (inner_race_outer_r + annulus_clearance_mm) +
              (outer_race_inner_r - annulus_clearance_mm - (inner_race_outer_r + annulus_clearance_mm))/2;

// Axial extents
z_top =  width_mm/2;
z_bot = -width_mm/2;

// Flange placement: on bottom face, slightly overlapped for robust union
flange_z = z_bot + flange_width_mm/2 - eps_mm;

// Annulus (ball pocket) axial height
annulus_h = max(0.25, width_mm - 2*annulus_axial_inset_mm);

// Helper: chamfer ring (purely visual, stays within given radii)
module chamfer_ring(r_outer, r_inner, z_at, up=true) {
    translate([0,0,z_at])
        cylinder(h=chamfer_mm,
                 r1= up ? r_outer : r_inner,
                 r2= up ? r_inner : r_outer,
                 center=false);
}

module bearing_solid() {
    union() {

        // ===== SOLID BODY (outer race + flange + inner race + balls + bridges) =====
        difference() {
            union() {

                // OUTER RACE + FLANGE (solid)
                difference() {
                    union() {
                        cylinder(r=outer_r, h=width_mm, center=true);

                        // Flange (connected by overlap computed from dimensions)
                        translate([0,0,flange_z])
                            cylinder(r=flange_r, h=flange_width_mm, center=true);
                    }

                    // Hollow out to create outer race ring (keeps OD and width)
                    cylinder(r=outer_race_inner_r, h=width_mm + 2*eps_mm, center=true);

                    // Relief under flange so flange reads as a step (keeps flange OD)
                    translate([0,0,flange_z])
                        cylinder(r=flange_r - 0.25, h=flange_width_mm + 2*eps_mm, center=true);
                }

                // INNER RACE (solid ring)
                difference() {
                    cylinder(r=inner_race_outer_r, h=width_mm, center=true);
                    // NOTE: bore is cut later globally to ensure visible through-hole
                    cylinder(r=bore_r + eps_mm, h=width_mm + 2*eps_mm, center=true);
                }

                // BALLS (solid spheres)
                for (i = [0:ball_count-1]) {
                    rotate([0,0,i*360/ball_count])
                        translate([ball_path_r, 0, 0])
                            sphere(r=ball_diameter_mm/2);
                }

                // CONNECTIVITY BRIDGES (thin ribs) from inner race to outer race
                for (j = [0:bridge_count-1]) {
                    rotate([0,0,j*360/bridge_count])
                        translate([(inner_race_outer_r + outer_race_inner_r)/2, 0, 0])
                            cube([outer_race_inner_r - inner_race_outer_r + 2*eps_mm,
                                  bridge_width_mm,
                                  bridge_thickness_mm],
                                 center=true);
                }

                // Subtle chamfers (visual only; do not exceed OD/width)
                chamfer_ring(outer_r - eps_mm, outer_r - outer_race_rim_thickness_mm, z_top - chamfer_mm, up=true);
                chamfer_ring(outer_r - eps_mm, outer_r - outer_race_rim_thickness_mm, z_bot + flange_width_mm, up=false);
                chamfer_ring(inner_race_outer_r - eps_mm, bore_r + eps_mm, z_top - chamfer_mm, up=true);
                chamfer_ring(inner_race_outer_r - eps_mm, bore_r + eps_mm, z_bot, up=false);
            }

            // ===== GLOBAL THROUGH-BORE (ensures visible 3.0mm hole in all views) =====
            cylinder(r=bore_r, h=width_mm + flange_width_mm + 4*eps_mm, center=true);

            // ===== BALL POCKET / ANNULUS VOID (to show bearing features) =====
            // Remove a ring-shaped cavity between races, leaving bridges to keep one connected solid.
            difference() {
                cylinder(r=outer_race_inner_r - annulus_clearance_mm,
                         h=annulus_h + 2*eps_mm, center=true);
                cylinder(r=inner_race_outer_r + annulus_clearance_mm,
                         h=annulus_h + 2*eps_mm, center=true);
            }
        }
    }
}

bearing_solid();