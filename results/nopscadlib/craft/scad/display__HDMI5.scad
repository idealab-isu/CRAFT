// HDMI display 5" module (single connected solid)
// Spec: 121, 76, 2.85, pcb offset [0,0,1.9]
// Aperture [[-54, -30.225], [54, 34.575, 0.5]]
// Touch screen [[-58.7, -34], [58.7, 36.25, 1]]
// Thread length 2
// TS ribbon clearance [[-2.5, -39], [10.5, -33]]

$fn = 64;

// -------------------- Parameters --------------------
display_width     = 121;
display_height    = 76;
display_thickness = 2.85;

pcb_offset = [0, 0, 1.9];

aperture_min = [-54,   -30.225, 0];
aperture_max = [ 54,    34.575, 0.5];

touch_min = [-58.7, -34,   0];
touch_max = [ 58.7,  36.25, 1];

thread_length = 2;

ts_ribbon_clear_min = [-2.5, -39];
ts_ribbon_clear_max = [10.5, -33];

eps = 0.25; // overlap/robust boolean epsilon

// PCB (approx)
pcb_width     = 110;
pcb_height    = 65;
pcb_thickness = 1.6;

// HDMI (approx) - placed on RIGHT edge (positive X) to match views
hdmi_body_width  = 12;  // along Y
hdmi_body_depth  = 14;  // along X (sticks out)
hdmi_body_height = 6;   // along Z

// Mounting / standoffs (approx)
mount_hole_inset_x = 6;
mount_hole_inset_y = 6;
standoff_radius    = 2.2;
knob_radius        = 4;
knob_height        = 2.5;

// Derived
aperture_size = [
  aperture_max[0] - aperture_min[0],
  aperture_max[1] - aperture_min[1],
  aperture_max[2] - aperture_min[2]
];
aperture_ctr = [
  (aperture_min[0] + aperture_max[0]) / 2,
  (aperture_min[1] + aperture_max[1]) / 2,
  (aperture_min[2] + aperture_max[2]) / 2
];

touch_size = [
  touch_max[0] - touch_min[0],
  touch_max[1] - touch_min[1],
  touch_max[2] - touch_min[2]
];
touch_ctr = [
  (touch_min[0] + touch_max[0]) / 2,
  (touch_min[1] + touch_max[1]) / 2,
  (touch_min[2] + touch_max[2]) / 2
];

ts_ribbon_size = [
  ts_ribbon_clear_max[0] - ts_ribbon_clear_min[0],
  ts_ribbon_clear_max[1] - ts_ribbon_clear_min[1]
];
ts_ribbon_ctr = [
  (ts_ribbon_clear_min[0] + ts_ribbon_clear_max[0]) / 2,
  (ts_ribbon_clear_min[1] + ts_ribbon_clear_max[1]) / 2
];

// Z stacking (centered display at z=0)
z_front =  display_thickness/2;
z_back  = -display_thickness/2;

// PCB sits behind display (negative Z) by pcb_offset.z
pcb_z_center   = z_back - pcb_offset[2] - pcb_thickness/2;
touch_z_center = z_front + touch_ctr[2];

// -------------------- Helpers --------------------
module rounded_cube(size=[10,10,10], r=1, center=true) {
  minkowski() {
    cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=center);
    sphere(r=r);
  }
}

// -------------------- Single connected solid model --------------------
module display_module_connected() {
  union() {

    // 1) Display bezel/body with aperture cut + TS ribbon clearance cut
    difference() {
      rounded_cube([display_width, display_height, display_thickness], r=0.8, center=true);

      // Aperture cut from FRONT side only (depth = aperture_size.z)
      translate([aperture_ctr[0], aperture_ctr[1], z_front - aperture_size[2]/2 + eps/2])
        cube([aperture_size[0], aperture_size[1], aperture_size[2] + eps], center=true);

      // TS ribbon clearance notch (cut through bezel at bottom edge, full thickness)
      translate([ts_ribbon_ctr[0], ts_ribbon_ctr[1], 0])
        cube([ts_ribbon_size[0], ts_ribbon_size[1], display_thickness + 2*eps], center=true);
    }

    // 2) Touchscreen layer (thin plate on front) - fused by overlap
    translate([touch_ctr[0], touch_ctr[1], z_front + touch_size[2]/2 - eps])
      cube([touch_size[0], touch_size[1], touch_size[2]], center=true);

    // 3) PCB (behind display) - fused by overlap into bezel
    translate([pcb_offset[0], pcb_offset[1], pcb_z_center + eps])
      cube([pcb_width, pcb_height, pcb_thickness], center=true);

    // 4) HDMI connector block (on PCB RIGHT edge) - connected to PCB with overlap
    // X placement: PCB right face + half connector depth - overlap
    // Z placement: sits on PCB (above PCB top face toward +Z), but PCB is behind display so still behind overall
    translate([
      pcb_offset[0] + pcb_width/2 + hdmi_body_depth/2 - eps,
      pcb_offset[1],
      pcb_z_center + pcb_thickness/2 + hdmi_body_height/2 - eps
    ])
      cube([hdmi_body_depth, hdmi_body_width, hdmi_body_height], center=true);

    // 5) Standoffs + knobs (behind PCB, toward more negative Z) - connected by overlap
    for (i = [-1, 1], j = [-1, 1]) {
      xh = pcb_offset[0] + i * (pcb_width/2  - mount_hole_inset_x);
      yh = pcb_offset[1] + j * (pcb_height/2 - mount_hole_inset_y);

      // Standoff: starts just below PCB bottom face (toward -Z)
      translate([xh, yh, pcb_z_center - pcb_thickness/2 - thread_length/2 + eps])
        cylinder(r=standoff_radius, h=thread_length, center=true);

      // Knob under standoff, connected by overlap
      translate([xh, yh, (pcb_z_center - pcb_thickness/2 - thread_length) - knob_height/2 + 2*eps])
        cylinder(r=knob_radius, h=knob_height, center=true);
    }

    // 6) Back cover lip (behind bezel) - fused into bezel and helps connectivity
    translate([0, 0, z_back - 0.6/2 + eps])
      cube([display_width-2, display_height-2, 0.6], center=true);
  }
}

display_module_connected();