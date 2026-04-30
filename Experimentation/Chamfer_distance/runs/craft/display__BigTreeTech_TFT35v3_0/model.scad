// Parameters (mm)
primary_dimension_mm = 84.5; //[42.25:169:0.1]
bezel_width_mm = 84.5; //[42.25:169:0.1]
bezel_height_mm = 54.5; //[27.25:109:0.1]
bezel_thickness_mm = 4; //[2:8:0.1]
bezel_corner_radius_mm = 0.5; //[0.25:1:0.05]  // not fully modeled
window_margin_mm = 3; //[1.5:6:0.1]
pcb_recess_depth_mm = 1.6; //[0.8:3.2:0.1]
pcb_clearance_mm = 0.3; //[0.15:0.6:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
display_thickness_mm = 3.2; //[1.6:6.4:0.1]
pcb_width_mm = 78.5; //[39.25:157:0.1]
pcb_height_mm = 48.5; //[24.25:97:0.1]
window_width_mm = 78.5; //[39.25:157:0.1]
window_height_mm = 48.5; //[24.25:97:0.1]

// Quality
$fn=32;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  // Avoid minkowski; use offset on a centered square
  r2 = max(0, min(r, min(w, h)/2));
  offset(r=r2) square([w-2*r2, h-2*r2], center=true);
}

module screw_hole_through(d=3.0, h=10) {
  cylinder(d=d, h=h, center=true, $fn=24);
}

module pin_header_2row(cols=6, rows=2, pitch=2.54, pin_d=0.64, pin_h=3.0, body_h=2.5) {
  // Simple but recognizable: black plastic body + gold pins
  body_w = (cols-1)*pitch + 2.2;
  body_d = (rows-1)*pitch + 2.2;
  color([0.08,0.08,0.09]) translate([0,0,body_h/2])
    cube([body_w, body_d, body_h], center=true);

  color([0.80,0.65,0.20]) {
    for (c=[0:cols-1]) for (r=[0:rows-1]) {
      x = (c-(cols-1)/2)*pitch;
      y = (r-(rows-1)/2)*pitch;
      translate([x,y,-pin_h/2]) cylinder(d=pin_d, h=pin_h, center=true, $fn=12);
    }
  }
}

// ---------- Base shapes from plan ----------
module front_bezel_outer_shape() {
  // Plan: box centered at origin
  cube([bezel_width_mm, bezel_height_mm, bezel_thickness_mm], center=true);
}

module display_window_cutout_shape() {
  cube([bezel_width_mm - 2*window_margin_mm,
        bezel_height_mm - 2*window_margin_mm,
        bezel_thickness_mm + 2*overlap_mm], center=true);
}

module pcb_recess_cutout_shape() {
  translate([0,0,-bezel_thickness_mm/2 + pcb_recess_depth_mm/2])
    cube([bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm),
          bezel_height_mm - 2*(window_margin_mm + pcb_clearance_mm),
          pcb_recess_depth_mm + overlap_mm], center=true);
}

module pcb_base_shape() {
  translate([0,0,-bezel_thickness_mm/2 + pcb_thickness_mm/2 - overlap_mm])
    cube([bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm),
          bezel_height_mm - 2*(window_margin_mm + pcb_clearance_mm),
          pcb_thickness_mm], center=true);
}

module display_shape() {
  translate([0,0,-bezel_thickness_mm/2 + pcb_thickness_mm + display_thickness_mm/2 - overlap_mm])
    cube([bezel_width_mm - 2*window_margin_mm,
          bezel_height_mm - 2*window_margin_mm,
          display_thickness_mm], center=true);
}

module mod_shape() {
  translate([
    (bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm))/2
      - ((bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm)) * 0.35)/2
      - pcb_clearance_mm,
    0,
    -bezel_thickness_mm/2 + pcb_thickness_mm + (display_thickness_mm*0.6)/2 - overlap_mm
  ])
    cube([
      (bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm)) * 0.35,
      (bezel_height_mm - 2*(window_margin_mm + pcb_clearance_mm)) * 0.25,
      display_thickness_mm * 0.6
    ], center=true);
}

// ---------- Operations from plan ----------
module front_bezel_windowed() {
  difference() {
    front_bezel_outer_shape();
    display_window_cutout_shape();
  }
}

module front_bezel() {
  difference() {
    front_bezel_windowed();
    pcb_recess_cutout_shape();
  }
}

// ---------- MANDATORY detailed components ----------

// PRIMARY: Display (detailed)
module display() {
  // Use plan placement; add recognizable features: glass, bezel lip, backplate, flex tail
  w = bezel_width_mm - 2*window_margin_mm;
  h = bezel_height_mm - 2*window_margin_mm;
  t = display_thickness_mm;

  translate([0,0,-bezel_thickness_mm/2 + pcb_thickness_mm + t/2 - overlap_mm]) {
    // Back housing
    color([0.18,0.18,0.20]) {
      difference() {
        // Slightly inset from window opening
        linear_extrude(height=t, center=true)
          rounded_rect_2d(w-1.2, h-1.2, 1.2);
        // Shallow cavity to suggest internal volume
        translate([0,0,0.2])
          linear_extrude(height=t-0.8, center=true)
            rounded_rect_2d(w-6, h-6, 1.0);
      }
    }

    // Front glass
    glass_t = min(1.0, t*0.35);
    color([0.10,0.10,0.12, 0.55])
      translate([0,0,t/2 - glass_t/2])
        linear_extrude(height=glass_t, center=true)
          rounded_rect_2d(w-2.0, h-2.0, 0.8);

    // Active area (dark)
    color([0.02,0.02,0.03, 0.85])
      translate([0,0,t/2 - glass_t - 0.15])
        linear_extrude(height=0.3, center=true)
          rounded_rect_2d(w-8.0, h-8.0, 0.6);

    // Flex tail (to connect to PCB)
    tail_w = 10;
    tail_l = 14;
    tail_t = 0.25;
    color([0.85,0.55,0.15])
      translate([0, -h/2 - tail_l/2 + 1.0, -t/2 + tail_t/2])
        cube([tail_w, tail_l, tail_t], center=true);

    // Connector stiffener on tail
    color([0.15,0.15,0.16])
      translate([0, -h/2 - 3.5, -t/2 + 0.6])
        cube([tail_w+2, 6, 1.0], center=true);
  }
}

// SECONDARY: Mod (detailed)
module mod() {
  // Plan placement; add: small module can, connector, and a couple passives
  mod_w = (bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm)) * 0.35;
  mod_h = (bezel_height_mm - 2*(window_margin_mm + pcb_clearance_mm)) * 0.25;
  mod_t = display_thickness_mm * 0.6;

  px = (bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm))/2
        - mod_w/2 - pcb_clearance_mm;
  pz = -bezel_thickness_mm/2 + pcb_thickness_mm + mod_t/2 - overlap_mm;

  translate([px, 0, pz]) {
    // Main module body
    color([0.12,0.12,0.14]) {
      difference() {
        linear_extrude(height=mod_t, center=true)
          rounded_rect_2d(mod_w, mod_h, 1.0);
        // Top recess
        translate([0,0,0.2])
          linear_extrude(height=max(0.2, mod_t-1.0), center=true)
            rounded_rect_2d(mod_w-3.0, mod_h-3.0, 0.8);
      }
    }

    // Metal shield can on top
    can_w = mod_w*0.55;
    can_h = mod_h*0.55;
    can_t = min(1.2, mod_t*0.55);
    color([0.70,0.70,0.72])
      translate([0,0,mod_t/2 - can_t/2])
        linear_extrude(height=can_t, center=true)
          rounded_rect_2d(can_w, can_h, 0.6);

    // Side connector (white)
    conn_w = 10;
    conn_h = 6;
    conn_t = 4;
    color("White")
      translate([mod_w/2 - conn_t/2, 0, -mod_t/2 + conn_h/2])
        cube([conn_t, conn_w, conn_h], center=true);

    // A couple of passives
    color([0.05,0.05,0.06])
      translate([-mod_w*0.18, -mod_h*0.18, mod_t/2 - 0.6])
        cube([4.0, 2.0, 1.0], center=true);
    color([0.05,0.05,0.06])
      translate([-mod_w*0.05, mod_h*0.12, mod_t/2 - 0.6])
        cube([3.0, 1.6, 0.9], center=true);
  }
}

// SECONDARY: PCB Base (detailed) - includes wall=2 requirement
module pcb_base() {
  // Interpret "pcb base" as the PCB itself with slight edge chamfer + mounting holes + copper pads
  // (wall=2 used as a keepout border for copper/pads)
  wall = 2;

  w = bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm);
  h = bezel_height_mm - 2*(window_margin_mm + pcb_clearance_mm);
  t = pcb_thickness_mm;

  translate([0,0,-bezel_thickness_mm/2 + t/2 - overlap_mm]) {
    // FR4 board
    color([0.02,0.35,0.20]) {
      linear_extrude(height=t, center=true)
        rounded_rect_2d(w, h, 1.2);
    }

    // Silkscreen outline
    color([0.90,0.90,0.90, 0.85])
      translate([0,0,t/2 - 0.05])
        linear_extrude(height=0.1, center=true)
          difference() {
            rounded_rect_2d(w-wall*0.6, h-wall*0.6, 1.0);
            rounded_rect_2d(w-wall*1.6, h-wall*1.6, 0.8);
          }

    // Corner mounting holes (NPTH look)
    hole_d = 3.0;
    hole_offx = w/2 - 4.0;
    hole_offy = h/2 - 4.0;
    color([0.75,0.75,0.77]) {
      for (sx=[-1,1]) for (sy=[-1,1]) {
        translate([sx*hole_offx, sy*hole_offy, 0])
          difference() {
            // plated ring
            cylinder(d=hole_d+2.0, h=0.25, center=true, $fn=32);
            cylinder(d=hole_d, h=0.35, center=true, $fn=32);
          }
      }
    }

    // A small IC + a capacitor for context
    color([0.08,0.08,0.09])
      translate([-w*0.15, 0, t/2 + 0.8])
        cube([10, 10, 1.6], center=true);

    color([0.15,0.15,0.16])
      translate([-w*0.28, -h*0.18, t/2 + 1.8])
        cylinder(d=6.0, h=3.6, center=true, $fn=32);

    // Header footprint pads (gold) near bottom edge
    pad_cols = 8;
    pitch = 2.54;
    color([0.80,0.65,0.20])
      translate([0, -h/2 + 6.0, t/2 - 0.05])
        for (i=[0:pad_cols-1]) {
          x = (i-(pad_cols-1)/2)*pitch;
          translate([x,0,0])
            cube([1.6, 2.0, 0.1], center=true);
        }
  }
}

// SECONDARY: PCB (detailed) - per plan, pcb is union of pcb_base with itself; keep as wrapper
module pcb() {
  pcb_base();
}

// SECONDARY: PCB Assembly (detailed)
module pcb_assembly() {
  // Union of pcb_base + display + mod, as per plan
  pcb_base();
  display();
  mod();

  // Add a small header on PCB to make assembly more recognizable (still connected to PCB)
  w = bezel_width_mm - 2*(window_margin_mm + pcb_clearance_mm);
  h = bezel_height_mm - 2*(window_margin_mm + pcb_clearance_mm);
  t = pcb_thickness_mm;

  translate([0,0,-bezel_thickness_mm/2 + t/2 - overlap_mm]) {
    translate([0, -h/2 + 6.0, t/2 + 1.25])
      pin_header_2row(cols=6, rows=2, pitch=2.54, pin_d=0.7, pin_h=3.2, body_h=2.5);
  }
}

// Front bezel as a component (not mandatory module name, but used in assembly)
module bezel() {
  // Add slight visual rounding via 2D offset for the outer, while keeping plan booleans for cutouts
  // Keep geometry faithful: outer box minus window minus recess.
  color([0.15,0.15,0.17]) {
    difference() {
      // Outer
      linear_extrude(height=bezel_thickness_mm, center=true)
        rounded_rect_2d(bezel_width_mm, bezel_height_mm, 1.2);

      // Window cutout
      translate([0,0,0])
        cube([bezel_width_mm - 2*window_margin_mm,
              bezel_height_mm - 2*window_margin_mm,
              bezel_thickness_mm + 2*overlap_mm], center=true);

      // Rear recess cutout
      pcb_recess_cutout_shape();
    }
  }

  // Add 4 small front countersink hints (purely visual, still connected)
  color([0.10,0.10,0.11]) {
    offx = bezel_width_mm/2 - 5.5;
    offy = bezel_height_mm/2 - 5.5;
    for (sx=[-1,1]) for (sy=[-1,1]) {
      translate([sx*offx, sy*offy, bezel_thickness_mm/2 - 0.6])
        cylinder(d1=3.2, d2=1.6, h=1.2, center=true, $fn=24);
    }
  }
}

// ---------- Final assembly ----------
module assembly() {
  // PRIMARY at origin: bezel
  bezel();

  // SECONDARY components attach within recess (no floating)
  pcb_assembly();
}

// Call final output
assembly();