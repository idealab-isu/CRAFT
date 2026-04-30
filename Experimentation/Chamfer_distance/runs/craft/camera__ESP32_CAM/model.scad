// Parameters (mm)
primary_dimension = 15; //[7.5:30:0.5]
fov_horizontal_deg = 54; //[27:108:1]
fov_vertical_deg = 41; //[20:82:1]
fov_distance_mm = 50; //[25:100:1]
ribbon_connector_length_mm = 15; //[7.5:30:0.5]
ribbon_connector_width_mm = 2.2; //[1.1:4.4:0.1]
ribbon_connector_thickness_mm = 1; //[0.5:2:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
body_length_mm = 25; //[12.5:50:0.5]
body_width_mm = 24; //[12:48:0.5]
body_height_mm = 8; //[4:16:0.5]
lens_diameter_mm = 8; //[4:16:0.5]
lens_height_mm = 6; //[3:12:0.5]
connector_offset_from_lens_mm = 10; //[5:20:0.5]
eps_overlap_mm = 0.8; //[0.5:2:0.1]
frustum_thickness_mm = 0.6; //[0.3:1.2:0.1]

// Quality
$fn=32;

// Derived (keep expressions aligned with plan intent)
scale_pd = (primary_dimension/15);

pcb_x = primary_dimension;
pcb_y = primary_dimension;
pcb_z = pcb_thickness_mm;

body_x = body_length_mm*scale_pd;
body_y = body_width_mm*scale_pd;
body_z = body_height_mm*scale_pd;

lens_r = (lens_diameter_mm*scale_pd)/2;
lens_h = lens_height_mm*scale_pd;

z_pcb_top = pcb_thickness_mm/2;
z_body_center = (pcb_thickness_mm/2) + (body_z)/2 - eps_overlap_mm;
z_body_top = (pcb_thickness_mm/2) + (body_z) - eps_overlap_mm;

z_lens_center = (pcb_thickness_mm/2) + (body_z) + (lens_h)/2 - eps_overlap_mm;
z_lens_top = (pcb_thickness_mm/2) + (body_z) + (lens_h) - eps_overlap_mm;

pad_x = ribbon_connector_width_mm*1.6;
pad_y = ribbon_connector_length_mm*0.35;
pad_z = pcb_thickness_mm*0.25;

pad_pos = [
  0,
  (primary_dimension/2) - (pad_y)/2 - eps_overlap_mm,
  (pcb_thickness_mm/2) - (pad_z)/2 + eps_overlap_mm
];

fpc_x = ribbon_connector_width_mm;
fpc_y = ribbon_connector_length_mm;
fpc_z = ribbon_connector_thickness_mm;

fpc_pos = [
  0,
  (primary_dimension/2) + (fpc_y)/2 - eps_overlap_mm,
  (pcb_thickness_mm/2) + (fpc_z)/2 - eps_overlap_mm
];

fov_near_pos = [0, 0, z_lens_top];
fov_far_pos  = [0, 0, z_lens_top + fov_distance_mm];

fov_far_x = 2*fov_distance_mm*tan(fov_horizontal_deg/2);
fov_far_y = 2*fov_distance_mm*tan(fov_vertical_deg/2);

// ---------- Helpers ----------
module rounded_box_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  offset(r=r2) square([w-2*r2, h-2*r2], center=true);
}

module rounded_box_3d(size=[10,10,10], r=1, center=true) {
  // Rounded via 2D offset + linear_extrude (fast, no minkowski)
  w = size[0]; h = size[1]; z = size[2];
  translate([0,0, center ? -z/2 : 0])
    linear_extrude(height=z)
      rounded_box_2d(w, h, r);
}

module screw_hole(d=2, h=5) {
  cylinder(d=d, h=h, center=true, $fn=24);
}

// ---------- Base shapes from plan ----------
module pcb_shape() {
  color([0.0, 0.4, 0.2])  // PCB green
    translate([0,0,0])
      rounded_box_3d([pcb_x, pcb_y, pcb_z], r=0.8, center=true);
}

module camera_body_shape() {
  // Detailed camera body: main housing + top boss + small side features
  color([0.12, 0.12, 0.14]) {
    translate([0,0,z_body_center]) {
      // Main housing with slight rounding
      rounded_box_3d([body_x, body_y, body_z], r=1.2*scale_pd, center=true);

      // Small "sensor can" bump under lens (on top face)
      translate([0,0, body_z/2 - 0.6*scale_pd])
        cylinder(d= min(body_x, body_y)*0.35, h=1.2*scale_pd, center=true, $fn=32);

      // Side connector/IC lump (visual detail)
      translate([body_x*0.22, -body_y*0.18, -body_z*0.05])
        rounded_box_3d([body_x*0.22, body_y*0.18, body_z*0.35], r=0.6*scale_pd, center=true);
    }
  }
}

module lens_shape() {
  // Detailed lens: barrel + front ring + slight taper + "glass"
  translate([0,0,z_lens_center]) {
    // Barrel
    color([0.08, 0.08, 0.09])
      union() {
        cylinder(r=lens_r, h=lens_h, center=true, $fn=32);

        // Front ring
        translate([0,0, lens_h*0.28])
          difference() {
            cylinder(r=lens_r*1.05, h=lens_h*0.18, center=true, $fn=32);
            cylinder(r=lens_r*0.82, h=lens_h*0.22, center=true, $fn=32);
          }

        // Rear taper into body
        translate([0,0, -lens_h*0.30])
          cylinder(r1=lens_r*0.92, r2=lens_r*0.78, h=lens_h*0.22, center=true, $fn=32);
      }

    // Glass element
    color([0.25, 0.35, 0.45, 0.55])
      translate([0,0, lens_h*0.36])
        cylinder(r=lens_r*0.72, h=max(0.6*scale_pd, lens_h*0.12), center=true, $fn=32);
  }
}

module connector_pad_area_shape() {
  // Gold pads on PCB
  color([0.8, 0.6, 0.2])
    translate(pad_pos)
      cube([pad_x, pad_y, pad_z], center=true);
}

module ribbon_connector_shape() {
  // FPC connector: plastic body + latch + pins hint
  translate(fpc_pos) {
    // Main plastic
    color([0.92, 0.92, 0.92])
      rounded_box_3d([fpc_x*1.25, fpc_y, fpc_z], r=0.25, center=true);

    // Latch bar
    color([0.75, 0.75, 0.78])
      translate([0, -fpc_y*0.18, fpc_z*0.35])
        cube([fpc_x*1.35, fpc_y*0.18, fpc_z*0.35], center=true);

    // Pin hint (thin metallic strip)
    color([0.65, 0.55, 0.35])
      translate([0, -fpc_y*0.35, -fpc_z*0.15])
        cube([fpc_x*0.95, fpc_y*0.12, max(0.15, fpc_z*0.25)], center=true);
  }
}

module fov_near_shape() {
  translate(fov_near_pos)
    cube([frustum_thickness_mm, frustum_thickness_mm, frustum_thickness_mm], center=true);
}

module fov_far_shape() {
  translate(fov_far_pos)
    cube([fov_far_x, fov_far_y, frustum_thickness_mm], center=true);
}

// ---------- Operations from plan ----------
module fov_frustum() {
  // Visualized frustum as thin solid
  color([0.2, 0.6, 1.0, 0.25])
    hull() {
      fov_near_shape();
      fov_far_shape();
    }
}

// [MANDATORY] Camera module (detailed, self-contained)
module camera() {
  // Union(camera_body, lens)
  union() {
    camera_body_shape();
    lens_shape();
  }
}

// [MANDATORY] Mod module (detailed, self-contained)
module mod() {
  union() {
    // PCB with mounting holes (detail) while keeping plan geometry intact
    difference() {
      pcb_shape();

      // Corner mounting holes (visual detail; typical small camera PCB)
      hole_d = 2.0*scale_pd;
      hole_off = primary_dimension*0.38;
      for (sx=[-1,1], sy=[-1,1])
        translate([sx*hole_off, sy*hole_off, 0])
          screw_hole(d=hole_d, h=pcb_thickness_mm+2);
    }

    // Camera (attached on top of PCB per plan)
    camera();

    // Connector pad area + connector
    connector_pad_area_shape();
    ribbon_connector_shape();

    // FOV frustum
    fov_frustum();
  }
}

// [MANDATORY] Assembly: PRIMARY at origin, SECONDARY attached (mod includes camera already)
module assembly() {
  // PRIMARY component at origin: camera module representation is part of mod,
  // but we keep the full requested assembly as the complete module at origin.
  mod();
}

assembly();