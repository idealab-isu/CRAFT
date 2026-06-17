$fn = 96;

// Parameters (mm)
body_d = 0.8; //[0.4:1.6:0.01]
body_h = 4.7; //[2.35:9.4:0.05]

top_bezel_h = 0.35; //[0.18:0.7:0.01]
top_bezel_overhang = 0.08; //[0.04:0.16:0.005]

base_flange_h = 0.35; //[0.18:0.7:0.01]
base_flange_overhang = 0.12; //[0.06:0.24:0.005]

thread_h = 1.2; //[0.6:2.4:0.05]
thread_overhang = 0.05; //[0.02:0.1:0.005]

lever_d = 0.25; //[0.12:0.5:0.01]
lever_h = 1.5; //[0.75:3:0.05]
lever_tilt_deg = 12; //[0:25:1]

terminal_w = 0.18; //[0.09:0.36:0.01]
terminal_t = 0.08; //[0.04:0.16:0.005]
terminal_h = 0.7; //[0.35:1.4:0.05]
terminal_spacing = 0.28; //[0.14:0.56:0.01]

grip_count = 12; //[6:24:1]
grip_rib_depth = 0.03; //[0.015:0.06:0.002]
grip_rib_w = 0.08; //[0.04:0.16:0.005]
grip_h = 2.2; //[1.1:4.4:0.05]

mark_groove_w = 0.12; //[0.06:0.24:0.01]
mark_groove_d = 0.03; //[0.015:0.06:0.002]
mark_groove_h = 0.25; //[0.12:0.5:0.01]

overlap = 0.02; //[0.01:0.08:0.005]

// Derived
body_r = body_d/2;
top_bezel_r = body_r + top_bezel_overhang;
base_flange_r = body_r + base_flange_overhang;
thread_r = body_r + thread_overhang;

// Keep grip ribs within overall 0.8mm diameter envelope
rib_outer_r = body_r;
rib_inner_r = max(0, rib_outer_r - grip_rib_depth);
rib_center_r = (rib_outer_r + rib_inner_r)/2;
rib_radial_thickness = max(0.001, rib_outer_r - rib_inner_r);

// Z locations (centered model)
z_top = body_h/2;
z_bot = -body_h/2;

z_top_bezel_c = z_top - top_bezel_h/2 + overlap;
z_base_flange_c = z_bot + base_flange_h/2 - overlap;
z_thread_c = z_top - top_bezel_h - thread_h/2 + overlap;

// Lever: ensure it starts at the top surface (touch/overlap), not centered through it
z_lever_base = z_top - overlap;
z_lever_c = z_lever_base + lever_h/2;

// Terminals: ensure they start at the bottom surface (touch/overlap), not centered through it
z_term_top = z_bot + overlap;
z_term_c = z_term_top - terminal_h/2;

// Marking groove location (near top, below bezel)
z_mark_c = z_top - top_bezel_h - mark_groove_h/2;

// Main body
module main_body() {
  cylinder(r=body_r, h=body_h, center=true);
}

// Top bezel
module top_bezel() {
  translate([0, 0, z_top_bezel_c])
    cylinder(r=top_bezel_r, h=top_bezel_h, center=true);
}

// Base flange
module base_flange() {
  translate([0, 0, z_base_flange_c])
    cylinder(r=base_flange_r, h=base_flange_h, center=true);
}

// Mounting threads (simple cylinder representation)
module mounting_threads() {
  translate([0, 0, z_thread_c])
    cylinder(r=thread_r, h=thread_h, center=true);
}

// Toggle lever (connected to top)
module toggle_lever() {
  translate([0, 0, z_lever_c])
    rotate([0, lever_tilt_deg, 0])
      cylinder(r=lever_d/2, h=lever_h, center=true);
}

// Electrical terminals (connected to bottom)
module electrical_terminals() {
  union() {
    translate([ terminal_spacing/2, 0, z_term_c])
      cube([terminal_w, terminal_t, terminal_h], center=true);
    translate([-terminal_spacing/2, 0, z_term_c])
      cube([terminal_w, terminal_t, terminal_h], center=true);
  }
}

// Grip ribs (kept within body diameter so silhouette remains cylindrical)
module grip_ribs() {
  for (i = [0:grip_count-1]) {
    rotate([0, 0, i*360/grip_count])
      translate([rib_center_r - overlap, 0, 0])
        cube([rib_radial_thickness + 2*overlap, grip_rib_w, grip_h], center=true);
  }
}

// Engraved markings (subtractive grooves on the top bezel area)
module engraved_markings() {
  union() {
    translate([0, 0, z_mark_c])
      cube([2*(top_bezel_r + overlap), mark_groove_w, mark_groove_h], center=true);
    translate([0, 0, z_mark_c])
      rotate([0, 0, 90])
        cube([2*(top_bezel_r + overlap), mark_groove_w, mark_groove_h], center=true);
  }
}

// Final: one connected solid, with grooves subtracted
difference() {
  union() {
    main_body();
    top_bezel();
    base_flange();
    mounting_threads();
    toggle_lever();
    electrical_terminals();
    grip_ribs();
  }

  // Shallow grooves only near the outer surface of the top bezel
  intersection() {
    engraved_markings();
    translate([0,0,z_mark_c])
      difference() {
        cylinder(r=top_bezel_r + overlap, h=mark_groove_h + 2*overlap, center=true);
        cylinder(r=top_bezel_r - mark_groove_d, h=mark_groove_h + 4*overlap, center=true);
      }
  }
}