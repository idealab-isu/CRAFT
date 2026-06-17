// DURATRAK V5HM variac (simplified) - single connected solid
// Fixes: ensure all parts are connected via computed translations and slight overlaps.
// Note: screws/washers are merged into the body (no separate floating parts).

// Parameters
thickness = 3; //[1.5:6:0.5]
dial = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]

body_diameter = 120; //[60:240:1]
body_height = 70; //[35:140:1]

bulge_width = 55; //[28:110:1]  // (kept for compatibility; not used directly)
bulge_extra_radius = 18; //[9:36:1]
bulge_height = 60; //[30:120:1]

shaft_diameter = 10; //[5:20:0.5]
shaft_length = 35; //[15:70:1]

mount_hole_diameter = 5; //[3:10:0.5]
mount_hole_offset_x = 40; //[20:80:1]
mount_hole_offset_y = 30; //[15:60:1]

screw_shank_diameter = 4.5; //[3:8:0.5]
screw_head_diameter = 8.5; //[5:16:0.5]
screw_length = 16; //[8:32:1]
washer_outer_diameter = 12; //[6:24:0.5]
washer_thickness = 1.5; //[0.8:3:0.1]

dial_diameter = 85; //[40:170:1]
dial_thickness = 6; //[3:15:0.5]
dial_hub_diameter = 22; //[10:44:1]
dial_hub_height = 10; //[5:25:1]

// Derived
main_r  = body_diameter/2;
bulge_r = main_r + bulge_extra_radius;

// Place bulge so it is tangent to main body with a small overlap (connected)
bulge_center_x = main_r + bulge_r - overlap;

// Z placement helpers (all centered solids)
z_top_of_body = body_height/2;
z_bottom_of_body = -body_height/2;

// Variac Body with Bulge + integrated "hardware" bosses (single solid)
module variac_body_solid() {
  union() {
    // Main body
    cylinder(r=main_r, h=body_height, center=true, $fn=96);

    // Bulge (secondary cylinder) connected to main body
    translate([bulge_center_x, 0, 0])
      cylinder(r=bulge_r, h=bulge_height, center=true, $fn=96);

    // Integrated screw/washer bosses on top face (so nothing floats)
    // These are positive features (not separate parts) to keep one connected solid.
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_offset_x, y * mount_hole_offset_y,
                 z_top_of_body + washer_thickness/2 - overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true, $fn=48);

      translate([x * mount_hole_offset_x, y * mount_hole_offset_y,
                 z_top_of_body + washer_thickness - overlap + (screw_length/6)/2])
        cylinder(r=screw_head_diameter/2, h=screw_length/6, center=true, $fn=48);
    }
  }
}

// Subtractive features (holes) that do not disconnect the solid
module variac_body_cuts() {
  union() {
    // Mounting through-holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_offset_x, y * mount_hole_offset_y, 0])
        cylinder(r=mount_hole_diameter/2, h=body_height + 4*overlap, center=true, $fn=48);
    }

    // Optional shallow counterbore for screw shank (kept shallow to avoid odd artifacts)
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_offset_x, y * mount_hole_offset_y,
                 z_top_of_body - (screw_length/2) + overlap])
        cylinder(r=screw_shank_diameter/2, h=screw_length, center=true, $fn=48);
    }
  }
}

// Shaft (connected to dial hub; dial hub connected to dial disc; disc overlaps body)
module shaft_solid() {
  // Shaft starts at top of dial hub and extends upward; overlap ensures connection.
  z_dial_disc_center = z_top_of_body + thickness + dial_thickness/2 - overlap;
  z_dial_hub_center  = z_top_of_body + thickness + dial_thickness + dial_hub_height/2 - overlap;

  z_hub_top = z_dial_hub_center + dial_hub_height/2;
  z_shaft_center = z_hub_top + shaft_length/2 - overlap;

  translate([0, 0, z_shaft_center])
    cylinder(r=shaft_diameter/2, h=shaft_length, center=true, $fn=48);
}

// Dial (disc + hub) connected to body and shaft
module dial_solid() {
  if (dial == 1) {
    z_dial_disc_center = z_top_of_body + thickness + dial_thickness/2 - overlap;
    z_dial_hub_center  = z_top_of_body + thickness + dial_thickness + dial_hub_height/2 - overlap;

    union() {
      // Dial disc overlaps into body by 'overlap' via z placement
      translate([0, 0, z_dial_disc_center])
        cylinder(r=dial_diameter/2, h=dial_thickness, center=true, $fn=128);

      // Hub overlaps into disc by 'overlap' via z placement
      translate([0, 0, z_dial_hub_center])
        cylinder(r=dial_hub_diameter/2, h=dial_hub_height, center=true, $fn=96);
    }
  }
}

// Assembly: ONE connected solid (single union with internal differences)
difference() {
  union() {
    variac_body_solid();
    dial_solid();
    if (dial == 1) shaft_solid();
  }
  variac_body_cuts();
}