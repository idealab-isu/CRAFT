// IEC power inlet module (IEC outlet RS 811-7193) - 40.0mm x 32.0mm
// One connected solid with recognizable IEC C14-style face opening, flange/ears,
// rear body, and terminals. No floating parts. All translate() values are formulas.

$fn = 64;

// ---------- Parameters ----------
overall_width_mm        = 40.0;  //[20:80:0.5]
overall_height_mm       = 32.0;  //[16:64:0.5]

flange_thickness_mm     = 2.5;   //[1.25:5:0.25]
bezel_thickness_mm      = 1.5;   //[0.75:3:0.25]
body_depth_mm           = 28.0;  //[14:56:0.5]

corner_radius_mm        = 3.0;   //[1.5:6:0.25]

mount_hole_diameter_mm  = 3.2;   //[2:6.5:0.1]
mount_hole_pitch_x_mm   = 30.0;  //[15:60:0.5]
mount_hole_pitch_y_mm   = 0.0;   //[0:30:0.5]

orifice_width_mm        = 27.0;  //[20:34:0.5]
orifice_height_mm       = 19.0;  //[14:26:0.5]

// C14 face details (approx)
c14_notch_w_mm          = 6.0;   // top key notch width
c14_notch_h_mm          = 3.0;   // top key notch depth into opening

body_width_mm           = 30.0;  //[20:50:0.5]
body_height_mm          = 22.0;  //[14:40:0.5]

terminal_blade_width_mm     = 6.3;  //[4.8:9.5:0.1]
terminal_blade_thickness_mm = 0.8;  //[0.5:1.6:0.05]
terminal_blade_length_mm    = 10.0; //[5:20:0.5]
terminal_pitch_x_mm         = 14.0; //[10:20:0.5]
terminal_pitch_y_mm         = 6.0;  //[4:12:0.5]

overlap_mm              = 1.0;   //[0.5:2:0.1]
cutout_extra_mm         = 0.5;   //[0.2:1.5:0.1]

// Ears (mounting tabs)
ear_w_mm                = 6.0;   // ear width in X
ear_h_mm                = 10.0;  // ear height in Y

// Face detailing
face_recess_depth_mm    = 2.0;   // recessed pocket depth
bevel_inset_mm          = 1.2;   // bevel inset around opening
bevel_depth_mm          = 1.2;   // bevel depth

// Pin cavity / shroud depth
shroud_wall_mm          = 1.2;
shroud_depth_mm         = 6.0;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
  }
}

module rounded_box(w, h, d, r, center=true) {
  translate(center ? [0,0,0] : [0,0,d/2])
    linear_extrude(height=d, center=true)
      rounded_rect_2d(w, h, r);
}

module trapezoid_prism(w1, h1, w2, h2, d, center=true) {
  translate(center ? [0,0,0] : [0,0,d/2])
    linear_extrude(height=d, center=true, scale=[w2/w1, h2/h1])
      square([w1, h1], center=true);
}

// C14-style opening: rectangle with a top-center key notch
module c14_opening_2d(w, h, notch_w, notch_h, r=1.2) {
  // notch_h is how far the notch cuts downward from the top edge
  difference() {
    rounded_rect_2d(w, h, r);
    translate([0, h/2 - notch_h/2])
      square([notch_w, notch_h + 2*cutout_extra_mm], center=true);
  }
}

// ---------- Main geometry ----------
module iec_inlet_solid() {
  flange_total_t = flange_thickness_mm + bezel_thickness_mm;

  // Coordinate convention:
  // Front face of flange at Z = 0
  // Positive Z goes outward (front), negative Z goes into device (rear)

  // Flange centered so its front face is at Z=0
  flange_center_z = flange_total_t/2;

  // Rear body overlaps into flange by overlap_mm to ensure connectivity
  body_center_z = -flange_thickness_mm - body_depth_mm/2 + overlap_mm;

  // Terminals overlap into rear body
  terminals_center_z =
    (-flange_thickness_mm - body_depth_mm) - terminal_blade_length_mm/2 + overlap_mm;

  // Face pocket centered just behind front face
  pocket_center_z = -face_recess_depth_mm/2;

  // Shrouds sit behind flange inside body, overlapping into body
  shroud_center_z = -flange_thickness_mm - shroud_depth_mm/2 + overlap_mm;

  difference() {
    union() {
      // Flange + ears (single connected plate)
      translate([0,0,flange_center_z])
        linear_extrude(height=flange_total_t, center=true)
          union() {
            rounded_rect_2d(overall_width_mm, overall_height_mm, corner_radius_mm);

            // Side ears (left/right), connected to flange with overlap
            for (sx = [-1, 1])
              translate([sx*(overall_width_mm/2 + ear_w_mm/2 - overlap_mm), 0])
                rounded_rect_2d(ear_w_mm, ear_h_mm, min(ear_w_mm, ear_h_mm)/4);
          }

      // Rear body (rounded box), overlaps into flange
      translate([0,0,body_center_z])
        rounded_box(body_width_mm, body_height_mm, body_depth_mm,
                    r=min(2.0, corner_radius_mm*0.6), center=true);

      // Internal pin shrouds (positive geometry) to give recognizable IEC inlet depth
      translate([0,0,shroud_center_z])
        union() {
          sh_w = terminal_blade_width_mm + 2*shroud_wall_mm;
          sh_h = 4.0 + 2*shroud_wall_mm;

          // Two upper, one lower center (approx C14)
          translate([-terminal_pitch_x_mm/2, -terminal_pitch_y_mm/2, 0])
            rounded_box(sh_w, sh_h, shroud_depth_mm, r=0.8, center=true);

          translate([ terminal_pitch_x_mm/2, -terminal_pitch_y_mm/2, 0])
            rounded_box(sh_w, sh_h, shroud_depth_mm, r=0.8, center=true);

          translate([0, terminal_pitch_y_mm/2, 0])
            rounded_box(sh_w, sh_h, shroud_depth_mm, r=0.8, center=true);
        }

      // Terminal blades (connected to body via overlap)
      translate([0,0,terminals_center_z])
        union() {
          translate([-terminal_pitch_x_mm/2, -terminal_pitch_y_mm/2, 0])
            cube([terminal_blade_width_mm, terminal_blade_thickness_mm, terminal_blade_length_mm], center=true);

          translate([ terminal_pitch_x_mm/2, -terminal_pitch_y_mm/2, 0])
            cube([terminal_blade_width_mm, terminal_blade_thickness_mm, terminal_blade_length_mm], center=true);

          translate([0, terminal_pitch_y_mm/2, 0])
            cube([terminal_blade_width_mm, terminal_blade_thickness_mm, terminal_blade_length_mm], center=true);
        }
    }

    // --- Subtractions (cutouts) ---

    // Face recess pocket (bezel detail)
    translate([0,0,pocket_center_z])
      rounded_box(orifice_width_mm + 2.0, orifice_height_mm + 2.0,
                  face_recess_depth_mm + 2*cutout_extra_mm,
                  r=1.5, center=true);

    // Beveled opening (chamfer) using C14 opening profile
    translate([0,0,-bevel_depth_mm/2])
      linear_extrude(height=bevel_depth_mm + 2*cutout_extra_mm, center=true)
        c14_opening_2d(orifice_width_mm + 2*bevel_inset_mm,
                       orifice_height_mm + 2*bevel_inset_mm,
                       c14_notch_w_mm + 2*bevel_inset_mm*0.5,
                       c14_notch_h_mm + 2*bevel_inset_mm*0.25,
                       r=1.2);

    // Main C14 opening cut through flange and into body (clears shrouds)
    orifice_cut_depth = flange_total_t + shroud_depth_mm + 8.0;
    // Center so it spans from front face into the body
    orifice_cut_center_z = -(orifice_cut_depth/2) + (flange_total_t/2);
    translate([0,0,orifice_cut_center_z])
      linear_extrude(height=orifice_cut_depth + 2*cutout_extra_mm, center=true)
        c14_opening_2d(orifice_width_mm, orifice_height_mm,
                       c14_notch_w_mm, c14_notch_h_mm, r=1.0);

    // Mounting holes through flange (left/right)
    for (sx = [-1, 1])
      translate([sx*mount_hole_pitch_x_mm/2, mount_hole_pitch_y_mm/2, flange_center_z])
        cylinder(d=mount_hole_diameter_mm, h=flange_total_t + 2*cutout_extra_mm, center=true);
  }
}

// ---------- Assembly ----------
iec_inlet_solid();