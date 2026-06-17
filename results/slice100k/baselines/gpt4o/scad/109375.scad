module crossbar_rod() {
    rod_length = 149.2;
    rod_width = 2.6;
    rod_height = 27.2;
    tab_width = 27.2;
    tab_height = 2.6;
    tab_thickness = 2.6;
    num_tabs = 5;
    tab_spacing = rod_length / (num_tabs + 1);

    // Main rod
    translate([-rod_length / 2, -rod_width / 2, -rod_height / 2])
        cube([rod_length, rod_width, rod_height]);

    // Tabs
    for (i = [1:num_tabs]) {
        translate([-tab_width / 2, -tab_thickness / 2, -rod_height / 2 + i * tab_spacing])
            cube([tab_width, tab_thickness, tab_height]);
    }
}

crossbar_rod();