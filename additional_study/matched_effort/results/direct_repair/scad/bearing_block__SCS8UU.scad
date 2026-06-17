$fn = 96;

// Linear bearing block for 6.0mm shaft
// Overall block size: 34.0mm x 30.0mm (X x Y)
// Thickness chosen as a reasonable default for a small bearing block.
shaft_d = 6.0;

block_x = 34.0;
block_y = 30.0;
block_z = 16.0;

corner_r = 3.0;

// Through bore for shaft (slight clearance)
shaft_clear = 0.25;
bore_d = shaft_d + shaft_clear;

// Split clamp slot
slot_w = 2.0;          // width of slit
slot_depth = block_y;  // through in Y

// Clamp screw (M3) across the slit (along Y), with nut trap
clamp_screw_d = 3.2;
clamp_head_d  = 6.2;
clamp_head_h  = 3.0;

nut_flat = 5.7;  // M3 hex across flats
nut_th   = 2.6;

// Mounting holes (M4) on base, 4 holes
mount_screw_d = 4.3;
mount_counterbore_d = 8.0;
mount_counterbore_h = 3.0;

mount_margin_x = 6.0;
mount_margin_y = 6.0;

module rounded_block(x,y,z,r){
  r2 = min(r, min(x,y)/2 - 0.01);
  linear_extrude(height=z)
    offset(r=r2)
      square([x-2*r2, y-2*r2], center=true);
}

module hex_prism(af, h){
  // Regular hex with across-flats = af
  // circumradius R = af / sqrt(3)
  R = af / sqrt(3);
  cylinder(h=h, r=R, $fn=6);
}

difference(){
  // Body
  translate([0,0,block_z/2])
    rounded_block(block_x, block_y, block_z, corner_r);

  // Shaft bore along X
  translate([0,0,block_z/2])
    rotate([0,90,0])
      cylinder(h=block_x+2, d=bore_d, center=true);

  // Clamp slit: from top down to bore center, through Y
  // Place slit at X=0, centered in Y, starting at top surface
  translate([0,0,block_z/2])
    translate([0,0,block_z/2 - (block_z/2)]) // no-op, keeps intent clear
      translate([0,0,block_z/2])
        ; // placeholder

  // Actual slit volume
  // Cut a thin slot from top surface down past bore center
  slit_z = block_z/2 + 1.0; // depth from top to slightly below center
  translate([0,0,block_z - slit_z/2])
    cube([block_x+2, slot_w, slit_z], center=true);

  // Clamp screw hole across Y near top, above bore
  clamp_z = block_z*0.72;
  translate([0,0,clamp_z])
    rotate([90,0,0])
      cylinder(h=block_y+2, d=clamp_screw_d, center=true);

  // Counterbore for screw head on +Y side
  translate([0, block_y/2 - clamp_head_h/2, clamp_z])
    rotate([90,0,0])
      cylinder(h=clamp_head_h+0.2, d=clamp_head_d, center=true);

  // Nut trap on -Y side
  translate([0, -block_y/2 + nut_th/2, clamp_z])
    rotate([90,0,0])
      hex_prism(nut_flat, nut_th+0.2);

  // Mounting holes (4) through Z with counterbores on bottom
  for (sx = [-1, 1], sy = [-1, 1]){
    xh = sx*(block_x/2 - mount_margin_x);
    yh = sy*(block_y/2 - mount_margin_y);

    // Through hole
    translate([xh, yh, block_z/2])
      cylinder(h=block_z+2, d=mount_screw_d, center=true);

    // Counterbore on bottom
    translate([xh, yh, mount_counterbore_h/2])
      cylinder(h=mount_counterbore_h+0.2, d=mount_counterbore_d, center=true);
  }
}