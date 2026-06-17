$fn = 96;

// Target overall size (must be verifiable)
overall_length_mm = 30.0;
overall_width_mm  = 30.0;
overall_depth_mm  = 10.1;

// Construction parameters
wall_thickness       = 1.2;
base_plate_thickness = 1.2;
top_cover_thickness  = 1.0;
internal_clearance   = 0.6;

axis_offset_x = 12.0;   // from left edge
axis_offset_y = 15.0;   // from bottom edge

inlet_bore_diameter     = 10.0;
impeller_outer_diameter = 18.0;
impeller_height         = 6.8;

hub_diameter = 6.0;
hub_height   = 6.8;

outlet_width  = 7.0;
outlet_height = 6.0;
outlet_length = 10.0;

mount_hole_diameter    = 2.4;
mount_hole_edge_margin = 3.5;

corner_radius = 2.0;
overlap = 0.8;

// ---------- helpers ----------
module rounded_rect_2d(l, w, r) {
  r2 = min(r, min(l, w)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(l/2 - r2), sy*(w/2 - r2)]) circle(r=r2);
  }
}

module rounded_box(l, w, h, r) {
  linear_extrude(height=h, center=true)
    rounded_rect_2d(l, w, r);
}

function clamp(v, lo, hi) = max(lo, min(hi, v));

// 2D annular sector (ring slice) for volute cavity
module annular_sector_2d(r_in, r_out, a0, a1) {
  // a0..a1 in degrees, CCW, assumes a1>a0
  difference() {
    intersection() {
      circle(r=r_out);
      polygon(points=[
        [0,0],
        [r_out*cos(a0), r_out*sin(a0)],
        [r_out*cos(a1), r_out*sin(a1)]
      ]);
    }
    circle(r=r_in);
  }
}

// ---------- impeller (inside housing, connected via hub to base) ----------
module impeller() {
  z0 = -overall_depth_mm/2 + base_plate_thickness; // top of base plate
  zc = z0 + impeller_height/2;

  translate([-overall_length_mm/2 + axis_offset_x,
             -overall_width_mm/2  + axis_offset_y,
             zc])
  union() {
    // Hub (touches base plate via slight overlap)
    translate([0,0,-impeller_height/2 + hub_height/2 - overlap/2])
      cylinder(d=hub_diameter, h=hub_height + overlap, center=true);

    // Backing disk
    disk_t = 0.8;
    translate([0,0,-impeller_height/2 + disk_t/2])
      cylinder(d=impeller_outer_diameter - 1.0, h=disk_t, center=true);

    // Radial blades (protrude outward)
    num_blades = 9;
    blade_len = (impeller_outer_diameter/2) - (hub_diameter/2) - 0.6;
    blade_w   = 1.2;
    blade_h   = impeller_height - 1.2;

    for (i = [0:num_blades-1]) {
      ang = i*360/num_blades;
      rotate([0,0,ang])
        hull() {
          translate([hub_diameter/2 + 0.4, 0, 0])
            cube([1.0, blade_w, blade_h], center=true);

          translate([hub_diameter/2 + blade_len, blade_w*1.2, 0])
            cube([1.0, blade_w, blade_h], center=true);
        }
    }
  }
}

// ---------- housing (single connected solid with inlet + side outlet + internal cavity) ----------
module blower_housing() {
  cavity_h = overall_depth_mm - base_plate_thickness - top_cover_thickness;

  // Z positions
  z_base_c = -overall_depth_mm/2 + base_plate_thickness/2;
  z_top_c  =  overall_depth_mm/2 - top_cover_thickness/2;
  z_cav_c  = (z_base_c + z_top_c)/2;

  // Inlet axis position in XY
  ax = -overall_length_mm/2 + axis_offset_x;
  ay = -overall_width_mm/2  + axis_offset_y;

  // Radii
  imp_r   = impeller_outer_diameter/2;
  cav_r   = imp_r + internal_clearance;
  outer_r = cav_r + wall_thickness;

  // Outlet placement: on +X side, centered on inlet Y
  outlet_xc = overall_length_mm/2 - outlet_length/2;
  outlet_yc = ay;

  outlet_w_outer = outlet_width + 2*wall_thickness;
  outlet_h_outer = outlet_height + 2*wall_thickness;

  // Volute cavity: annular sector that grows toward the outlet
  // Choose outlet direction along +X (0 degrees). Start near -140 deg and wrap to +40 deg.
  a0 = -140;
  a1 =  40;

  // Inner/outer radii for volute cavity (keeps a "tongue" near the hub)
  vol_r_in  = max(hub_diameter/2 + 1.0, cav_r*0.55);
  vol_r_out = cav_r;

  // Outer shell (rounded square) + outlet duct + scroll bulge
  module outer_shell() {
    union() {
      // Outer body
      rounded_box(overall_length_mm, overall_width_mm, overall_depth_mm, corner_radius);

      // Side outlet duct (outer) - connected to body by overlap
      translate([outlet_xc, outlet_yc, z_cav_c])
        cube([outlet_length + overlap, outlet_w_outer, outlet_h_outer], center=true);

      // Scroll bulge around impeller (outer)
      translate([ax, ay, z_cav_c])
        cylinder(r=outer_r, h=overall_depth_mm, center=true);
    }
  }

  // Internal voids: cavity volume + inlet bore + outlet passage + volute cavity
  module inner_voids() {
    union() {
      // Main internal cavity (keeps walls/plates)
      translate([0,0,z_cav_c])
        rounded_box(overall_length_mm - 2*wall_thickness,
                    overall_width_mm  - 2*wall_thickness,
                    cavity_h + 2*overlap,
                    max(0, corner_radius - wall_thickness));

      // Volute cavity (annular sector) extruded through cavity height
      translate([ax, ay, z_cav_c])
        linear_extrude(height=cavity_h + 2*overlap, center=true)
          annular_sector_2d(vol_r_in, vol_r_out, a0, a1);

      // Outlet passage (inner) - overlaps into volute and out of body
      translate([outlet_xc, outlet_yc, z_cav_c])
        cube([outlet_length + 2*overlap, outlet_width, outlet_height], center=true);

      // Inlet bore through top cover into cavity
      translate([ax, ay, z_top_c])
        cylinder(d=inlet_bore_diameter, h=top_cover_thickness + 2*overlap, center=true);
    }
  }

  // Mounting holes (through entire body)
  module mount_holes() {
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x*(overall_length_mm/2 - mount_hole_edge_margin),
                 y*(overall_width_mm/2  - mount_hole_edge_margin),
                 0])
        cylinder(d=mount_hole_diameter, h=overall_depth_mm + 2*overlap, center=true);
    }
  }

  difference() {
    outer_shell();
    inner_voids();
    mount_holes();
  }
}

// ---------- assembly: ONE connected solid (housing + impeller inside, touching base) ----------
union() {
  blower_housing();
  impeller();
}