// IEC fused inlet (old style) - connected solid, overall face 36x27mm
// Fixes:
// - Adds recognizable IEC C14 face details (pin openings + earth slot + inner bezel recess)
// - Adds clearer fused inlet module features (fuse drawer pocket + cap lip, switch pocket + rocker)
// - Keeps overall faceplate size exactly 36.0 x 27.0 mm
// - Ensures ONE connected solid (all additive parts overlap main body/flange; all cutouts are subtractive)

$fn = 64;

// -------------------- Parameters --------------------
face_W = 36.0; //[18.0:72.0:0.5]
face_H = 27.0; //[13.5:54.0:0.5]
flange_t = 2.5; //[1.25:5.0:0.1]

body_D = 30.0; //[15.0:60.0:0.5]
body_W = 28.0; //[14.0:56.0:0.5]
body_H = 22.0; //[11.0:44.0:0.5]

panel_t = 2.0; //[1.0:4.0:0.1]
cutout_W = 27.5; //[13.75:55.0:0.5]
cutout_H = 20.5; //[10.25:41.0:0.5]

clip_W = 6.0; //[3.0:12.0:0.5]
clip_H = 2.0; //[1.0:4.0:0.1]
clip_overhang = 1.2; //[0.6:2.4:0.1]

eps = 0.25; //[0.1:1.0:0.05]

screw_hole_d = 3.2; //[2.0:6.0:0.1]
screw_edge_margin = 5.0; //[3.0:10.0:0.5]

fuse_W = 12.0; //[6.0:24.0:0.5]
fuse_H = 6.0; //[3.0:12.0:0.5]
fuse_D = 10.0; //[5.0:20.0:0.5]
fuse_cap_t = 1.5; //[0.8:3.0:0.1]

switch_W = 14.0; //[7.0:28.0:0.5]
switch_H = 10.0; //[5.0:20.0:0.5]
switch_D = 4.0; //[2.0:8.0:0.5]

blade_W = 6.3; //[3.0:12.6:0.1]
blade_T = 0.8; //[0.4:1.6:0.1]
blade_L = 10.0; //[5.0:20.0:0.5]

strain_W = 10.0; //[5.0:20.0:0.5]
strain_H = 6.0; //[3.0:12.0:0.5]
strain_D = 6.0; //[3.0:12.0:0.5]

label_W = 10.0; //[5.0:20.0:0.5]
label_H = 4.0; //[2.0:8.0:0.5]
label_depth = 0.8; //[0.4:1.6:0.1]

chamfer = 0.8; //[0.4:1.6:0.1]

// IEC C14 face detail parameters (visual, not a certified drawing)
iec_bezel_W = 24.0;
iec_bezel_H = 18.0;
iec_bezel_r = 2.0;
iec_bezel_recess = 1.2;     // recess depth into front face

pin_slot_W = 2.2;           // rectangular slot width
pin_slot_H = 6.2;           // rectangular slot height
pin_pitch = 10.0;           // L-N spacing
earth_slot_W = 6.0;
earth_slot_H = 2.6;
earth_y = -4.8;             // earth below pins

// -------------------- Helpers --------------------
module rrect2d(w,h,r){
  r2 = min(r, min(w,h)/2);
  hull(){
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(w/2-r2), sy*(h/2-r2)]) circle(r=r2);
  }
}

module rrect3d(w,h,t,r){
  linear_extrude(height=t, center=true) rrect2d(w,h,r);
}

// -------------------- Coordinate convention --------------------
// Front face outer surface at z=0, body extends to negative z.
z_flange_center = -flange_t/2;
z_body_center   = -(flange_t + body_D/2 - eps); // overlap into flange
z_body_front    = z_body_center + body_D/2;
z_body_back     = z_body_center - body_D/2;

// -------------------- Base solids --------------------
module front_faceplate_flange(){
  translate([0,0,z_flange_center])
    rrect3d(face_W, face_H, flange_t, chamfer);
}

module main_inlet_housing_body(){
  translate([0,0,z_body_center])
    rrect3d(body_W, body_H, body_D, 1.0);
}

module rear_body_extension(){
  ext_D = body_D*0.35;
  ext_W = body_W*0.85;
  ext_H = body_H*0.85;
  z_ext_center = z_body_back - ext_D/2 + eps; // overlap into main body
  translate([0,0,z_ext_center])
    rrect3d(ext_W, ext_H, ext_D, 0.8);
}

// -------------------- Subtractive details --------------------
module mounting_screw_hole(x){
  translate([x,0,z_flange_center])
    cylinder(d=screw_hole_d, h=flange_t + 2*eps, center=true);
}

module label_recess(x,y){
  translate([x,y,-label_depth/2 + eps])
    cube([label_W, label_H, label_depth + 2*eps], center=true);
}

// IEC bezel recess (gives recognizable inlet face depth)
module iec_bezel_recess(){
  // recess into front surface; keep within flange thickness
  t = min(iec_bezel_recess, flange_t - 0.3);
  translate([0,0,-t/2 + eps])
    rrect3d(iec_bezel_W, iec_bezel_H, t + 2*eps, iec_bezel_r);
}

// IEC pin openings (through flange and slightly into body)
module iec_pin_openings(){
  t = flange_t + 4*eps;

  // L and N slots (vertical rectangles)
  for (sx=[-1,1]){
    translate([sx*pin_pitch/2, 2.0, z_flange_center])
      cube([pin_slot_W, pin_slot_H, t], center=true);
  }

  // Earth slot (horizontal rectangle)
  translate([0, earth_y, z_flange_center])
    cube([earth_slot_W, earth_slot_H, t], center=true);
}

// Fuse drawer pocket (recess into front face)
module fuse_drawer_pocket(){
  x = -(face_W/2 - fuse_W/2 - eps);
  y =  (face_H/2 - fuse_H/2 - eps);

  // pocket depth into flange (not through)
  pocket_t = min(flange_t - 0.4, 1.6);
  translate([x,y,-pocket_t/2 + eps])
    cube([fuse_W*0.92, fuse_H*0.92, pocket_t + 2*eps], center=true);
}

// Switch pocket (recess into front face)
module switch_pocket(){
  x = (face_W/2 - switch_W/2 - eps);
  y = (face_H/2 - switch_H/2 - eps);

  pocket_t = min(flange_t - 0.4, 1.4);
  translate([x,y,-pocket_t/2 + eps])
    cube([switch_W*0.92, switch_H*0.92, pocket_t + 2*eps], center=true);
}

// -------------------- Additive features (must be connected) --------------------
module snap_in_retention_clip(side=1){
  // side = -1 left, +1 right
  x = side*(body_W/2 + clip_overhang/2 - eps);
  z = z_body_front - (panel_t + clip_H/2) + eps; // overlaps body
  translate([x,0,z])
    cube([clip_overhang + 2*eps, clip_W, clip_H], center=true);
}

module fuse_drawer(){
  // protruding outward (positive z) and overlapping flange
  x = -(face_W/2 - fuse_W/2 - eps);
  y =  (face_H/2 - fuse_H/2 - eps);
  z =  fuse_D/2 - eps; // overlaps front surface at z=0
  translate([x,y,z])
    cube([fuse_W, fuse_H, fuse_D], center=true);
}

module fuse_cap(){
  x = -(face_W/2 - fuse_W/2 - eps);
  y =  (face_H/2 - fuse_H/2 - eps);
  // cap overlaps drawer slightly to ensure connectivity
  z = fuse_D + fuse_cap_t/2 - 1.0*eps;
  translate([x,y,z])
    cube([fuse_W*0.9, fuse_H*0.9, fuse_cap_t], center=true);
}

module switch_rocker(){
  x = (face_W/2 - switch_W/2 - eps);
  y = (face_H/2 - switch_H/2 - eps);
  z = switch_D/2 - eps; // overlaps flange
  // slight top bevel via hull of two boxes
  translate([x,y,z])
    hull(){
      cube([switch_W, switch_H, switch_D], center=true);
      translate([0,0,switch_D*0.25])
        cube([switch_W*0.92, switch_H*0.92, switch_D*0.6], center=true);
    }
}

module terminal_blade(x,y){
  z = z_body_back - blade_L/2 + eps; // overlaps body back
  translate([x,y,z])
    cube([blade_T, blade_W, blade_L], center=true);
}

module strain_relief_features(){
  y = -(body_H/2 - strain_H/2 - eps);
  z = z_body_back - strain_D/2 + eps; // overlaps body
  translate([0,y,z])
    cube([strain_W, strain_H, strain_D], center=true);
}

// Connected reference "panel cutout" block (kept connected, not floating)
module panel_cutout_profile(){
  z_panel_center = z_body_front - panel_t/2 + eps; // overlaps body
  translate([0,0,z_panel_center])
    rrect3d(cutout_W, cutout_H, panel_t, 0.6);
}

// -------------------- Faceplate with holes/recesses --------------------
module faceplate_with_details(){
  difference(){
    front_faceplate_flange();

    // IEC face details
    iec_bezel_recess();
    iec_pin_openings();

    // Fuse + switch pockets
    fuse_drawer_pocket();
    switch_pocket();

    // Mounting holes
    mounting_screw_hole(-(face_W/2 - screw_edge_margin));
    mounting_screw_hole( (face_W/2 - screw_edge_margin));

    // Label recesses (bottom corners)
    label_recess(-(face_W/2 - label_W/2 - eps), -(face_H/2 - label_H/2 - eps));
    label_recess( (face_W/2 - label_W/2 - eps), -(face_H/2 - label_H/2 - eps));
  }
}

// -------------------- Final connected model --------------------
module complete_model(){
  union(){
    faceplate_with_details();
    main_inlet_housing_body();
    rear_body_extension();

    snap_in_retention_clip(-1);
    snap_in_retention_clip( 1);

    fuse_drawer();
    fuse_cap();
    switch_rocker();

    // Rear terminals (L, N, E) - all overlap body back
    terminal_blade(-pin_pitch/2,  0);
    terminal_blade( pin_pitch/2,  0);
    terminal_blade(0,            -pin_pitch/2);

    strain_relief_features();

    // Connected reference cutout block
    panel_cutout_profile();
  }
}

// Output
complete_model();