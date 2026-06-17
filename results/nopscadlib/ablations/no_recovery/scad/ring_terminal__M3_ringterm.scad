// Parameters
terminal_type = 0; //[0:1:1]
material_thickness_mm = 1.0; //[0.5:2.0:0.1]
outer_diameter_mm = 10.0; //[5.0:20.0:0.5]
inner_diameter_mm = 5.0; //[2.5:10.0:0.5]
lug_width_mm = 6.0; //[3.0:12.0:0.5]
overall_length_mm = 20.0; //[10.0:40.0:1]
crimp_length_mm = 0.0; //[0.0:30.0:0.5]
wire_entry_hole_diameter_mm = 0.0; //[0.0:8.0:0.5]
bend_angle_deg = 45; //[0:90:5]
transition_length_mm = 1.0; //[0.5:3.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
lug_stem_length_mm = 8.0; //[4.0:20.0:0.5]
barrel_outer_diameter_mm = 6.0; //[3.0:12.0:0.5]

// Ring Lug Plate
module ring_lug_plate() {
  color("Silver") {
    difference() {
      linear_extrude(height=material_thickness_mm) {
        polygon(points=[
          [-outer_diameter_mm/2, 0],
          [outer_diameter_mm/2, 0],
          [lug_width_mm/2, -(outer_diameter_mm/2 + lug_stem_length_mm)],
          [-lug_width_mm/2, -(outer_diameter_mm/2 + lug_stem_length_mm)]
        ]);
      }
      translate([0, 0, material_thickness_mm/2])
        cylinder(r=inner_diameter_mm/2, h=material_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Crimp Barrel
module crimp_barrel() {
  color("Silver") {
    difference() {
      rotate([90, 0, 0])
        translate([0, -(outer_diameter_mm/2 + lug_stem_length_mm + transition_length_mm - overlap_mm), material_thickness_mm/2 + crimp_length_mm/2])
        cylinder(r=barrel_outer_diameter_mm/2, h=crimp_length_mm, center=true);
      rotate([90, 0, 0])
        translate([0, -(outer_diameter_mm/2 + lug_stem_length_mm + transition_length_mm - overlap_mm), material_thickness_mm/2 + crimp_length_mm/2])
        cylinder(r=(barrel_outer_diameter_mm - 2*material_thickness_mm)/2, h=crimp_length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Non-Crimp Tongue with Optional Hole
module non_crimp_tongue_with_optional_hole() {
  color("Silver") {
    difference() {
      translate([0, -(outer_diameter_mm/2 + lug_stem_length_mm + transition_length_mm + ((overall_length_mm - (outer_diameter_mm/2 + lug_stem_length_mm + transition_length_mm)) + overlap_mm)/2 - overlap_mm), material_thickness_mm/2])
        cube([lug_width_mm, (overall_length_mm - (outer_diameter_mm/2 + lug_stem_length_mm + transition_length_mm)) + overlap_mm, material_thickness_mm], center=true);
      if (wire_entry_hole_diameter_mm > 0) {
        translate([0, -(overall_length_mm - lug_width_mm/2), material_thickness_mm/2])
          cylinder(r=wire_entry_hole_diameter_mm/2, h=material_thickness_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Non-Crimp Attachment Union
module non_crimp_attachment_union() {
  color("Silver") {
    union() {
      translate([0, -(outer_diameter_mm/2 + lug_stem_length_mm + (transition_length_mm + overlap_mm)/2 - overlap_mm), material_thickness_mm/2])
        cube([lug_width_mm, transition_length_mm + overlap_mm, material_thickness_mm], center=true);
      non_crimp_tongue_with_optional_hole();
      translate([0, -(outer_diameter_mm/2 + lug_stem_length_mm + transition_length_mm + (overall_length_mm - (outer_diameter_mm/2 + lug_stem_length_mm + transition_length_mm))/2 - overlap_mm), material_thickness_mm/2])
        rotate([bend_angle_deg, 0, 0])
        cube([lug_width_mm, (overall_length_mm - (outer_diameter_mm/2 + lug_stem_length_mm + transition_length_mm)), material_thickness_mm], center=true);
    }
  }
}

// Ring Terminal
module ring_terminal() {
  union() {
    ring_lug_plate();
    if (terminal_type == 0) {
      non_crimp_attachment_union();
    }
  }
}

// Ring Terminal Assembly
module ring_terminal_assembly() {
  union() {
    ring_terminal();
    if (terminal_type == 1) {
      translate([0, 0, 0]) crimp_barrel();
    }
  }
}

// Final Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();