$fn=128;

cell_height = 61.5;
cell_diameter = 34.2;

module battery_cell(h=cell_height, d=cell_diameter) {
    cylinder(h=h, d=d, center=true);
}

battery_cell();