// Parameters
envelope_width_mm = 40; //[20:80:1]
envelope_length_mm = 40; //[20:80:1]
envelope_depth_mm = 9.5; //[5:19:0.5]
wall_thickness_mm = 1; //[0.6:2:0.1]
clearance_mm = 0.2; //[0.1:0.6:0.05]
corner_radius_mm = 3; //[1.5:6:0.5]
plate_thickness_mm = 1; //[0.6:2:0.1]
cavity_height_mm = 7.5; //[4:16:0.5]
inlet_bore_d_mm = 16; //[10:26:0.5]
outlet_width_mm = 12; //[6:20:0.5]
outlet_height_mm = 6; //[3:12:0.5]
outlet_length_mm = 10; //[5:25:1]
screw_hole_d_mm = 3; //[2:4:0.1]
screw_boss_d_mm = 7; //[5:12:0.5]
screw_pitch_mm = 32; //[24:48:1]
impeller_outer_d_mm = 24; //[16:34:0.5]
impeller_hub_d_mm = 10; //[6:18:0.5]
impeller_height_mm = 6.5; //[3:14:0.5]
impeller_blade_count = 18; //[8:30:1]
shaft_d_mm = 1.2; //[0.8:2.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Blower module
module blower() {
  color([0.15, 0.15, 0.17]) {
    difference() {
      union() {
        // Base plate
        translate([0, 0, -envelope_depth_mm/2 + plate_thickness_mm/2])
          cube([envelope_width_mm, envelope_length_mm, plate_thickness_mm], center=true);

        // Volute casing (shell)
        difference() {
          translate([0, 0, 0])
            cube([envelope_width_mm, envelope_length_mm, cavity_height_mm], center=true);
          translate([0, 0, 0])
            cube([envelope_width_mm - 2*wall_thickness_mm,
                  envelope_length_mm - 2*wall_thickness_mm,
                  cavity_height_mm - 2*wall_thickness_mm], center=true);
        }

        // Top cover plate (kept, but ensure it overlaps the casing slightly)
        // Previously it could end up not intersecting the casing depending on heights.
        // Place it so its bottom face penetrates the casing top by overlap_mm.
        translate([0, 0, (cavity_height_mm/2) + (plate_thickness_mm/2) - overlap_mm])
          cube([envelope_width_mm, envelope_length_mm, plate_thickness_mm], center=true);

        // Outlet duct (already overlaps into body by overlap_mm in X)
        difference() {
          translate([envelope_width_mm/2 + outlet_length_mm/2 - overlap_mm, 0, 0])
            cube([outlet_length_mm, outlet_width_mm, outlet_height_mm], center=true);
          translate([envelope_width_mm/2 + outlet_length_mm/2 - overlap_mm, 0, 0])
            cube([outlet_length_mm - 2*wall_thickness_mm,
                  outlet_width_mm - 2*wall_thickness_mm,
                  outlet_height_mm - 2*wall_thickness_mm], center=true);
        }

        // Screw bosses
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * screw_pitch_mm/2, y * screw_pitch_mm/2, 0])
            cylinder(r=screw_boss_d_mm/2, h=envelope_depth_mm, center=true);
        }

        // Impeller rotor
        union() {
          // Hub
          translate([0, 0, 0])
            cylinder(r=impeller_hub_d_mm/2, h=impeller_height_mm, center=true);

          // Blades
          for (i = [0:impeller_blade_count-1]) {
            rotate([0, 0, i*360/impeller_blade_count])
              translate([impeller_outer_d_mm/4, 0, 0])
              hull() {
                translate([0, 0, -impeller_height_mm/2])
                  cylinder(r=1, h=impeller_height_mm, $fn=12);
                translate([impeller_outer_d_mm/2 - 3, 3, impeller_height_mm*0.3])
                  rotate([0, 10, 15])
                  cylinder(r=1.5, h=impeller_height_mm*0.7, $fn=12);
              }
          }
        }

        // Impeller shaft connector
        translate([0, 0, 0])
          cylinder(r=shaft_d_mm/2,
                   h=envelope_depth_mm - plate_thickness_mm + overlap_mm,
                   center=true);

        // --- FIX: Add a physical "bridge/rim" that guarantees the upper cover is attached ---
        // This creates a thin perimeter ring that overlaps both the casing and the top cover.
        // It does not change the external envelope, but ensures a solid connection.
        difference() {
          translate([0, 0, (cavity_height_mm/2) - (overlap_mm/2)])
            cube([envelope_width_mm, envelope_length_mm, overlap_mm], center=true);
          translate([0, 0, (cavity_height_mm/2) - (overlap_mm/2)])
            cube([envelope_width_mm - 2*wall_thickness_mm,
                  envelope_length_mm - 2*wall_thickness_mm,
                  overlap_mm + 0.2], center=true);
        }
      }

      // Inlet bore (cut through top cover; position follows new top cover Z)
      translate([0, 0, (cavity_height_mm/2) + (plate_thickness_mm/2) - overlap_mm])
        cylinder(r=inlet_bore_d_mm/2,
                 h=plate_thickness_mm + wall_thickness_mm + overlap_mm,
                 center=true);

      // Mounting screw holes
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * screw_pitch_mm/2, y * screw_pitch_mm/2, 0])
          cylinder(r=screw_hole_d_mm/2, h=envelope_depth_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Fan module (kept for completeness; not used in final single-solid blower)
module fan() {
  color([0.2, 0.2, 0.22]) {
    difference() {
      cube([envelope_width_mm, envelope_length_mm, 10], center=true);
      cylinder(d=envelope_width_mm-4, h=12, center=true, $fn=32);
    }
    cylinder(d=impeller_hub_d_mm, h=8, center=true, $fn=24);
    for (i = [0:6]) {
      rotate([0, 0, i*360/7])
        hull() {
          translate([impeller_hub_d_mm/2 + 2, 0, -3])
            cylinder(r=2, h=6, $fn=8);
          translate([impeller_outer_d_mm/2 - 3, 3, 0])
            rotate([0, 12, 20])
            cylinder(r=2.5, h=5, $fn=8);
        }
    }
  }
}

// Blower Fan module (kept for completeness; not used in final single-solid blower)
module blower_fan() {
  color([0.2, 0.2, 0.22]) {
    difference() {
      cube([envelope_width_mm, envelope_length_mm, 10], center=true);
      cylinder(d=envelope_width_mm-4, h=12, center=true, $fn=32);
    }
    cylinder(d=impeller_hub_d_mm, h=8, center=true, $fn=24);
    for (i = [0:6]) {
      rotate([0, 0, i*360/7])
        hull() {
          translate([impeller_hub_d_mm/2 + 2, 0, -3])
            cylinder(r=2, h=6, $fn=8);
          translate([impeller_outer_d_mm/2 - 3, 3, 0])
            rotate([0, 12, 20])
            cylinder(r=2.5, h=5, $fn=8);
        }
    }
  }
}

// Assembly: output a single connected solid (blower only)
module assembly() {
  union() {
    blower();
  }
}

assembly();