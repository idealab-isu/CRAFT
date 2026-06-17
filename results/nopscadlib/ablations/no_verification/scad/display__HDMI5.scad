$fn = 64;

// Parameters
display_width = 121; //[60.5:242:0.5]
display_height = 76; //[38:152:0.5]
display_thickness = 2.85; //[1.4:5.7:0.05]

pcb_offset_x = 0; //[-10:10:0.5]
pcb_offset_y = 0; //[-10:10:0.5]
pcb_offset_z = 1.9; //[0:10:0.1]

aperture_min_x = -54; //[-108:-27:0.5]
aperture_min_y = -30.225; //[-60.45:-15.1125:0.5]
aperture_max_x = 54; //[27:108:0.5]
aperture_max_y = 34.575; //[17.2875:69.15:0.5]
aperture_depth = 0.5; //[0.2:2:0.1]

touch_min_x = -58.7; //[-117.4:-29.35:0.5]
touch_min_y = -34; //[-68:-17:0.5]
touch_max_x = 58.7; //[29.35:117.4:0.5]
touch_max_y = 36.25; //[18.125:72.5:0.5]
touch_thickness = 1; //[0.5:3:0.1]

bezel_thickness = 3; //[1.5:8:0.25]
bezel_margin = 4; //[2:12:0.5]
overlap = 1; //[0.5:2:0.1]

pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_width = 110; //[55:220:0.5]
pcb_height = 65; //[32.5:130:0.5]
pcb_back_clearance = 2; //[1:8:0.25]

mount_boss_radius = 3.5; //[2:7:0.25]
mount_hole_radius = 1.6; //[1:3:0.1]
mount_boss_inset = 8; //[4:20:0.5]
thread_length = 2; // thread length

ts_ribbon_min_x = -2.5; //[-10:0:0.5]
ts_ribbon_min_y = -39; //[-78:-19.5:0.5]
ts_ribbon_max_x = 10.5; //[5.25:21:0.5]
ts_ribbon_max_y = -33; //[-66:-16.5:0.5]
ts_ribbon_depth = 6; //[3:15:0.5]

hdmi_width = 14; //[7:28:0.5]
hdmi_height = 6; //[3:12:0.25]
hdmi_depth = 12; //[6:24:0.5]

knob_radius = 6; //[3:12:0.5]
knob_height = 5; //[2.5:12:0.5]
knob_shaft_radius = 1.5; //[0.8:3:0.1]
knob_shaft_length = 6; //[3:15:0.5]

// Derived sizes/centers
ap_w = aperture_max_x - aperture_min_x;
ap_h = aperture_max_y - aperture_min_y;
ap_cx = (aperture_min_x + aperture_max_x)/2;
ap_cy = (aperture_min_y + aperture_max_y)/2;

ts_w = touch_max_x - touch_min_x;
ts_h = touch_max_y - touch_min_y;
ts_cx = (touch_min_x + touch_max_x)/2;
ts_cy = (touch_min_y + touch_max_y)/2;

rib_w = ts_ribbon_max_x - ts_ribbon_min_x;
rib_h = ts_ribbon_max_y - ts_ribbon_min_y;
rib_cx = (ts_ribbon_min_x + ts_ribbon_max_x)/2;
rib_cy = (ts_ribbon_min_y + ts_ribbon_max_y)/2;

bezel_w = display_width + 2*bezel_margin;
bezel_h = display_height + 2*bezel_margin;

// Z stack (centered around display at z=0)
z_display_c = 0;
z_display_top = z_display_c + display_thickness/2;
z_display_bot = z_display_c - display_thickness/2;

z_touch_c = z_display_top + touch_thickness/2 - overlap; // touch sits on display
z_touch_top = z_touch_c + touch_thickness/2;
z_touch_bot = z_touch_c - touch_thickness/2;

z_bezel_c = z_touch_top + bezel_thickness/2 - overlap;   // bezel sits on touch
z_bezel_top = z_bezel_c + bezel_thickness/2;
z_bezel_bot = z_bezel_c - bezel_thickness/2;

z_pcb_c = z_display_bot - pcb_offset_z - pcb_thickness/2 + overlap; // pcb behind display
z_pcb_top = z_pcb_c + pcb_thickness/2;
z_pcb_bot = z_pcb_c - pcb_thickness/2;

// Helpers
module box_xy(x0, y0, x1, y1, z0, z1) {
  translate([(x0+x1)/2, (y0+y1)/2, (z0+z1)/2])
    cube([abs(x1-x0), abs(y1-y0), abs(z1-z0)], center=true);
}

// Main connected solid (single manifold)
module connected_solid() {

  // Mount boss placement (used by multiple parts)
  boss_x = pcb_offset_x + pcb_width/2 - mount_boss_inset;
  boss_y = pcb_offset_y + pcb_height/2 - mount_boss_inset;

  // Boss spans from PCB top down to knob bottom (guaranteed connectivity)
  boss_top = z_pcb_top + overlap;
  boss_bot = (z_pcb_bot - pcb_back_clearance - knob_shaft_length - knob_height) - overlap;
  boss_h = boss_top - boss_bot;
  boss_zc = (boss_top + boss_bot)/2;

  // Knob + shaft Z (attached to boss bottom)
  knob_top = boss_bot + knob_height + overlap;
  knob_bot = boss_bot - overlap;
  knob_zc = (knob_top + knob_bot)/2;

  shaft_top = boss_bot + knob_shaft_length + overlap;
  shaft_bot = boss_bot - overlap;
  shaft_zc = (shaft_top + shaft_bot)/2;

  union() {

    // Bezel with real aperture cut-through + ribbon clearance notch
    color("Silver")
    difference() {
      translate([0,0,z_bezel_c])
        cube([bezel_w, bezel_h, bezel_thickness], center=true);

      // Display aperture: cut from bezel front face down to specified depth
      // (front face = +Z)
      translate([ap_cx, ap_cy, z_bezel_top - aperture_depth/2])
        cube([ap_w, ap_h, aperture_depth + 2*overlap], center=true);

      // Touchscreen ribbon clearance: cut from bezel bottom face upward
      translate([rib_cx, rib_cy, z_bezel_bot + ts_ribbon_depth/2])
        cube([rib_w, rib_h, ts_ribbon_depth + 2*overlap], center=true);
    }

    // Touchscreen glass outline/overhang (visible in ortho views)
    // Slightly overlaps into bezel and display to keep one connected solid.
    color([0.2,0.2,0.2,0.35])
      translate([ts_cx, ts_cy, z_touch_c])
        cube([ts_w, ts_h, touch_thickness + 2*overlap], center=true);

    // Display body
    color("Black")
      translate([0,0,z_display_c])
        cube([display_width, display_height, display_thickness], center=true);

    // PCB (connected to display via overlap)
    color([0.0, 0.4, 0.2])
      translate([pcb_offset_x, pcb_offset_y, z_pcb_c])
        cube([pcb_width, pcb_height, pcb_thickness], center=true);

    // HDMI connector (attached to PCB edge, not floating)
    color("DimGray")
      translate([
        pcb_offset_x,
        pcb_offset_y - pcb_height/2 - hdmi_depth/2 + overlap,
        z_pcb_top - overlap + hdmi_height/2
      ])
        cube([hdmi_width, hdmi_depth, hdmi_height], center=true);

    // Mount boss + threaded hole (thread length = 2mm)
    color("Gray")
    difference() {
      translate([boss_x, boss_y, boss_zc])
        cylinder(r=mount_boss_radius, h=boss_h, center=true);

      // Threaded hole: 2mm deep from the very bottom of boss upward
      translate([boss_x, boss_y, boss_bot + thread_length/2])
        cylinder(r=mount_hole_radius, h=thread_length + 2*overlap, center=true);
    }

    // Knob: attached to boss bottom (no floating)
    color("Brass")
      translate([boss_x, boss_y, knob_zc])
        cylinder(r=knob_radius, h=(knob_top - knob_bot), center=true);

    // Shaft: overlaps into boss bottom and into knob
    color("Brass")
      translate([boss_x, boss_y, shaft_zc])
        cylinder(r=knob_shaft_radius, h=(shaft_top - shaft_bot), center=true);
  }
}

connected_solid();