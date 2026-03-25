$fn = 96;

// Parameters
rod_diameter = 16.0; //[8.0:32.0:0.5]
overall_height = 27.0; //[14.0:54.0:0.5]
bracket_width = 40.0; //[20.0:80.0:1]     // X
bracket_depth = 30.0; //[15.0:60.0:1]     // Y
base_thickness = 8.0; //[4.0:16.0:0.5]    // Z
wall_thickness = 6.0; //[3.0:12.0:0.5]
mount_hole_diameter = 5.0; //[3.0:10.0:0.5]
mount_hole_spacing = 26.0; //[13.0:52.0:1]
rod_fit_clearance = 0.4; //[0.0:1.2:0.1]
clamp_screw_diameter = 4.0; //[2.0:8.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Derived
bore_r  = (rod_diameter + rod_fit_clearance)/2;
outer_r = bore_r + wall_thickness;

body_h = overall_height - base_thickness;                 // height above base
assert(body_h > 0, "overall_height must be > base_thickness");

// Place rod center so the top of the clamp body reaches overall_height
rod_center_z = base_thickness + (body_h - outer_r);
assert(rod_center_z > base_thickness + 0.1,
       "Not enough body height for chosen outer_r; increase overall_height or reduce wall_thickness/rod_diameter.");

body_top_z = base_thickness + body_h;
assert(abs(body_top_z - overall_height) < 1e-6, "overall_height mismatch");

// Clamp geometry
split_w = max(1.2, wall_thickness*0.35);                  // slit width
split_y = bracket_depth + 2*overlap;                      // cut fully through Y
split_z0 = rod_center_z;                                  // slit starts at rod center
split_h = body_top_z - split_z0 + 2*overlap;              // slit to top

// Clamp screw (through Y, above bore)
screw_z = rod_center_z + outer_r*0.55;
screw_head_d = clamp_screw_diameter*2.0;                  // simple counterbore
screw_head_depth = wall_thickness*0.9;

// Mount holes (through Z)
mount_y = 0;
mount_z = base_thickness/2;

// SK16-style bracket (single connected solid)
module sk16_bracket() {

  // Leave a small "hinge/web" so the split doesn't sever the part
  hinge_web = max(1.2, overlap);
  split_x_center = bracket_width/2 - hinge_web/2;

  // Boss length in X with slight overlap into the blocks
  boss_h = bracket_width + 2*overlap;

  // --- Added/Fixed: side "ring/flange" (orange in screenshots) ---
  // Make it a real flange that is physically attached to the main body by
  // overlapping into the side face by 1-2mm.
  flange_radial = max(2.0, wall_thickness*0.6);           // thickness outward from boss OD
  flange_r_out  = outer_r + flange_radial;
  flange_r_in   = outer_r - overlap;                      // overlap into boss to guarantee fusion
  flange_len    = max(6.0, wall_thickness*1.2);           // thickness along X
  flange_x_sign = 1;                                      // +X side (matches screenshots)
  flange_x = flange_x_sign*(bracket_width/2 - flange_len/2 + overlap); // overlap into body

  difference() {
    union() {
      // Base block (bottom at z=0)
      translate([0, 0, base_thickness/2])
        cube([bracket_width, bracket_depth, base_thickness], center=true);

      // Upper clamp body: rectangular block sitting on base
      translate([0, 0, base_thickness + body_h/2])
        cube([bracket_width, bracket_depth, body_h], center=true);

      // Cylindrical boss around bore (fused: extend slightly in X)
      translate([0, 0, rod_center_z])
        rotate([0, 90, 0])
          cylinder(r=outer_r, h=boss_h, center=true);

      // Side flange/ring (physically attached: overlaps into boss and into body side)
      translate([flange_x, 0, rod_center_z])
        rotate([0, 90, 0])
          difference() {
            cylinder(r=flange_r_out, h=flange_len, center=true);
            cylinder(r=flange_r_in,  h=flange_len + 2*overlap, center=true);
          }

      // Vertical rib under the boss to guarantee attachment to the base
      rib_z0 = base_thickness - overlap;
      rib_h  = (rod_center_z - outer_r) - rib_z0 + 2*overlap; // up to bottom of boss
      if (rib_h > 0)
        translate([0, 0, rib_z0 + rib_h/2])
          cube([2*outer_r, bracket_depth, rib_h], center=true);
    }

    // Rod bore (through X)
    translate([0, 0, rod_center_z])
      rotate([0, 90, 0])
        cylinder(r=bore_r, h=bracket_width + 4*overlap, center=true);

    // Clamp split (slit from rod center to top, through Y) - shifted so it doesn't sever
    translate([split_x_center, 0, split_z0 + split_h/2 - overlap])
      cube([split_w, split_y, split_h], center=true);

    // Clamp screw hole (through Y)
    translate([0, 0, screw_z])
      rotate([90, 0, 0])
        cylinder(r=clamp_screw_diameter/2, h=bracket_depth + 2*overlap, center=true);

    // Counterbore on one side (front, +Y)
    translate([0, bracket_depth/2 - screw_head_depth/2 + overlap*0.2, screw_z])
      rotate([90, 0, 0])
        cylinder(r=screw_head_d/2, h=screw_head_depth + 2*overlap, center=true);

    // Mounting holes (through base, Z)
    translate([-mount_hole_spacing/2, mount_y, mount_z])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
    translate([ mount_hole_spacing/2, mount_y, mount_z])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
  }
}

sk16_bracket();