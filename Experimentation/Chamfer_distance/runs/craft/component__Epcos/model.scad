// Parameters (mm)
primary_dimension = 4.6; //[2.3:9.2:0.1]
body_width        = 4.6; //[2.3:9.2:0.1]
body_thickness    = 2.5; //[1.25:5:0.1]
body_length       = 2.5; //[1.25:5:0.1]
overlap           = 0.6; //[0.3:1.2:0.1]

knob_radius  = 1.15; //[0.6:2.3:0.05]
knob_height  = 1.38; //[0.7:2.8:0.05]
screw_radius = 0.46; //[0.25:0.9:0.01]
screw_length = 3.68; //[1.8:7.4:0.1]

marker_radius = 0.23; //[0.12:0.46:0.01]
marker_height = 0.92; //[0.4:1.8:0.02]
marker_pitch  = 1.38; //[0.7:2.8:0.02]

// Global quality
$fn=32;

// ---------- Helpers ----------
module hex_prism(flat_d=2, h=1, center=false) {
  // flat_d is across flats
  r = flat_d / (2*cos(30));
  cylinder(r=r, h=h, center=center, $fn=6);
}

module rounded_rect_2d(w, h, r) {
  rr = min(r, min(w, h)/2);
  hull() {
    translate([ w/2-rr,  h/2-rr]) circle(r=rr, $fn=24);
    translate([-w/2+rr,  h/2-rr]) circle(r=rr, $fn=24);
    translate([ w/2-rr, -h/2+rr]) circle(r=rr, $fn=24);
    translate([-w/2+rr, -h/2+rr]) circle(r=rr, $fn=24);
  }
}

module marker_pin(r=marker_radius, h=marker_height) {
  // Small "hole position marker" with a tiny head so it reads as a marker, not just a cylinder
  union() {
    cylinder(r=r, h=h, center=true, $fn=24);
    translate([0,0,h/2 - min(0.18, h*0.25)]) cylinder(r=r*1.35, h=min(0.18, h*0.25), center=false, $fn=24);
  }
}

// ---------- Base shapes from plan ----------
module component_body() {
  // Encapsulated body
  color([0.15, 0.15, 0.17])  // black plastic
    cube([body_width, body_length, body_thickness], center=true);
}

// [MANDATORY] Screw Knob Assembly (detailed)
module screw_knob_assembly() {
  // Positions from plan
  knob_z  = body_thickness/2 + knob_height/2 - overlap;
  screw_z = body_thickness/2 + knob_height - overlap - screw_length/2;

  // Detail parameters (kept minimal but recognizable)
  knob_r = knob_radius;
  knob_h = knob_height;

  // Knurling ribs
  rib_count = 10;
  rib_w = max(0.18, knob_r*0.18);
  rib_d = max(0.18, knob_r*0.22);

  // Screw details
  shank_r = screw_radius;
  head_h  = max(0.35, shank_r*1.2);
  head_r  = max(shank_r*1.9, shank_r + 0.35);
  tip_h   = max(0.35, shank_r*1.2);

  color([0.2, 0.2, 0.22])  // dark knob
  union() {
    // Knob body with simple knurl ribs
    translate([0,0,knob_z])
    union() {
      // main knob cylinder
      cylinder(r=knob_r, h=knob_h, center=true, $fn=32);

      // top chamfer ring (visual)
      translate([0,0,knob_h/2 - min(0.25, knob_h*0.25)])
        cylinder(r1=knob_r, r2=knob_r*0.88, h=min(0.25, knob_h*0.25), center=false, $fn=32);

      // knurl ribs around perimeter
      for (i=[0:rib_count-1]) {
        rotate([0,0,i*360/rib_count])
          translate([knob_r - rib_d/2, 0, 0])
            cube([rib_d, rib_w, knob_h*0.92], center=true);
      }

      // central boss (suggests insert)
      cylinder(r=knob_r*0.35, h=knob_h*0.75, center=true, $fn=32);
    }

    // Screw: metal shank + head + tip (passes through body)
    color([0.75, 0.75, 0.77])  // silver metal
    translate([0,0,screw_z])
    union() {
      // shank
      cylinder(r=shank_r, h=screw_length, center=true, $fn=32);

      // head near top (inside knob region)
      translate([0,0,screw_length/2 - head_h])
      difference() {
        cylinder(r=head_r, h=head_h, center=false, $fn=32);
        // simple slot
        translate([0,0,head_h*0.55])
          cube([head_r*1.7, max(0.18, shank_r*0.7), head_h*1.2], center=true);
      }

      // pointed tip at bottom
      translate([0,0,-screw_length/2])
        cylinder(r1=shank_r, r2=0.05, h=tip_h, center=false, $fn=32);
    }
  }
}

// [MANDATORY] Rail Hole Positions (detailed markers)
module rail_hole_positions() {
  // Base marker position from plan
  base_z = body_thickness/2 - marker_height/2 + overlap;

  color([0.85, 0.85, 0.8])  // light marker color
  union() {
    // center marker (as in plan's union target with itself)
    translate([0,0,base_z]) marker_pin();

    // shifted markers (± marker_pitch in Y)
    translate([0, marker_pitch, 0]) translate([0,0,base_z]) marker_pin();
    translate([0,-marker_pitch, 0]) translate([0,0,base_z]) marker_pin();

    // Small connecting web to guarantee connectivity (assembly rule: no floating parts)
    // Connects markers to body top surface region
    web_t = max(0.25, marker_radius*2.2);
    translate([0,0, body_thickness/2 - web_t/2 + overlap])
      linear_extrude(height=web_t, center=true)
        rounded_rect_2d(w=marker_radius*3.2, h=marker_pitch*2 + marker_radius*3.2, r=marker_radius*1.2);
  }
}

// [MANDATORY] Ttrack Hole Positions (detailed markers)
module ttrack_hole_positions() {
  base_z = body_thickness/2 - marker_height/2 + overlap;

  color([0.85, 0.85, 0.8])
  union() {
    // center marker (as in plan's union target with itself)
    translate([0,0,base_z]) marker_pin();

    // shifted markers: (+body_width/4, +marker_pitch/2) and (-body_width/4, -marker_pitch/2)
    translate([ body_width/4,  marker_pitch/2, 0]) translate([0,0,base_z]) marker_pin();
    translate([-body_width/4, -marker_pitch/2, 0]) translate([0,0,base_z]) marker_pin();

    // connectivity web
    web_t = max(0.25, marker_radius*2.2);
    translate([0,0, body_thickness/2 - web_t/2 + overlap])
      linear_extrude(height=web_t, center=true)
        rounded_rect_2d(w=body_width/2 + marker_radius*3.2, h=marker_pitch + marker_radius*3.2, r=marker_radius*1.2);
  }
}

// [MANDATORY] Ttrack Insert Hole Positions (detailed markers)
module ttrack_insert_hole_positions() {
  base_z = body_thickness/2 - marker_height/2 + overlap;

  color([0.85, 0.85, 0.8])
  union() {
    // center marker (as in plan's union target with itself)
    translate([0,0,base_z]) marker_pin();

    // shifted markers: (+body_width/4, -marker_pitch/2) and (-body_width/4, +marker_pitch/2)
    translate([ body_width/4, -marker_pitch/2, 0]) translate([0,0,base_z]) marker_pin();
    translate([-body_width/4,  marker_pitch/2, 0]) translate([0,0,base_z]) marker_pin();

    // connectivity web
    web_t = max(0.25, marker_radius*2.2);
    translate([0,0, body_thickness/2 - web_t/2 + overlap])
      linear_extrude(height=web_t, center=true)
        rounded_rect_2d(w=body_width/2 + marker_radius*3.2, h=marker_pitch + marker_radius*3.2, r=marker_radius*1.2);
  }
}

// ---------- Final assembly ----------
module assembly() {
  union() {
    component_body();
    screw_knob_assembly();
    rail_hole_positions();
    ttrack_hole_positions();
    ttrack_insert_hole_positions();
  }
}

assembly();