$fn = 128;

// Target dimensions (mm)
bore_diameter_mm   = 5.0;
outer_diameter_mm  = 13.0;
width_mm           = 4.0;
flange_diameter_mm = 15.0;

// Visual/detail parameters (kept modest so geometry stays valid)
flange_width_mm = 1.0;      // flange thickness (part of total width)
rim_thickness_mm = 1.2;     // outer race radial thickness
hub_thickness_mm = 1.2;     // inner race radial thickness
shield_thickness_mm = 0.6;  // shallow recess depth per side
shield_radial_overlap_mm = 0.6;
ball_diameter_mm = 1.6;
ball_count = 7;

eps = 0.02;

// Derived radii
r_bore  = bore_diameter_mm/2;
r_outer = outer_diameter_mm/2;
r_flange = flange_diameter_mm/2;

r_inner_outer = r_bore + hub_thickness_mm;     // OD of inner race
r_outer_inner = r_outer - rim_thickness_mm;    // ID of outer race

// Ball path radius (between races)
r_ball_path = (r_inner_outer + r_outer_inner)/2;

// Keep balls inside available radial space
ball_r = min(ball_diameter_mm/2, (r_outer_inner - r_inner_outer)/2 - 0.05);
ball_d = 2*ball_r;

// Axial layout: total width is width_mm, flange occupies top portion
z_top =  width_mm/2;
z_bot = -width_mm/2;
z_flange_center = z_top - flange_width_mm/2;

// Ensure flange is within width
flange_width_mm = min(flange_width_mm, width_mm);

// Main bearing as ONE connected solid (with through-bore)
module flanged_bearing() {
  difference() {
    union() {
      // Outer ring body (full width)
      cylinder(r=r_outer, h=width_mm, center=true);

      // Flange (connected to outer ring, within total width)
      translate([0,0,z_flange_center])
        cylinder(r=r_flange, h=flange_width_mm, center=true);

      // Inner ring body (full width) - connected via small bridges to keep one solid
      cylinder(r=r_inner_outer, h=width_mm, center=true);

      // Balls (for visual bearing look) - connected via tiny bridges to inner ring
      for (i = [0:ball_count-1]) {
        rotate([0,0,i*360/ball_count]) {
          translate([r_ball_path, 0, 0])
            sphere(r=ball_r);

          // Small bridge to ensure connectivity (overlaps inner ring slightly)
          // Bridge runs radially from inner ring OD to ball center
          bridge_len = max(0.2, r_ball_path - r_inner_outer + 0.15);
          translate([r_inner_outer + bridge_len/2 - 0.15, 0, 0])
            cube([bridge_len, ball_d*0.35, ball_d*0.35], center=true);
        }
      }
    }

    // Through bore (5mm) - guarantees visible hole
    cylinder(r=r_bore, h=width_mm + 2, center=true);

    // Remove material between inner and outer rings to create race gap
    // (leaves outer ring thickness and inner ring thickness)
    cylinder(r=r_outer_inner, h=width_mm + 2, center=true);
    cylinder(r=r_inner_outer, h=width_mm + 2, center=true);

    // Re-add rings by subtracting only the annulus between them:
    // Use a "negative" trick: subtract a big cylinder, then add back rings is not possible in difference.
    // So instead, carve the gap with an annular cutter:
    difference() {
      cylinder(r=r_outer_inner, h=width_mm + 2, center=true);
      cylinder(r=r_inner_outer, h=width_mm + 2, center=true);
    }

    // Shield recesses (shallow grooves) on both faces for visual detail
    for (z = [z_top - shield_thickness_mm/2, z_bot + shield_thickness_mm/2]) {
      translate([0,0,z])
        difference() {
          cylinder(r=r_outer - rim_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm + eps, center=true);
          cylinder(r=r_bore + hub_thickness_mm - shield_radial_overlap_mm, h=shield_thickness_mm + 2, center=true);
        }
    }
  }
}

// Correct race-gap carving: build rings explicitly, then subtract bore and add details
module bearing_connected_solid() {
  difference() {
    union() {
      // Outer ring + flange
      union() {
        difference() {
          cylinder(r=r_outer, h=width_mm, center=true);
          cylinder(r=r_outer_inner, h=width_mm + 2, center=true);
        }
        translate([0,0,z_flange_center])
          cylinder(r=r_flange, h=flange_width_mm, center=true);
      }

      // Inner ring
      difference() {
        cylinder(r=r_inner_outer, h=width_mm, center=true);
        cylinder(r=r_bore, h=width_mm + 2, center=true);
      }

      // Balls + bridges (connect to inner ring)
      for (i = [0:ball_count-1]) {
        rotate([0,0,i*360/ball_count]) {
          translate([r_ball_path, 0, 0])
            sphere(r=ball_r);

          bridge_len = max(0.2, r_ball_path - r_inner_outer + 0.15);
          translate([r_inner_outer + bridge_len/2 - 0.15, 0, 0])
            cube([bridge_len, ball_d*0.35, ball_d*0.35], center=true);
        }
      }
    }

    // Ensure bore is clean through everything
    cylinder(r=r_bore, h=width_mm + 4, center=true);

    // Add shallow shield grooves by subtracting
    for (z = [z_top - shield_thickness_mm/2, z_bot + shield_thickness_mm/2]) {
      translate([0,0,z])
        difference() {
          cylinder(r=r_outer - rim_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm + eps, center=true);
          cylinder(r=r_bore + hub_thickness_mm - shield_radial_overlap_mm, h=shield_thickness_mm + 4, center=true);
        }
    }
  }
}

bearing_connected_solid();