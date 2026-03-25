// Old unswitched mains socket (UK-style) - one connected solid
// Dimension-driven placement; no floating parts

// Parameters
socket_style = 0; //[0:1:1]
switched = 0; //[0:1:1]
include_earth_cutout = 1; //[0:1:1]
include_panel_cutout = 1; //[0:1:1]
panel_cutout_small = 0; //[0:1:1]

faceplate_w = 86; //[60:172:1]
faceplate_h = 86; //[60:172:1]
faceplate_t = 8;  //[4:16:1]
corner_r = 6;     //[3:12:1]

body_overlap = 1; //[0.5:2:0.5]

screw_pitch_y = 60.3; //[45:90:0.1]
screw_clear_d = 3.8;  //[3:5:0.1]
screw_csk_d = 8;      //[6:12:0.1]
screw_csk_depth = 3;  //[1:6:0.1]

pin_pitch_x = 22.2;   //[18:28:0.1]
pin_y_offset = -11.1; //[-20:0:0.1]
earth_y_offset = 11.1; //[0:20:0.1]

ln_aperture_w = 7;    //[5:10:0.1]
ln_aperture_h = 4.5;  //[3:7:0.1]
earth_aperture_w = 4.5; //[3:7:0.1]
earth_aperture_h = 8.5; //[6:12:0.1]
aperture_depth = 10;  //[6:20:1]

rear_cavity_depth = 22; //[12:44:1]
rear_wall_t = 2.5;      //[1.5:5:0.1]
rear_cavity_w = 70;     //[50:120:1]
rear_cavity_h = 70;     //[50:120:1]

panel_cutout_w = 67; //[45:120:1]
panel_cutout_h = 67; //[45:120:1]
panel_cutout_t = 2;  //[1:6:1]
panel_tab_w = 10;    //[6:20:1]

earth_ref_d = 6;       //[4:12:0.5]
earth_ref_inset = 8;   //[4:16:0.5]

// Extra detailing parameters (dimension-driven)
inner_border_inset = 6;     // inset of inner recessed border from faceplate edge
inner_border_depth = 0.8;   // shallow recess depth
aperture_chamfer = 0.8;     // small lead-in chamfer for apertures

back_box_w = 70;
back_box_h = 70;
back_box_d = 35;

neck_w = 26;   // widened to resemble typical socket body transition
neck_h = 22;
neck_d = 10;

eps = 0.01;

// Rounded rectangle prism (centered)
module rr_prism(w, h, t, r, center=true) {
  translate(center ? [0,0,0] : [w/2, h/2, t/2])
    hull() {
      for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(w/2 - r), sy*(h/2 - r), 0])
          cylinder(r=r, h=t, center=true, $fn=48);
    }
}

// Faceplate solid
module faceplate_solid() {
  rr_prism(faceplate_w, faceplate_h, faceplate_t, corner_r, center=true);
}

// Old unswitched socket front detailing (recessed border + apertures + screws)
module faceplate_cutouts() {
  // Inner recessed border (old style)
  rr_prism(
    faceplate_w - 2*inner_border_inset,
    faceplate_h - 2*inner_border_inset,
    inner_border_depth + body_overlap,
    max(0.1, corner_r - inner_border_inset/2),
    center=true
  );

  // Apertures (with slight chamfer lead-in)
  for (sx = [-1, 1]) {
    // Chamfer lead-in
    translate([sx*pin_pitch_x/2, pin_y_offset, faceplate_t/2 - (aperture_chamfer/2)])
      cube([ln_aperture_w + 2*aperture_chamfer,
            ln_aperture_h + 2*aperture_chamfer,
            aperture_chamfer + body_overlap], center=true);

    // Main slot
    translate([sx*pin_pitch_x/2, pin_y_offset, faceplate_t/2 - (aperture_depth/2)])
      cube([ln_aperture_w, ln_aperture_h, aperture_depth + body_overlap], center=true);
  }

  // Earth aperture
  translate([0, earth_y_offset, faceplate_t/2 - (aperture_chamfer/2)])
    cube([earth_aperture_w + 2*aperture_chamfer,
          earth_aperture_h + 2*aperture_chamfer,
          aperture_chamfer + body_overlap], center=true);

  translate([0, earth_y_offset, faceplate_t/2 - (aperture_depth/2)])
    cube([earth_aperture_w, earth_aperture_h, aperture_depth + body_overlap], center=true);

  // Mounting screw holes + countersinks
  for (sy = [-1, 1]) {
    translate([0, sy*screw_pitch_y/2, 0])
      cylinder(r=screw_clear_d/2, h=faceplate_t + 2*body_overlap, center=true, $fn=48);

    translate([0, sy*screw_pitch_y/2, faceplate_t/2 - (screw_csk_depth + body_overlap)/2])
      cylinder(r=screw_csk_d/2, h=screw_csk_depth + body_overlap, center=true, $fn=48);
  }

  // Rear cavity (keeps rear wall thickness)
  // Ensure cavity does not break through the front: leave rear_wall_t at the back of faceplate
  cavity_h = min(rear_cavity_depth, max(0, faceplate_t - rear_wall_t));
  if (cavity_h > 0)
    translate([0, 0, -faceplate_t/2 + cavity_h/2])
      cube([rear_cavity_w, rear_cavity_h, cavity_h + eps], center=true);
}

// Back box + neck (connected to faceplate)
module back_box_connected() {
  // Neck connects faceplate to back box with overlap into faceplate
  translate([0, 0, -faceplate_t/2 - neck_d/2 + body_overlap])
    rr_prism(neck_w, neck_h, neck_d, r=min(4, min(neck_w,neck_h)/4), center=true);

  // Back box (old style surface box) connected to neck with overlap
  translate([0, 0, -faceplate_t/2 - neck_d - back_box_d/2 + 2*body_overlap])
    rr_prism(back_box_w, back_box_h, back_box_d, r=min(6, min(back_box_w,back_box_h)/10), center=true);
}

// Earth reference marker (small bump; stays connected to rear cavity floor region)
module earth_reference_bump() {
  // Put bump on the rear cavity "floor" area (still part of the solid)
  translate(
    [-rear_cavity_w/2 + earth_ref_inset,
     -rear_cavity_h/2 + earth_ref_inset,
     -faceplate_t/2 + max(0.6, inner_border_depth)/2]
  )
    cylinder(r=earth_ref_d/2, h=max(0.6, inner_border_depth), center=true, $fn=48);
}

// Panel cutout tab (connected, not floating)
module panel_cutout_connected() {
  // Keep it as an optional connected "template" piece, but ensure it attaches to the faceplate edge.
  // Use a thin bridge that overlaps into the faceplate by body_overlap.
  cut_w = panel_cutout_small ? panel_cutout_w*0.7 : panel_cutout_w;
  cut_h = panel_cutout_small ? panel_cutout_h*0.7 : panel_cutout_h;

  // Bridge/tab
  translate([faceplate_w/2 + panel_tab_w/2 - body_overlap, 0, -faceplate_t/2 + panel_cutout_t/2])
    cube([panel_tab_w + 2*body_overlap, cut_h*0.35, panel_cutout_t], center=true);

  // Cutout plate
  translate([faceplate_w/2 + panel_tab_w + cut_w/2 - 2*body_overlap, 0, -faceplate_t/2 + panel_cutout_t/2])
    cube([cut_w, cut_h, panel_cutout_t], center=true);
}

// Assembly: ONE connected solid
module assembly() {
  union() {
    // Main socket body (faceplate with cutouts + connected back box)
    difference() {
      union() {
        faceplate_solid();
        back_box_connected();
      }
      faceplate_cutouts();
    }

    // Optional earth reference bump (adds material, stays connected)
    if (include_earth_cutout)
      earth_reference_bump();

    // Optional connected panel cutout geometry
    if (include_panel_cutout)
      panel_cutout_connected();
  }
}

assembly();