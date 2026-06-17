$fn = 128;

// Parameters
cell_height = 50.5; //[25.25:101:0.1]
cell_diameter = 14.5; //[7.25:29:0.1]

overlap = 0.8; //[0.5:2:0.1]
face_thickness = 0.6; //[0.3:1.2:0.1]

button_diameter = 5.5; //[2.75:11:0.1]
button_height = 1.2; //[0.6:2.4:0.1]

insulator_outer_diameter = 10.5; //[5.25:21:0.1]
insulator_inner_diameter = 6.2; //[3.1:12.4:0.1]
insulator_thickness = 0.4; //[0.2:0.8:0.05]

label_thickness = 0.25; //[0.1:0.6:0.05]
label_height = 46; //[23:92:0.5]

fillet_radius = 0.6; //[0.2:1.5:0.1]

// Derived
cell_r = cell_diameter/2;
z_top = cell_height/2;
z_bot = -cell_height/2;

// Base Shapes
module cell_body() {
  cylinder(h=cell_height, r=cell_r, center=true);
}

module top_face() {
  translate([0, 0, z_top - face_thickness/2 + overlap/2])
    cylinder(h=face_thickness, r=cell_r, center=true);
}

module bottom_face() {
  translate([0, 0, z_bot + face_thickness/2 - overlap/2])
    cylinder(h=face_thickness, r=cell_r, center=true);
}

module positive_terminal_button() {
  // Ensure it intersects the top face/body by "overlap"
  translate([0, 0, z_top + button_height/2 - overlap])
    cylinder(h=button_height, r=button_diameter/2, center=true);
}

module top_insulator_ring() {
  // Place ring so it intersects the top face/body by "overlap"
  translate([0, 0, z_top + insulator_thickness/2 - overlap])
    difference() {
      cylinder(h=insulator_thickness, r=insulator_outer_diameter/2, center=true);
      cylinder(h=insulator_thickness + 2*overlap, r=insulator_inner_diameter/2, center=true);
    }
}

module side_label_shell() {
  // Centered on body; label is a thin sleeve that intersects the body (one connected solid)
  difference() {
    cylinder(h=label_height, r=cell_r + label_thickness, center=true);
    cylinder(h=label_height + 2*overlap, r=cell_r - overlap, center=true);
  }
}

module battery_union_raw() {
  union() {
    cell_body();
    top_face();
    bottom_face();
    positive_terminal_button();
    top_insulator_ring();
    side_label_shell();
  }
}

// Final Output (fillet via minkowski; keep connected by using unioned solid)
minkowski() {
  battery_union_raw();
  sphere(r=fillet_radius);
}