// Parameters (mm)
primary_dimension_mm = 9; //[4.5:18:0.1]
body_diameter_mm = 9; //[4.5:18:0.1]
body_height_mm = 8; //[4:16:0.1]
base_plate_diameter_mm = 10; //[5:20:0.1]
base_plate_thickness_mm = 1; //[0.5:2:0.05]
shaft_diameter_mm = 1; //[0.5:2:0.05]
shaft_length_mm = 15.5; //[7.75:31:0.1]
interface_step_height_mm = 0.9; //[0.45:1.8:0.05]
interface_step_diameter_mm = 8.1; //[4.05:16.2:0.1]
overlap_mm = 0.6; //[0.2:1.5:0.1]

// Quality
$fn=32;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2, $fn=24);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2, $fn=24);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2, $fn=24);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2, $fn=24);
  }
}

module screw_hole(d=1.6, h=10) {
  cylinder(d=d, h=h, center=true, $fn=24);
}

// ---------- MANDATORY COMPONENTS ----------

// [PRIMARY] Veroboard Base (detailed: board + copper strip bumps + mounting holes)
module veroboard_base(size=[base_plate_diameter_mm*0.55, base_plate_diameter_mm*0.35, base_plate_thickness_mm*0.6], wall=2, tapped=false) {
  w = size[0];
  l = size[1];
  t = max(0.6, size[2]);
  corner_r = min(1.2, min(w,l)*0.12);

  color([0.85, 0.72, 0.45])  // phenolic/veroboard tan
  union() {
    // Board body with rounded corners
    linear_extrude(height=t)
      rounded_rect_2d(w, l, corner_r);

    // Copper strip hints on underside (small ribs)
    // Keep subtle to avoid heavy booleans
    strip_h = min(0.18, t*0.35);
    strip_w = max(0.35, min(0.6, w/30));
    n = max(4, floor(l / 1.8));
    for (i = [0:n-1]) {
      y = -l/2 + (i+0.5)*l/n;
      translate([0, y, -strip_h*0.02])
        color([0.72, 0.45, 0.2])
          cube([w*0.92, strip_w, strip_h], center=true);
    }

    // Through holes grid (visual only: shallow dimples on top)
    // (Avoid full perforation to keep it connected solid per plan intent)
    dimple_d = 0.5;
    dimple_h = min(0.25, t*0.45);
    nx = max(4, floor(w / 2.0));
    ny = max(3, floor(l / 2.0));
    for (ix=[0:nx-1]) for (iy=[0:ny-1]) {
      x = -w*0.42 + ix*(w*0.84)/(max(1,nx-1));
      y = -l*0.42 + iy*(l*0.84)/(max(1,ny-1));
      translate([x, y, t - dimple_h/2])
        color([0.65, 0.55, 0.35])
          cylinder(d=dimple_d, h=dimple_h, center=true, $fn=16);
    }
  }
}

// [SECONDARY] Buzzer (detailed: can + top sound port + pins)
module buzzer(r=body_diameter_mm*0.18, h=base_plate_thickness_mm*0.8) {
  can_h = max(1.2, h);
  can_r = max(1.2, r);
  lip_h = min(0.35, can_h*0.25);
  port_d = can_r*0.55;

  color([0.12, 0.12, 0.14])  // black plastic
  union() {
    // Main can with slight top lip
    union() {
      cylinder(r=can_r, h=can_h, center=true, $fn=32);
      translate([0,0,can_h/2 - lip_h/2])
        cylinder(r=can_r*1.03, h=lip_h, center=true, $fn=32);
    }

    // Top sound port ring (raised)
    translate([0,0,can_h/2 - lip_h*0.9])
      color([0.18, 0.18, 0.2])
        difference() {
          cylinder(d=port_d*1.15, h=lip_h*0.9, center=true, $fn=32);
          cylinder(d=port_d, h=lip_h*1.2, center=true, $fn=32);
        }

    // Two pins (metal) exiting bottom
    pin_d = 0.35;
    pin_len = max(1.2, can_h*0.9);
    pin_spacing = can_r*0.65;
    for (sx=[-1,1]) {
      translate([sx*pin_spacing/2, 0, -can_h/2 - pin_len/2 + 0.1])
        color("Silver")
          cylinder(d=pin_d, h=pin_len, center=true, $fn=18);
    }
  }
}

// [SECONDARY] PCB Base (detailed: FR4 board + pads + 4 mounting holes)
module pcb_base(size=[base_plate_diameter_mm*0.45, base_plate_diameter_mm*0.25, base_plate_thickness_mm*0.6], wall=2) {
  w = size[0];
  l = size[1];
  t = max(0.8, size[2]);
  corner_r = min(1.0, min(w,l)*0.15);

  color([0.0, 0.4, 0.2])  // green FR4
  union() {
    // Board
    linear_extrude(height=t)
      rounded_rect_2d(w, l, corner_r);

    // Silkscreen-ish rectangle
    translate([0,0,t-0.05])
      color([0.85,0.85,0.85])
        linear_extrude(height=0.08)
          difference() {
            rounded_rect_2d(w*0.86, l*0.78, corner_r*0.7);
            rounded_rect_2d(w*0.78, l*0.70, corner_r*0.6);
          }

    // Pads (gold) along one edge
    pad_w = w*0.08;
    pad_l = l*0.12;
    pad_h = 0.12;
    np = 4;
    for (i=[0:np-1]) {
      x = -w*0.25 + i*(w*0.5)/(max(1,np-1));
      translate([x, -l*0.32, t + pad_h/2])
        color([0.8, 0.6, 0.2])
          cube([pad_w, pad_l, pad_h], center=true);
    }

    // Mounting hole rings (visual only, not cut through to keep union solid)
    ring_d = min(1.6, min(w,l)*0.18);
    ring_h = 0.15;
    hx = w*0.38;
    hy = l*0.32;
    for (sx=[-1,1]) for (sy=[-1,1]) {
      translate([sx*hx, sy*hy, t + ring_h/2])
        color([0.8, 0.6, 0.2])
          difference() {
            cylinder(d=ring_d, h=ring_h, center=true, $fn=24);
            cylinder(d=ring_d*0.55, h=ring_h*1.5, center=true, $fn=24);
          }
    }
  }
}

// [SECONDARY] Orientate Axial (detailed: small axial coupler/adapter around shaft)
module orientate_axial(shaft_d=shaft_diameter_mm, body_d=shaft_diameter_mm*3.2, body_h=shaft_diameter_mm*3.0) {
  d_out = max(2.2, body_d);
  h = max(2.0, body_h);
  d_in = max(shaft_d*1.05, 0.8);

  color([0.15, 0.15, 0.17])  // black anodized/printed
  union() {
    // Coupler body
    difference() {
      cylinder(d=d_out, h=h, center=true, $fn=32);
      cylinder(d=d_in, h=h+0.4, center=true, $fn=24);
      // Side flat (key) hint
      translate([d_out*0.22, 0, 0])
        cube([d_out*0.6, d_out*0.25, h+0.6], center=true);
    }

    // Tiny set-screw boss
    boss_d = d_out*0.55;
    boss_h = h*0.35;
    translate([d_out*0.35, 0, 0])
      color([0.2,0.2,0.22])
        cylinder(d=boss_d, h=boss_h, center=true, $fn=24);
  }
}

// [SECONDARY] Right Trapezoid (detailed: trapezoid block with bore + mounting holes)
module right_trapezoid(size=[base_plate_diameter_mm*0.25, base_plate_diameter_mm*0.18, base_plate_thickness_mm*0.6], center=true, h=0) {
  w = max(1.5, size[0]);
  d = max(1.2, size[1]);
  t = max(0.8, size[2]);

  // Trapezoid profile (wider at bottom)
  top_w = w*0.72;
  bot_w = w;
  prof = [
    [-bot_w/2, -d/2],
    [ bot_w/2, -d/2],
    [ top_w/2,  d/2],
    [-top_w/2,  d/2]
  ];

  bore_d = min(w*0.35, d*0.55);
  hole_d = min(1.2, min(w,d)*0.22);

  color([0.75, 0.75, 0.77])  // aluminum-ish
  difference() {
    translate([0,0, center ? 0 : t/2])
      linear_extrude(height=t, center=center)
        polygon(points=prof);

    // Central bore (bearing seat hint)
    translate([0, 0, 0])
      cylinder(d=bore_d, h=t+0.6, center=true, $fn=32);

    // Two mounting holes
    hx = w*0.22;
    hy = -d*0.18;
    for (sx=[-1,1]) {
      translate([sx*hx, hy, 0])
        cylinder(d=hole_d, h=t+0.6, center=true, $fn=24);
    }
  }
}

// ---------- Motor primitives from plan ----------
module base_plate_disc() {
  translate([0,0,base_plate_thickness_mm/2])
    cylinder(r=base_plate_diameter_mm/2, h=base_plate_thickness_mm, center=true, $fn=32);
}

module body_to_base_interface_step() {
  translate([0,0,base_plate_thickness_mm + interface_step_height_mm/2 - overlap_mm])
    cylinder(r=interface_step_diameter_mm/2, h=interface_step_height_mm, center=true, $fn=32);
}

module motor_body_cylinder() {
  translate([0,0,base_plate_thickness_mm + interface_step_height_mm + body_height_mm/2 - overlap_mm])
    cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true, $fn=32);
}

module center_shaft() {
  translate([0,0,shaft_length_mm/2 - overlap_mm])
    cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true, $fn=32);
}

// ---------- Assembly ----------
module assembly() {
  // Motor union per plan, with detailed mandatory components.
  union() {
    // Base plate + motor can
    color([0.4, 0.4, 0.43]) base_plate_disc();                 // steel-ish
    color([0.55, 0.55, 0.58]) body_to_base_interface_step();    // metal step
    color([0.1, 0.1, 0.12]) motor_body_cylinder();              // black can

    // Shaft
    color("Silver") center_shaft();

    // Orientate axial (coupler) attached on shaft near base
    translate([0,0, max(1.2, shaft_diameter_mm*1.8)])
      orientate_axial();

    // PRIMARY: Veroboard base at origin region (attached to base plate underside/top per plan)
    translate([0,0, base_plate_thickness_mm - (base_plate_thickness_mm*0.6)/2])
      veroboard_base(size=[base_plate_diameter_mm*0.55, base_plate_diameter_mm*0.35, base_plate_thickness_mm*0.6], wall=2, tapped=false);

    // PCB base (stacked, slightly offset so it's visible but still connected)
    translate([0, base_plate_diameter_mm*0.12, base_plate_thickness_mm - (base_plate_thickness_mm*0.6)/2 + overlap_mm*0.2])
      pcb_base(size=[base_plate_diameter_mm*0.45, base_plate_diameter_mm*0.25, base_plate_thickness_mm*0.6], wall=2);

    // Buzzer on top of base plate
    translate([0,0, base_plate_thickness_mm + (base_plate_thickness_mm*0.8)/2 - overlap_mm])
      buzzer(r=body_diameter_mm*0.18, h=base_plate_thickness_mm*0.8);

    // Right trapezoid attached at right edge per plan
    translate([base_plate_diameter_mm/2 - (base_plate_diameter_mm*0.25)/2 - overlap_mm, 0,
               base_plate_thickness_mm - (base_plate_thickness_mm*0.6)/2])
      right_trapezoid(size=[base_plate_diameter_mm*0.25, base_plate_diameter_mm*0.18, base_plate_thickness_mm*0.6], center=true, h=0);

    // Small connector rib to guarantee physical connection between stacked boards and motor base
    // (Allowed by assembly rules: add bracket/mount to connect; keep minimal)
    color([0.75, 0.75, 0.77])
      translate([0,0, base_plate_thickness_mm*0.55])
        cube([base_plate_diameter_mm*0.18, base_plate_diameter_mm*0.12, base_plate_thickness_mm*0.9], center=true);
  }
}

assembly();