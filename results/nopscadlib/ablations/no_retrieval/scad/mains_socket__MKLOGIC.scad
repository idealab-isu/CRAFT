$fn = 96;

// -------------------- Parameters --------------------
plate_W = 146; //[73:292:1]
plate_H = 86;  //[43:172:1]
plate_T = 3;   //[1.5:6:0.1]
plate_corner_R = 6; //[3:12:0.5]

socket_recess_W = 70; //[35:140:1]
socket_recess_H = 55; //[27.5:110:1]
socket_recess_D = 1.5; //[0.5:3:0.1]
recess_corner_R = 4; //[2:8:0.5]
socket_recess_offset_x = -20; //[-40:0:1]
socket_recess_offset_y = 0;   //[-20:20:1]

switch_W = 24; //[12:48:1]
switch_H = 34; //[17:68:1]
switch_T = 4;  //[2:8:0.1]
switch_offset_x = 50; //[0:80:1]
switch_offset_y = 0;  //[-20:20:1]
switch_aperture_clearance = 1; //[0.5:2:0.1]

indicator_W = 6;  //[3:12:0.5]
indicator_H = 12; //[6:24:0.5]
indicator_inset_from_top = 6; //[3:12:0.5]

screw_hole_d = 4.2; //[2.5:6:0.1]
screw_csk_d = 8.5;  //[6:12:0.1]
screw_csk_depth = 1.2; //[0.6:2.5:0.1]
screw_hole_spacing = 120; //[60:160:1]
screw_hole_offset_y = 0; //[-20:20:1]

backbox_W = 120; //[60:180:1]
backbox_H = 70;  //[35:120:1]
backbox_D = 25;  //[12:50:1]

overlap = 1; //[0.5:2:0.1]

// UK socket aperture (stylised)
pin_bot_w = 7;
pin_bot_h = 16;
pin_spacing_x = 22;
pin_offset_y = -2;

earth_w = 8;
earth_h = 18;
earth_offset_y = 14;

// Ensure apertures actually cut through the front face (and a bit beyond)
aperture_depth = plate_T + 2*overlap;

// Socket outline (raised bezel) inside recess
socket_bezel_inset = 4; //[2:8:0.5]
socket_bezel_h = 0.8;   //[0.4:1.6:0.1]

// Optional subtle emboss around apertures (kept simple)
aperture_bezel_h = 0.6;
aperture_bezel_r = 1.2;

// -------------------- Helpers --------------------
module rounded_rect_2d(w,h,r){
  r2 = min(r, min(w,h)/2);
  hull(){
    translate([ w/2-r2,  h/2-r2]) circle(r=r2);
    translate([-w/2+r2,  h/2-r2]) circle(r=r2);
    translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    translate([ w/2-r2, -h/2+r2]) circle(r=r2);
  }
}

module rounded_box(w,h,t,r,center=true){
  linear_extrude(height=t, center=center)
    rounded_rect_2d(w,h,r);
}

module faceplate(){
  rounded_box(plate_W, plate_H, plate_T, plate_corner_R, center=true);
}

module socket_recess_cut(){
  // Cut from the FRONT face downwards into the plate
  translate([socket_recess_offset_x,
             socket_recess_offset_y,
             plate_T/2 - socket_recess_D/2])
    rounded_box(socket_recess_W, socket_recess_H, socket_recess_D + overlap, recess_corner_R, center=true);
}

module socket_inner_recess_cut(){
  inner_w = socket_recess_W - 10;
  inner_h = socket_recess_H - 10;
  inner_d = min(2.2, socket_recess_D + 0.9);
  translate([socket_recess_offset_x,
             socket_recess_offset_y,
             plate_T/2 - inner_d/2])
    rounded_box(inner_w, inner_h, inner_d + overlap, max(1.5, recess_corner_R-1), center=true);
}

module uk_pin_apertures_cut(){
  // Place cutting solids centered at z=0 so they cut through the plate.
  translate([socket_recess_offset_x, socket_recess_offset_y, 0]){
    // Earth
    translate([0, earth_offset_y, 0])
      cube([earth_w, earth_h, aperture_depth], center=true);

    // Live/Neutral
    translate([-pin_spacing_x/2, pin_offset_y, 0])
      cube([pin_bot_w, pin_bot_h, aperture_depth], center=true);
    translate([ pin_spacing_x/2, pin_offset_y, 0])
      cube([pin_bot_w, pin_bot_h, aperture_depth], center=true);

    // Shutter hint slots (thin cut-through)
    shutter_w = 10;
    shutter_h = 2.2;
    translate([-pin_spacing_x/2, pin_offset_y + pin_bot_h/2 - 3, 0])
      cube([shutter_w, shutter_h, aperture_depth], center=true);
    translate([ pin_spacing_x/2, pin_offset_y + pin_bot_h/2 - 3, 0])
      cube([shutter_w, shutter_h, aperture_depth], center=true);
  }
}

module switch_aperture_cut(){
  pocket_d = min(1.2, plate_T*0.6);
  translate([switch_offset_x,
             switch_offset_y,
             plate_T/2 - pocket_d/2])
    rounded_box(switch_W + 2*switch_aperture_clearance,
                switch_H + 2*switch_aperture_clearance,
                pocket_d + overlap,
                1.5,
                center=true);
}

module screw_hole_cut(pos){
  translate(pos)
    cylinder(r=screw_hole_d/2, h=plate_T + 2*overlap, center=true);
}

module screw_countersink_cut(pos){
  // Countersink on front face only
  translate([pos[0], pos[1], plate_T/2 - screw_csk_depth/2])
    cylinder(r1=screw_csk_d/2, r2=screw_hole_d/2, h=screw_csk_depth + overlap, center=true);
}

module switch_rocker(){
  // Rocker sits on top of plate, overlapping slightly to ensure connection
  rocker_r = 2;
  translate([switch_offset_x,
             switch_offset_y,
             plate_T/2 + switch_T/2 - overlap])
    rounded_box(switch_W, switch_H, switch_T, rocker_r, center=true);
}

module switch_indicator_window_cut(){
  translate([switch_offset_x,
             switch_offset_y + switch_H/2 - indicator_inset_from_top - indicator_H/2,
             plate_T/2 + switch_T/2 - overlap])
    cube([indicator_W, indicator_H, switch_T + 2*overlap], center=true);
}

module rocker_bevel_cut(){
  // Create a rocker-like top by shaving two opposite edges
  shave = 1.2;
  zc = plate_T/2 + switch_T/2 - overlap;
  translate([switch_offset_x, switch_offset_y, zc]){
    translate([0, switch_H/2 - shave/2, 0])
      rotate([45,0,0])
        cube([switch_W + 2*overlap, shave*2, switch_T + 4*overlap], center=true);
    translate([0, -switch_H/2 + shave/2, 0])
      rotate([-45,0,0])
        cube([switch_W + 2*overlap, shave*2, switch_T + 4*overlap], center=true);
  }
}

module socket_bezel(){
  // Raised outline inside the recess to make the socket recognizable
  bezel_w = socket_recess_W - 2*socket_bezel_inset;
  bezel_h = socket_recess_H - 2*socket_bezel_inset;
  bezel_r = max(1.5, recess_corner_R - 1.5);

  // Place on front face with overlap into plate so it is connected
  translate([socket_recess_offset_x,
             socket_recess_offset_y,
             plate_T/2 + socket_bezel_h/2 - overlap])
    difference(){
      rounded_box(bezel_w, bezel_h, socket_bezel_h, bezel_r, center=true);
      rounded_box(bezel_w - 6, bezel_h - 6, socket_bezel_h + 2*overlap, max(1, bezel_r-1), center=true);
    }
}

module socket_aperture_bezels(){
  // Subtle raised rims around the three main apertures to read as a socket.
  // These are CONNECTED to the plate by overlapping into it.
  zc = plate_T/2 + aperture_bezel_h/2 - overlap;

  translate([socket_recess_offset_x, socket_recess_offset_y, zc]){
    // Earth bezel
    translate([0, earth_offset_y, 0])
      difference(){
        rounded_box(earth_w + 6, earth_h + 6, aperture_bezel_h, aperture_bezel_r, center=true);
        cube([earth_w + 1.2, earth_h + 1.2, aperture_bezel_h + 2*overlap], center=true);
      }

    // Live/Neutral bezels
    for (sx = [-pin_spacing_x/2, pin_spacing_x/2]){
      translate([sx, pin_offset_y, 0])
        difference(){
          rounded_box(pin_bot_w + 6, pin_bot_h + 6, aperture_bezel_h, aperture_bezel_r, center=true);
          cube([pin_bot_w + 1.2, pin_bot_h + 1.2, aperture_bezel_h + 2*overlap], center=true);
        }
    }
  }
}

module backbox(){
  // Connected to back of plate with slight overlap
  translate([0, 0, -plate_T/2 - backbox_D/2 + overlap])
    rounded_box(backbox_W, backbox_H, backbox_D, 2, center=true);
}

// -------------------- Build --------------------
module plate_with_features(){
  difference(){
    faceplate();

    // Socket recess + inner well
    socket_recess_cut();
    socket_inner_recess_cut();

    // UK pin apertures (cut-through)
    uk_pin_apertures_cut();

    // Switch pocket
    switch_aperture_cut();

    // Screw holes + countersinks
    screw_hole_cut([-screw_hole_spacing/2, screw_hole_offset_y, 0]);
    screw_hole_cut([ screw_hole_spacing/2, screw_hole_offset_y, 0]);
    screw_countersink_cut([-screw_hole_spacing/2, screw_hole_offset_y, 0]);
    screw_countersink_cut([ screw_hole_spacing/2, screw_hole_offset_y, 0]);
  }
}

module rocker_with_window(){
  difference(){
    switch_rocker();
    switch_indicator_window_cut();
    rocker_bevel_cut();
  }
}

// Final: ONE connected solid (union of connected parts)
union(){
  plate_with_features();

  // Socket recognizability features (connected via overlap)
  socket_bezel();
  socket_aperture_bezels();

  // Switch (connected via overlap)
  rocker_with_window();

  // Backbox (connected via overlap)
  backbox();
}