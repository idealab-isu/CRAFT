// T-slot nut for 6.0mm screws, 8.0mm across flats, and 6.6mm thick
// Corrected to be a true T-slot nut profile (rectangular T body with lips/undercut),
// while keeping the 8.0mm across-flats hex drive feature and a 6.0mm screw hole.

screw_thread_diameter_mm      = 6.0;  //[3.0:12.0:0.1]
hole_tap_drill_diameter_mm    = 5.0;  //[2.5:10.0:0.1]
hole_clearance_mm             = 0.0;  //[0.0:1.0:0.05]
across_flats_mm               = 8.0;  //[4.0:16.0:0.1]
thickness_mm                  = 6.6;  //[3.3:13.2:0.1]
chamfer_mm                    = 0.3;  //[0.0:1.5:0.05]
corner_radius_mm              = 0.5;  //[0.0:2.0:0.1]
nut_length_mm                 = 12.0; //[6.0:24.0:0.5]
t_slot_major_width_mm         = 11.8; //[6.0:20.0:0.1]  // lip width (T head)
t_slot_minor_width_mm         = 7.8;  //[4.0:16.0:0.1]  // stem width (T neck)
t_slot_lip_thickness_mm       = 2.2;  //[1.0:4.4:0.1]   // thickness of each lip (top & bottom)
step_overlap_mm               = 0.8;  //[0.2:2.0:0.1]
hole_extra_height_mm          = 2.0;  //[0.5:6.0:0.5]
hex_tool_extra_height_mm      = 1.0;  //[0.5:4.0:0.5]

$fn = 96;

function clamp(x, a, b) = min(max(x, a), b);

module rounded_cube_xy(size=[10,10,10], r=0.5, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = clamp(r, 0, min(sx, sy)/2);

  translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    linear_extrude(height=sz, center=true)
      offset(r=rr)
        square([sx-2*rr, sy-2*rr], center=true);
}

module tslot_nut() {
  // Derived dimensions
  lip_h = t_slot_lip_thickness_mm;
  stem_h = thickness_mm - 2*lip_h;                 // middle stem thickness
  stem_h2 = max(0.01, stem_h + step_overlap_mm);   // overlap for robust union

  // Z positions (computed)
  z_top_lip    =  thickness_mm/2 - lip_h/2;
  z_bottom_lip = -thickness_mm/2 + lip_h/2;
  z_stem       =  0;

  // Hex radius from across-flats (AF = 2*R*cos(30))
  hex_R = across_flats_mm/(2*cos(30));

  // Hole radius (tap drill + clearance)
  hole_r = (hole_tap_drill_diameter_mm + hole_clearance_mm)/2;

  difference() {
    // True T-slot profile: rectangular T (major lips + minor stem),
    // then add a hex "drive" feature by intersecting only the central stem region.
    union() {
      // T body (connected solid)
      union() {
        // Top lip
        translate([0, 0, z_top_lip])
          rounded_cube_xy([t_slot_major_width_mm, nut_length_mm, lip_h],
                          r=corner_radius_mm, center=true);

        // Bottom lip
        translate([0, 0, z_bottom_lip])
          rounded_cube_xy([t_slot_major_width_mm, nut_length_mm, lip_h],
                          r=corner_radius_mm, center=true);

        // Middle stem (overlaps into both lips)
        translate([0, 0, z_stem])
          rounded_cube_xy([t_slot_minor_width_mm, nut_length_mm, stem_h2],
                          r=corner_radius_mm, center=true);
      }

      // Hex drive feature (8mm AF) limited to the stem region so the outer silhouette remains T-shaped
      intersection() {
        cylinder(h=thickness_mm + hex_tool_extra_height_mm, r=hex_R, center=true, $fn=6);
        // Limit hex to the stem width/height so it doesn't "hexify" the lips
        rounded_cube_xy([t_slot_minor_width_mm, nut_length_mm, thickness_mm + hex_tool_extra_height_mm],
                        r=0, center=true);
      }
    }

    // Through hole (for M6 tapping/clearance as set by parameters)
    cylinder(h=thickness_mm + hole_extra_height_mm, r=hole_r, center=true, $fn=64);

    // Chamfers on both sides of the hole
    translate([0, 0,  thickness_mm/2 - chamfer_mm/2])
      cylinder(h=chamfer_mm, r1=hole_r + chamfer_mm, r2=hole_r, center=true, $fn=64);

    translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
      cylinder(h=chamfer_mm, r1=hole_r, r2=hole_r + chamfer_mm, center=true, $fn=64);
  }
}

tslot_nut();