// Utility function to toggle display of elements
function toggleDisplay(elementId, displayStyle) {
    document.getElementById(elementId).style.display = displayStyle;
}

// Show Add Safe Zone Form
function showAddZoneForm() {
    toggleDisplay("add-zone-form", "block");
    toggleDisplay("zones", "none");
    toggleDisplay("header-container", "flex");
    toggleDisplay("search-container", "none");
    toggleDisplay("return-zone-btn", "flex");
    toggleDisplay("add-zone-btn", "none");
    toggleDisplay("table-container", "none");
}

// Hide Add Safe Zone Form
function hideAddZoneForm() {
    toggleDisplay("add-zone-form", "none");
    toggleDisplay("zones", "block");
    toggleDisplay("header-container", "flex");
    toggleDisplay("search-container", "block");
    toggleDisplay("return-zone-btn", "none");
    toggleDisplay("add-zone-btn", "flex");
    toggleDisplay("table-container", "flex");

    // Clear all input fields
    ["zone-name", "zone-x", "zone-y", "zone-z", "zone-radius"].forEach(id => {
        document.getElementById(id).value = '';
    });
}

// Filter zones by name
function filterZonesByName() {
    const filterName = document.getElementById("filter-zone-name").value.toLowerCase();
    const zoneItems = document.querySelectorAll("#zones .zone-item");

    zoneItems.forEach(zoneItem => {
        const zoneName = zoneItem.querySelector('.strong-name').textContent.toLowerCase();
        zoneItem.style.display = zoneName.includes(filterName) || filterName === "" ? "flex" : "none";
    });
}

// Remove zone
function removeZone(id) {
    fetch(`https://${GetParentResourceName()}/removeZone`, {
        method: "POST",
        body: JSON.stringify({ id })
    });
}

// Display zones in the UI
window.addEventListener('message', function(event) {
    const data = event.data;

    switch (data.action) {
        case 'show':
            $('.safezone').show(100);
            break;
        case 'hide':
            $('.safezone').hide(100);
            break;
        case 'updateZones':
            updateZones(data.zones);
            break;
        case 'toggleUI':
            toggleDisplay("manager", data.state ? 'block' : 'none');
            break;
        case 'closeUI':
            toggleDisplay("manager", 'none');
            hideAddZoneForm();
            break;
    }
});

function updateZones(zones) {
    const zonesElement = document.getElementById("zones");
    zonesElement.innerHTML = ''; // Clear existing zones

    zones.forEach(zone => {
        const zoneElement = document.createElement('div');
        zoneElement.classList.add('zone-item');
        zoneElement.dataset.id = zone.id;
        zoneElement.innerHTML = `
            <strong class="strong-id">${zone.id}</strong>
            <strong class="strong-name">${zone.name}</strong><br>
            <p> vec3(${zone.x}, ${zone.y}, ${zone.z})</p><br>
            <h3 class="radius-text">${zone.radius}</h3>
            <div class="zone-buttons">
                <div class="flex gap-2 text-gray-600 hover:scale-110 duration-200 hover:cursor-pointer" onclick="removeZone(${zone.id})">
                    <svg class="w-6 stroke-red-700" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        <line x1="10" y1="11" x2="10" y2="17"></line>
                        <line x1="14" y1="11" x2="14" y2="17"></line>
                    </svg>
                    <button class="font-semibold text-sm text-red-700">Delete</button>
                </div>
            </div>
        `;
        zonesElement.appendChild(zoneElement);
    });
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

function closeUI() {
    fetch(`https://${GetParentResourceName()}/closeUI`, { method: "POST" });
}

function addZone() {
    const inputs = ["zone-name", "zone-x", "zone-y", "zone-z", "zone-radius"].map(id => document.getElementById(id).value);

    if (inputs.some(input => !input)) {
        showAlert();
        return;
    }

    const [name, x, y, z, radius] = inputs.map((value, index) => index === 0 ? value : parseFloat(value));

    fetch(`https://${GetParentResourceName()}/addZone`, {
        method: "POST",
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, x, y, z, radius })
    });

    hideAddZoneForm();
}

function showAlert() {
    fetch(`https://${GetParentResourceName()}/showAlert`, {
        method: "POST",
    });
}

// Function to fill coordinates with player's current position
function fillcoords() {
    fetch(`https://${GetParentResourceName()}/getPlayerCoords`, { method: "POST" })
        .then(response => response.json())
        .then(data => {
            ["zone-x", "zone-y", "zone-z"].forEach((id, index) => {
                document.getElementById(id).value = data[['x', 'y', 'z'][index]];
            });
        })
        .catch(error => console.error('Error fetching player coordinates:', error));
}