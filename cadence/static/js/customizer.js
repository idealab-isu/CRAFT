/**
 * CADence Parameter Customizer
 *
 * Generates interactive UI controls for OpenSCAD parameters
 * Supports sliders with ranges and real-time updates
 */

class ParameterCustomizer {
    constructor(containerId, options = {}) {
        this.container = document.getElementById(containerId);
        if (!this.container) {
            console.error(`Container ${containerId} not found`);
            return;
        }

        this.parameters = {};
        this.onChange = options.onChange || (() => {});
        this.autoUpdate = options.autoUpdate || false;
        this.sessionId = options.sessionId || null;
    }

    /**
     * Load parameters and generate UI controls
     * @param {Object} parameters - Dictionary of parameter metadata
     */
    loadParameters(parameters) {
        this.parameters = parameters;
        this.render();
    }

    render() {
        // Clear existing content
        this.container.innerHTML = '';

        if (Object.keys(this.parameters).length === 0) {
            this.container.innerHTML = '<p class="no-params">No customizable parameters</p>';
            return;
        }

        // Create parameter controls
        for (const [name, meta] of Object.entries(this.parameters)) {
            const controlDiv = this.createControl(name, meta);
            this.container.appendChild(controlDiv);
        }

        // Add action buttons
        const actionsDiv = document.createElement('div');
        actionsDiv.className = 'customizer-actions';

        const applyBtn = document.createElement('button');
        applyBtn.className = 'btn-apply';
        applyBtn.textContent = 'Apply Changes';
        applyBtn.onclick = () => this.applyChanges();

        const resetBtn = document.createElement('button');
        resetBtn.className = 'btn-reset';
        resetBtn.textContent = 'Reset';
        resetBtn.onclick = () => this.reset();

        actionsDiv.appendChild(applyBtn);
        actionsDiv.appendChild(resetBtn);

        this.container.appendChild(actionsDiv);

        // Auto-update checkbox
        const autoUpdateDiv = document.createElement('div');
        autoUpdateDiv.className = 'auto-update-control';

        const autoUpdateCheckbox = document.createElement('input');
        autoUpdateCheckbox.type = 'checkbox';
        autoUpdateCheckbox.id = 'auto-update-checkbox';
        autoUpdateCheckbox.checked = this.autoUpdate;
        autoUpdateCheckbox.onchange = (e) => {
            this.autoUpdate = e.target.checked;
        };

        const autoUpdateLabel = document.createElement('label');
        autoUpdateLabel.htmlFor = 'auto-update-checkbox';
        autoUpdateLabel.textContent = 'Auto-update';

        autoUpdateDiv.appendChild(autoUpdateCheckbox);
        autoUpdateDiv.appendChild(autoUpdateLabel);

        this.container.appendChild(autoUpdateDiv);
    }

    createControl(name, meta) {
        const controlDiv = document.createElement('div');
        controlDiv.className = 'param-control';

        const label = document.createElement('label');
        label.className = 'param-label';
        label.textContent = name;

        const valueDisplay = document.createElement('span');
        valueDisplay.className = 'param-value';
        valueDisplay.id = `param-value-${name}`;
        valueDisplay.textContent = meta.value !== undefined ? meta.value : 0;

        label.appendChild(valueDisplay);
        controlDiv.appendChild(label);

        // Check if it has range (slider) or options (dropdown)
        if (meta.min !== undefined && meta.max !== undefined) {
            // Slider control
            const slider = document.createElement('input');
            slider.type = 'range';
            slider.className = 'param-slider';
            slider.id = `param-${name}`;
            slider.min = meta.min;
            slider.max = meta.max;
            slider.step = meta.step || 1;
            slider.value = meta.value;

            slider.oninput = (e) => {
                const newValue = parseFloat(e.target.value);
                valueDisplay.textContent = newValue;

                if (this.autoUpdate) {
                    this.updateParameter(name, newValue);
                }
            };

            controlDiv.appendChild(slider);

            // Min/max labels
            const rangeLabels = document.createElement('div');
            rangeLabels.className = 'range-labels';
            rangeLabels.innerHTML = `<span>${meta.min}</span><span>${meta.max}</span>`;
            controlDiv.appendChild(rangeLabels);

        } else if (meta.options && Array.isArray(meta.options)) {
            // Dropdown control
            const select = document.createElement('select');
            select.className = 'param-select';
            select.id = `param-${name}`;

            for (const option of meta.options) {
                const optEl = document.createElement('option');
                optEl.value = option;
                optEl.textContent = option;
                if (option === meta.value) {
                    optEl.selected = true;
                }
                select.appendChild(optEl);
            }

            select.onchange = (e) => {
                const newValue = e.target.value;
                valueDisplay.textContent = newValue;

                if (this.autoUpdate) {
                    this.updateParameter(name, newValue);
                }
            };

            controlDiv.appendChild(select);

        } else {
            // Text input for other types
            const input = document.createElement('input');
            input.type = 'number';
            input.className = 'param-input';
            input.id = `param-${name}`;
            input.value = meta.value;

            input.onchange = (e) => {
                const newValue = parseFloat(e.target.value);
                valueDisplay.textContent = newValue;

                if (this.autoUpdate) {
                    this.updateParameter(name, newValue);
                }
            };

            controlDiv.appendChild(input);
        }

        return controlDiv;
    }

    getCurrentValues() {
        const values = {};

        for (const name of Object.keys(this.parameters)) {
            const element = document.getElementById(`param-${name}`);
            if (element) {
                values[name] = element.type === 'number' || element.type === 'range'
                    ? parseFloat(element.value)
                    : element.value;
            }
        }

        return values;
    }

    updateParameter(name, value) {
        this.parameters[name].value = value;
        this.onChange(name, value);
    }

    applyChanges() {
        const values = this.getCurrentValues();
        this.regenerateModel(values);
    }

    reset() {
        // Reload original values
        this.render();
    }

    async regenerateModel(parameters) {
        if (!this.sessionId) {
            console.error('No session ID available');
            return;
        }

        // Show loading state
        const applyBtn = this.container.querySelector('.btn-apply');
        if (applyBtn) {
            applyBtn.textContent = 'Regenerating...';
            applyBtn.disabled = true;
        }

        try {
            const response = await fetch('/regenerate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    session_id: this.sessionId,
                    parameters: parameters
                })
            });

            const data = await response.json();

            if (data.success) {
                // Update UI with new render
                window.dispatchEvent(new CustomEvent('model-regenerated', { detail: data }));

                // Show success feedback
                if (applyBtn) {
                    applyBtn.textContent = 'Applied ✓';
                    setTimeout(() => {
                        applyBtn.textContent = 'Apply Changes';
                        applyBtn.disabled = false;
                    }, 2000);
                }
            } else {
                console.error('Regeneration failed:', data.error);
                if (applyBtn) {
                    applyBtn.textContent = 'Error - Try Again';
                    applyBtn.disabled = false;
                }
            }
        } catch (error) {
            console.error('Regeneration error:', error);
            if (applyBtn) {
                applyBtn.textContent = 'Error - Try Again';
                applyBtn.disabled = false;
            }
        }
    }

    setSessionId(sessionId) {
        this.sessionId = sessionId;
    }
}

// Export for global use
window.ParameterCustomizer = ParameterCustomizer;
