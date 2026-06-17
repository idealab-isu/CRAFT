// Ruideng-style panel meter / power supply module (ONE connected solid)
// Fixes vs. prior: adds recognizable front face (bezel + through screen window + button recesses),
// adds rear connector/terminal block with screw bosses + pin header + cable strain relief,
// adds side mounting ears, all placed with dimension-driven formulas and intentional overlaps.

$fn = 64;

// -------------------- Parameters --------------------
overall_size_x = 48; //[24:96:1]
overall_size_y = 29; //[15:58:1]
body_depth_behind_panel = 26; //[13:52:1]

bezel_size_x = 52; //[26:104:1]
bezel_size_y = 33; //[17:66:1]
bezel_thickness_z = 3; //[1.5:6:0.1]
bezel_corner_radius = 2.5; //[1.25:5:0.1]

aperture_size_x = 36; //[18:72:0.5]
aperture_size_y = 18; //[9:36:0.5]
aperture_corner_radius = 1.2; //[0.6:2.4:0.1]
inner_aperture_offset_x = 0; //[-5:5:0.1]
inner_aperture_offset_y = 2; //[-5:5:0.1]  // slightly up like many panel meters

// Front face details
screen_lip = 1.2;            // border around aperture for shallow recess
screen_recess_depth = 1.0;   // shallow recess around window
window_clearance = 0.4;      // slightly larger than aperture for through opening

button_count = 3; //[0:4:1]
button_size_x = 6; //[3:12:0.5]
button_size_y = 4; //[2:8:0.5]
button_height_z = 1.2; //[0.6:2.4:0.1]
button_row_offset_y = -10; //[-16:0:0.5]
button_spacing_x = 8; //[4:16:0.5]
button_corner_r = 0.7;

// Side mounting ears (common on panel modules)
ear_w = 6;   //[3:12:0.5]
ear_h = 10;  //[5:20:0.5]
ear_t = 2.2; //[1:4:0.1]

// Rear features
terminal_block_w = 18;
terminal_block_h = 10;
terminal_block_d = 8;

screw_boss_r = 2.2;
screw_boss_h = 2.0;

pin_header_w = 14;
pin_header_h = 5;
pin_header_d = 6;

strain_relief_w = 10;
strain_relief_h = 6;
strain_relief_d = 6;

// Internal PCB slab (kept solid, connected)
pcb_size_x = 44; //[22:88:1]
pcb_size_y = 25; //[12.5:50:1]
pcb_size_z = 1.6;
pcb_z_offset_from_front = 10; //[0:20:0.5]

// General
overlap = 1; //[0.5:2:0.1]

// -------------------- Helpers --------------------
module rounded_rect_2d(x, y, r) {
  rr = min(r, x/2, y/2);
  hull() {
    for (sx = [-1,1], sy = [-1,1])
      translate([sx*(x/2-rr), sy*(y/2-rr)]) circle(r=rr);
  }
}

module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
  x = size[0]; y = size[1]; z = size[2];
  translate(center ? [0,0,0] : [x/2,y/2,z/2])
    linear_extrude(height=z, center=true)
      rounded_rect_2d(x, y, r);
}

// -------------------- Coordinate references --------------------
// Front face plane at z = 0 (bezel front). Positive z goes outward (toward viewer).
// Bezel occupies z in [0, bezel_thickness_z]. Body extends behind panel into negative z.

function body_center_z() = -(body_depth_behind_panel/2) + overlap/2;
function body_back_face_z() = body_center_z() - body_depth_behind_panel/2;
function body_front_face_z() = body_center_z() + body_depth_behind_panel/2;

// -------------------- Parts --------------------
module front_bezel() {
  // Bezel with: shallow recess around screen + THROUGH window opening + button recesses.
  difference() {
    // Outer bezel solid
    translate([0,0,bezel_thickness_z/2])
      rounded_rect_prism([bezel_size_x, bezel_size_y, bezel_thickness_z], bezel_corner_radius, center=true);

    // Shallow recess around window (not through)
    recess_x = aperture_size_x + 2*screen_lip;
    recess_y = aperture_size_y + 2*screen_lip;
    translate([inner_aperture_offset_x, inner_aperture_offset_y,
               bezel_thickness_z - screen_recess_depth/2 + overlap/2])
      rounded_rect_prism([recess_x, recess_y, screen_recess_depth + overlap],
                         aperture_corner_radius, center=true);

    // Through window opening (screen cutout)
    win_x = aperture_size_x + window_clearance;
    win_y = aperture_size_y + window_clearance;
    translate([inner_aperture_offset_x, inner_aperture_offset_y, bezel_thickness_z/2])
      rounded_rect_prism([win_x, win_y, bezel_thickness_z + 2*overlap],
                         aperture_corner_radius, center=true);

    // Button recess pockets (so buttons are distinct when added as solids)
    if (button_count > 0) {
      pocket_z = bezel_thickness_z - (button_height_z*0.6)/2 + overlap/2;
      pocket_h = button_height_z*0.6 + overlap;
      for (i = [0:button_count-1]) {
        bx = (i - (button_count-1)/2) * button_spacing_x;
        translate([bx, button_row_offset_y, pocket_z])
          rounded_rect_prism([button_size_x+0.6, button_size_y+0.6, pocket_h],
                             button_corner_r, center=true);
      }
    }
  }
}

module rear_body() {
  // Main body behind panel; overlaps into bezel to guarantee union.
  // Body front face slightly intrudes into bezel back.
  // Place so body front face is at z = overlap (inside bezel volume).
  // With center at body_center_z(), front face is body_front_face_z().
  // We want body_front_face_z() = overlap => body_center_z = overlap - d/2.
  cz = overlap - body_depth_behind_panel/2;
  translate([0,0,cz])
    rounded_rect_prism([overall_size_x, overall_size_y, body_depth_behind_panel], r=1.2, center=true);
}

module side_ears() {
  // Small ears on left/right, centered in Y, near bezel plane, intersecting body.
  // Place at body front region so they are visible in top/bottom views.
  xoff = overall_size_x/2 + ear_w/2 - overlap;
  // Put ears around the panel plane (z ~ 0) but ensure they intersect body (body reaches to z=overlap).
  zc = overlap - ear_t/2; // intersects body at its front
  translate([-xoff, 0, zc]) rounded_rect_prism([ear_w, ear_h, ear_t], r=1.0, center=true);
  translate([ xoff, 0, zc]) rounded_rect_prism([ear_w, ear_h, ear_t], r=1.0, center=true);
}

module buttons() {
  // Buttons protrude from bezel front, overlapping into bezel for union.
  if (button_count > 0) {
    zc = bezel_thickness_z + button_height_z/2 - overlap; // overlap into bezel
    for (i = [0:button_count-1]) {
      bx = (i - (button_count-1)/2) * button_spacing_x;
      translate([bx, button_row_offset_y, zc])
        rounded_rect_prism([button_size_x, button_size_y, button_height_z], r=button_corner_r, center=true);
    }
  }
}

module pcb_inside() {
  // PCB slab inside body, connected by overlap (touches body).
  // Place a bit behind the panel plane.
  // Body front face is at z=overlap; place PCB center at z = overlap - pcb_z_offset_from_front - pcb_thickness/2
  zc = overlap - pcb_z_offset_from_front - pcb_size_z/2;
  translate([0,0,zc])
    cube([pcb_size_x, pcb_size_y, pcb_size_z], center=true);
}

module rear_connectors() {
  // Terminal block + pin header + strain relief, all attached to rear face.
  // Rear face of body at z = (overlap - body_depth_behind_panel).
  rear_face_z = overlap - body_depth_behind_panel;

  // Terminal block centered, protruding further back (negative z)
  term_zc = rear_face_z - terminal_block_d/2 + overlap; // overlap into body
  translate([0, 0, term_zc])
    rounded_rect_prism([terminal_block_w, terminal_block_h, terminal_block_d], r=1.0, center=true);

  // Two screw bosses on terminal block front edge (still solid)
  boss_y = terminal_block_h/4;
  boss_x = terminal_block_w/4;
  boss_zc = term_zc - terminal_block_d/2 + screw_boss_h/2 - overlap/2; // on rear-most face, still intersect
  translate([-boss_x, boss_y, boss_zc]) cylinder(r=screw_boss_r, h=screw_boss_h, center=true);
  translate([ boss_x, boss_y, boss_zc]) cylinder(r=screw_boss_r, h=screw_boss_h, center=true);

  // Pin header block below terminal block (common on these modules)
  header_y = -(terminal_block_h/2 + pin_header_h/2 - overlap);
  header_zc = rear_face_z - pin_header_d/2 + overlap;
  translate([0, header_y, header_zc])
    rounded_rect_prism([pin_header_w, pin_header_h, pin_header_d], r=0.8, center=true);

  // Strain relief / cable exit nub on one side of terminal block
  sr_x = terminal_block_w/2 + strain_relief_w/2 - overlap;
  sr_zc = rear_face_z - strain_relief_d/2 + overlap;
  translate([sr_x, 0, sr_zc])
    rounded_rect_prism([strain_relief_w, strain_relief_h, strain_relief_d], r=1.0, center=true);
}

// -------------------- Assembly (ONE connected solid) --------------------
module assembly() {
  union() {
    front_bezel();
    rear_body();
    side_ears();
    buttons();
    pcb_inside();
    rear_connectors();
  }
}

assembly();