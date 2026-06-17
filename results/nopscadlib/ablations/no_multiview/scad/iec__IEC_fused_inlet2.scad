// Parameters
cutout_width_mm = 36.0; //[18.0:72.0:0.5]
cutout_height_mm = 27.0; //[13.5:54.0:0.5]
cutout_corner_radius_mm = 0.0; //[0.0:4.0:0.25]
panel_thickness_mm = 2.0; //[1.0:3.0:0.25]
fit_clearance_mm = 0.3; //[0.0:1.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
flange_width_mm = 44.0; //[36.0:88.0:0.5]
flange_height_mm = 34.0; //[27.0:68.0:0.5]
flange_thickness_mm = 3.0; //[1.5:6.0:0.25]
bezel_thickness_mm = 1.5; //[0.8:4.0:0.1]
body_depth_mm = 30.0; //[15.0:60.0:0.5]
body_wall_mm = 2.0; //[1.0:4.0:0.25]
front_face_recess_mm = 1.0; //[0.0:3.0:0.25]
mounting_method_variant = 1; //[0:1:1]
screw_hole_diameter_mm = 3.2; //[2.0:6.0:0.1]
screw_hole_pitch_x_mm = 36.0; //[20.0:60.0:0.5]
screw_hole_pitch_y_mm = 0.0; //[0.0:30.0:0.5]
fuse_drawer_width_mm = 18.0; //[12.0:30.0:0.5]
fuse_drawer_height_mm = 10.0; //[6.0:18.0:0.5]
fuse_drawer_depth_mm = 12.0; //[6.0:25.0:0.5]
spade_width_mm = 6.3; //[4.8:9.5:0.1]
spade_thickness_mm = 0.8; //[0.5:1.5:0.05]
spade_length_mm = 12.0; //[6.0:25.0:0.5]
spade_pitch_x_mm = 10.0; //[6.0:16.0:0.5]
spade_pitch_y_mm = 6.0; //[0.0:12.0:0.5]
strain_relief_clearance_radius_mm = 10.0; //[5.0:20.0:0.5]
strain_relief_clearance_length_mm = 25.0; //[10.0:60.0:0.5]

// ---------- Derived placement helpers (keeps everything connected) ----------
body_total_z_mm = body_depth_mm + panel_thickness_mm + flange_thickness_mm + bezel_thickness_mm;

// Keep the original body Z-centering logic, but reuse it consistently
body_center_z_mm = -(body_depth_mm - (flange_thickness_mm + bezel_thickness_mm)) / 2;

// Body extents
body_front_z_mm = body_center_z_mm + body_total_z_mm/2;
body_back_z_mm  = body_center_z_mm - body_total_z_mm/2;

// Flange extents (as modeled)
flange_total_z_mm = flange_thickness_mm + bezel_thickness_mm;
flange_center_z_mm = flange_total_z_mm/2;
flange_back_z_mm = flange_center_z_mm - flange_total_z_mm/2;

// ---------- IEC Inlet Body ----------
module iec() {
  color("Black")
  difference() {
    // Outer body
    translate([0, 0, body_center_z_mm])
      cube([cutout_width_mm - 2 * fit_clearance_mm,
            cutout_height_mm - 2 * fit_clearance_mm,
            body_total_z_mm], center=true);

    // Inner void
    translate([0, 0, body_center_z_mm])
      cube([cutout_width_mm - 2 * fit_clearance_mm - 2 * body_wall_mm,
            cutout_height_mm - 2 * fit_clearance_mm - 2 * body_wall_mm,
            body_total_z_mm - 2 * body_wall_mm], center=true);
  }
}

// ---------- Front Flange Bezel ----------
module front_flange_bezel() {
  color("Silver")
  difference() {
    // Outer flange
    translate([0, 0, flange_center_z_mm])
      cube([flange_width_mm, flange_height_mm, flange_total_z_mm], center=true);

    // Opening
    translate([0, 0, flange_center_z_mm])
      cube([cutout_width_mm + 2 * fit_clearance_mm,
            cutout_height_mm + 2 * fit_clearance_mm,
            flange_total_z_mm + 2 * overlap_mm], center=true);

    // Screw holes
    if (mounting_method_variant == 1) {
      translate([-screw_hole_pitch_x_mm / 2, screw_hole_pitch_y_mm / 2, flange_center_z_mm])
        rotate([90, 0, 0])
        cylinder(r=screw_hole_diameter_mm / 2, h=flange_total_z_mm + 2 * overlap_mm, center=true);

      translate([screw_hole_pitch_x_mm / 2, -screw_hole_pitch_y_mm / 2, flange_center_z_mm])
        rotate([90, 0, 0])
        cylinder(r=screw_hole_diameter_mm / 2, h=flange_total_z_mm + 2 * overlap_mm, center=true);
    }
  }
}

// ---------- Fuse Drawer Housing (ensure it intersects the body) ----------
module fuse_drawer_housing() {
  // Place it near the top inside the cutout, and push slightly into the body front
  fuse_y_mm = (cutout_height_mm/2 - fuse_drawer_height_mm/2 - overlap_mm);
  fuse_z_mm = body_front_z_mm - fuse_drawer_depth_mm/2 + overlap_mm; // intersects body by overlap_mm

  color("DimGray")
    translate([0, fuse_y_mm, fuse_z_mm])
      cube([fuse_drawer_width_mm, fuse_drawer_height_mm, fuse_drawer_depth_mm], center=true);
}

// ---------- Rear Terminal Spades (ensure they intersect the body back) ----------
module rear_terminal_spades() {
  spade_z_mm = body_back_z_mm - spade_length_mm/2 + overlap_mm; // intersects body by overlap_mm

  color("Silver") {
    translate([-spade_pitch_x_mm / 2,  spade_pitch_y_mm / 2, spade_z_mm])
      cube([spade_width_mm, spade_thickness_mm, spade_length_mm], center=true);
    translate([ spade_pitch_x_mm / 2,  spade_pitch_y_mm / 2, spade_z_mm])
      cube([spade_width_mm, spade_thickness_mm, spade_length_mm], center=true);
    translate([-spade_pitch_x_mm / 2, -spade_pitch_y_mm / 2, spade_z_mm])
      cube([spade_width_mm, spade_thickness_mm, spade_length_mm], center=true);
    translate([ spade_pitch_x_mm / 2, -spade_pitch_y_mm / 2, spade_z_mm])
      cube([spade_width_mm, spade_thickness_mm, spade_length_mm], center=true);
  }
}

// ---------- Strain Relief Clearance (FIX: attach cylinder to body; no floating) ----------
module strain_relief_clearance() {
  // The original cylinder was floating because it was translated too far back.
  // Attach it to the rear face of the body with a guaranteed overlap.
  // Cylinder axis is along Y due to rotate([90,0,0]); its "thickness" in Z is 2*r.
  // Ensure Z overlap by placing its center at (body_back_z - r + overlap).
  cyl_center_z_mm = body_back_z_mm - strain_relief_clearance_radius_mm + overlap_mm;

  color("Black")
    translate([0, 0, cyl_center_z_mm])
      rotate([90, 0, 0])
        cylinder(r=strain_relief_clearance_radius_mm,
                 h=strain_relief_clearance_length_mm,
                 center=true);
}

// ---------- Assembly (single connected solid) ----------
module assembly() {
  union() {
    iec();
    // Ensure flange intersects body slightly (they already overlap in Z, but keep union explicit)
    front_flange_bezel();
    fuse_drawer_housing();
    rear_terminal_spades();
    strain_relief_clearance();
  }
}

assembly();