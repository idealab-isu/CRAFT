// Dimension-calibrated (target: 96.60 x 19.00 x 123.00 mm)
scale([0.947088, 1.055556, 0.756923])
{
// Fixed: connected, braced/open diamond loop + integrated eyelets + connected end boss
// Bounding box target: 96.6 x 19.0 x 123.0 mm (X x Y x Z)

$fn = 96;

// Parameters
bbox_X = 96.6;
bbox_Y = 19.0;
bbox_Z = 123.0;

plate_t = 8.0;          // main thickness (Y direction)
spine_w = 14.0;         // spine width (X)
spine_Z = 123.0;        // overall length (Z)

diamond_center_Z = 62.0;
diamond_W = 86.0;       // diamond overall width (X)
diamond_H = 70.0;       // diamond overall height (Z)
brace_w = 8.0;          // frame/brace width

eyelet_OD = 16.0;
eyelet_ID = 8.0;
eyelet_t  = plate_t;    // eyelets same thickness as plate

spine_eyelet_spacing = 28.0;
spine_eyelet_offset_top = 18.0;

boss_D = 18.0;
boss_L = 10.0;

overlap = 1.0;

// Helpers
function z_top() =  bbox_Z/2;
function z_bot() = -bbox_Z/2;

module ring_y(od, id, h) {
  // Ring axis along Y (thickness direction), centered at origin
  difference() {
    cylinder(r=od/2, h=h, center=true);
    cylinder(r=id/2, h=h + 2*overlap, center=true);
  }
}

module spine_main() {
  cube([spine_w, plate_t, spine_Z], center=true);
}

module diamond_frame_2d() {
  // Outer diamond minus inner diamond => open loop
  difference() {
    polygon(points=[
      [ diamond_W/2, 0],
      [ 0,          diamond_H/2],
      [-diamond_W/2, 0],
      [ 0,         -diamond_H/2]
    ]);
    polygon(points=[
      [ diamond_W/2 - brace_w, 0],
      [ 0,          diamond_H/2 - brace_w],
      [-diamond_W/2 + brace_w, 0],
      [ 0,         -diamond_H/2 + brace_w]
    ]);
  }
}

module diamond_loop() {
  // Extrude in Y, place in XZ plane at diamond_center_Z
  translate([0, 0, diamond_center_Z])
    rotate([90, 0, 0])
      linear_extrude(height=plate_t, center=true)
        diamond_frame_2d();
}

module diamond_internal_braces() {
  // Two diagonal struts inside the diamond, leaving it linkage-like (not a solid plate)
  // Struts are rectangles in 2D, rotated, then extruded in Y.
  // Keep them within the inner opening by using a slightly smaller length.
  inner_W = diamond_W - 2*brace_w;
  inner_H = diamond_H - 2*brace_w;
  strut_len = min(inner_W, inner_H) * 0.92;
  strut_w   = brace_w;

  translate([0, 0, diamond_center_Z])
    rotate([90, 0, 0])
      linear_extrude(height=plate_t, center=true)
        union() {
          rotate( 45) square([strut_len, strut_w], center=true);
          rotate(-45) square([strut_len, strut_w], center=true);
        }
}

module diamond_corner_eyelets() {
  // Eyelets at the four diamond corners, integrated by overlapping into the frame
  // Diamond corners in XZ:
  // East/West: (±W/2, 0), North/South: (0, ±H/2)
  // Place at diamond_center_Z in Z.
  union() {
    translate([ diamond_W/2, 0, diamond_center_Z]) ring_y(eyelet_OD, eyelet_ID, eyelet_t);
    translate([-diamond_W/2, 0, diamond_center_Z]) ring_y(eyelet_OD, eyelet_ID, eyelet_t);
    translate([0, 0, diamond_center_Z + diamond_H/2]) ring_y(eyelet_OD, eyelet_ID, eyelet_t);
    translate([0, 0, diamond_center_Z - diamond_H/2]) ring_y(eyelet_OD, eyelet_ID, eyelet_t);
  }
}

module spine_eyelets() {
  // Three eyelets along the spine, integrated by overlap
  z1 = z_top() - spine_eyelet_offset_top;
  z2 = z1 - spine_eyelet_spacing;
  z3 = z2 - spine_eyelet_spacing;

  union() {
    translate([0, 0, z1]) ring_y(eyelet_OD, eyelet_ID, eyelet_t);
    translate([0, 0, z2]) ring_y(eyelet_OD, eyelet_ID, eyelet_t);
    translate([0, 0, z3]) ring_y(eyelet_OD, eyelet_ID, eyelet_t);
  }
}

module spine_to_diamond_gusset() {
  // Ensure robust connection between spine and diamond loop
  // A short widening block centered at diamond_center_Z
  gusset_z = diamond_center_Z;
  gusset_h = diamond_H*0.35;
  gusset_w = spine_w + 2*brace_w;

  translate([0, 0, gusset_z])
    cube([gusset_w, plate_t, gusset_h], center=true);
}

module end_boss_cap() {
  // Boss at the TOP end of the spine, axis along Y, connected by overlap
  // Place so its top is near z_top(), but still within bbox_Z.
  zc = z_top() - boss_D/2; // keep within Z while looking like a cap
  translate([0, 0, zc])
    cylinder(r=boss_D/2, h=boss_L, center=true);
}

module model() {
  // One connected solid: spine + diamond loop + braces + eyelets + gusset + boss
  union() {
    spine_main();
    diamond_loop();
    diamond_internal_braces();
    spine_to_diamond_gusset();
    diamond_corner_eyelets();
    spine_eyelets();
    end_boss_cap();
  }
}

// Final
model();
}
