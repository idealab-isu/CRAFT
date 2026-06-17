// 40mm x 40mm x 9.5mm Centrifugal blower (single connected solid)

// Parameters
overall_width = 40; //[20:80:0.5]
overall_length = 40; //[20:80:0.5]
overall_depth = 9.5; //[5:19:0.1]

casing_wall_thickness = 1.5; //[0.8:3:0.1]
top_thickness = 1; //[0.6:2:0.1]
base_thickness = 1; //[0.6:2:0.1]

inlet_bore_diameter = 20; //[10:40:0.5]
impeller_outer_diameter = 30; //[15:60:0.5]

outlet_width = 12; //[6:24:0.5]
outlet_height = 6; //[3:12:0.5]
outlet_offset_from_center = 10; //[0:20:0.5]
outlet_length = 10; //[5:25:0.5]

mount_hole_diameter = 3; //[2:6:0.25]
mount_pitch = 32; //[20:50:0.5]

clearance_radial = 0.5; //[0.2:1.5:0.05]
clearance_axial = 0.3; //[0.1:1:0.05]
overlap = 1; //[0.5:2:0.1]

$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_rect_2d(w, h, r) {
  r2 = clamp(r, 0, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
  }
}

module blower_40x40x9p5() {
  inner_h = overall_depth - top_thickness - base_thickness;

  // Volute/impeller cavity sizing
  imp_r = impeller_outer_diameter/2;
  cav_r = imp_r + clearance_radial;
  outer_r = cav_r + casing_wall_thickness;

  // Keep volute inside 40x40 footprint
  max_outer_r = min(overall_width, overall_length)/2 - 0.8;
  outer_r2 = min(outer_r, max_outer_r);
  cav_r2 = outer_r2 - casing_wall_thickness;

  // Outlet wall thickness and inner opening
  out_wall = casing_wall_thickness;
  out_w_in = max(0.1, outlet_width - 2*out_wall);
  out_h_in = max(0.1, outlet_height - 2*out_wall);

  // Place outlet on +X side, connected to casing with overlap
  out_x = overall_width/2 + outlet_length/2 - overlap;
  out_y = outlet_offset_from_center;

  // Inlet on top cover
  inlet_r = inlet_bore_diameter/2;

  // Volute "tongue" (cutout) near outlet to suggest scroll
  tongue_w = casing_wall_thickness * 1.2;
  tongue_len = outer_r2 * 0.9;

  // Main solid: base + top + casing ring + outlet duct
  difference() {
    union() {
      // Base plate
      translate([0, 0, -overall_depth/2 + base_thickness/2])
        cube([overall_width, overall_length, base_thickness], center=true);

      // Top cover plate
      translate([0, 0, overall_depth/2 - top_thickness/2])
        cube([overall_width, overall_length, top_thickness], center=true);

      // Casing body (ring around volute cavity), centered in Z between plates
      translate([0, 0, 0])
        difference() {
          // Outer block to keep square blower form factor
          cube([overall_width, overall_length, inner_h], center=true);

          // Carve circular cavity (volute cavity)
          cylinder(r=cav_r2, h=inner_h + 2*overlap, center=true);

          // Carve a small "tongue" region near outlet to imply scroll/tongue
          // (removes material from cavity side, leaving a tongue feature)
          rotate([0,0,0])
            translate([outer_r2 - tongue_len/2, 0, 0])
              cube([tongue_len, tongue_w, inner_h + 2*overlap], center=true);
        }

      // Outlet duct (outer shell)
      translate([out_x, out_y, 0])
        cube([outlet_length, outlet_width, outlet_height], center=true);
    }

    // Hollow the outlet duct (inner passage)
    translate([out_x, out_y, 0])
      cube([outlet_length + 2*overlap, out_w_in, out_h_in], center=true);

    // Open connection from volute cavity to outlet (cut a window through casing wall)
    // Window sits at +X edge of cavity and overlaps into outlet.
    window_len = casing_wall_thickness + 2*overlap;
    translate([outer_r2 - casing_wall_thickness/2, out_y, 0])
      cube([window_len, out_w_in, out_h_in], center=true);

    // Inlet bore through top cover only (centrifugal blower top inlet)
    translate([0, 0, overall_depth/2 - top_thickness/2])
      cylinder(r=inlet_r, h=top_thickness + 2*overlap, center=true);

    // Mounting holes through entire thickness
    for (x = [-1, 1], y = [-1, 1])
      translate([x*mount_pitch/2, y*mount_pitch/2, 0])
        cylinder(r=mount_hole_diameter/2, h=overall_depth + 2*overlap, center=true);
  }
}

blower_40x40x9p5();