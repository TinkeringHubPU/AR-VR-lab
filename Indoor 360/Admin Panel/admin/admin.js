// admin.js

const supabaseUrl = window.CONFIG.supabaseUrl;
const supabaseKey = window.CONFIG.supabaseKey;
const supabaseClient = window.supabase.createClient(supabaseUrl, supabaseKey);

// DOM Elements
const appContainer = document.getElementById('app-container');
const toastContainer = document.getElementById('toast-container');
const navLinks = document.querySelectorAll('.nav-link[data-target]');
const sections = document.querySelectorAll('.section');

// --- AUTHENTICATION DISABLED FOR EASE OF USE ---
async function initApp() {
    initDashboard();
}

// --- NAVIGATION ---
navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        // Remove active class from all
        navLinks.forEach(l => l.classList.remove('active'));
        sections.forEach(s => s.classList.remove('active'));
        
        // Add active class to clicked
        const targetId = e.currentTarget.dataset.target;
        e.currentTarget.classList.add('active');
        document.getElementById(targetId).classList.add('active');
    });
});

// --- TOAST NOTIFICATIONS ---
function showToast(message, type = 'info') {
    if (!toastContainer) return;
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <i class="ph ${type === 'success' ? 'ph-check-circle' : type === 'error' ? 'ph-x-circle' : 'ph-info'}"></i>
        <span>${message}</span>
    `;
    toastContainer.appendChild(toast);
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease forwards';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// --- CLOUDINARY WIDGET ---
let cloudinaryWidget;
if (window.cloudinary && window.CONFIG.cloudinaryCloud) {
    cloudinaryWidget = cloudinary.createUploadWidget({
        cloudName: window.CONFIG.cloudinaryCloud,
        uploadPreset: window.CONFIG.cloudinaryUploadPreset,
        folder: 'indoor-campus-navigation',
        sources: ['local', 'url', 'camera'],
        multiple: false,
        resourceType: 'image',
        clientAllowedFormats: ['jpg', 'jpeg', 'png', 'webp']
    }, (error, result) => {
        if (!error && result && result.event === "success") {
            const url = result.info.secure_url;
            document.getElementById('scene-panorama').value = url;
            showToast('Image uploaded successfully', 'success');
        }
    });

    const btnUpload = document.getElementById('btn-upload-cloudinary');
    if (btnUpload) {
        btnUpload.addEventListener('click', () => {
            cloudinaryWidget.open();
        }, false);
    }
}

// --- DASHBOARD INITIALIZATION ---
async function initDashboard() {
    loadGlobals();
    loadScenes();
    loadLabels();
}

// ==========================================
// 1. GLOBALS MANAGER
// ==========================================
async function loadGlobals() {
    const { data, error } = await supabaseClient.from('config_globals').select('*').eq('id', 'default').single();
    if (error) {
        if (error.code !== 'PGRST116') console.error("Error loading globals:", error); // ignore no rows
        return;
    }
    
    if (data) {
        document.getElementById('global-first-scene').value = data.first_scene || '';
        document.getElementById('global-fade').value = data.scene_fade_duration || 1200;
        document.getElementById('global-autoload').checked = data.auto_load;
        document.getElementById('global-compass').checked = data.compass;
    }
}

document.getElementById('btn-save-globals').addEventListener('click', async () => {
    const payload = {
        id: 'default',
        first_scene: document.getElementById('global-first-scene').value,
        scene_fade_duration: parseInt(document.getElementById('global-fade').value),
        auto_load: document.getElementById('global-autoload').checked,
        compass: document.getElementById('global-compass').checked
    };

    const { error } = await supabaseClient.from('config_globals').upsert(payload);
    if (error) showToast(error.message, 'error');
    else showToast('Global settings saved!', 'success');
});

// ==========================================
// 2. SCENES MANAGER
// ==========================================
let currentScenes = [];

async function loadScenes() {
    const { data, error } = await supabaseClient.from('scenes').select('*').order('id');
    if (error) {
        showToast(error.message, 'error');
        return;
    }
    
    currentScenes = data;
    const tbody = document.querySelector('#scenes-table tbody');
    tbody.innerHTML = '';
    
    data.forEach(scene => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td><strong>${scene.id}</strong></td>
            <td>${scene.title}</td>
            <td style="max-width:200px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                ${scene.description || '<span style="color:var(--text-secondary); font-style:italic">None</span>'}
            </td>
            <td style="max-width:200px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                <a href="${scene.panorama}" target="_blank" style="color:var(--primary)">${scene.panorama}</a>
            </td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-secondary btn-edit-scene" data-id="${scene.id}"><i class="ph ph-pencil"></i></button>
                    <button class="btn btn-danger btn-delete-scene" data-id="${scene.id}"><i class="ph ph-trash"></i></button>
                </div>
            </td>
        `;
        tbody.appendChild(tr);
    });

    // Attach listeners
    document.querySelectorAll('.btn-edit-scene').forEach(btn => {
        btn.addEventListener('click', (e) => openSceneModal(e.currentTarget.dataset.id));
    });
    document.querySelectorAll('.btn-delete-scene').forEach(btn => {
        btn.addEventListener('click', async (e) => {
            if(confirm('Delete this scene?')) {
                const id = e.currentTarget.dataset.id;
                await supabaseClient.from('scenes').delete().eq('id', id);
                loadScenes();
            }
        });
    });
}

function openSceneModal(sceneId = null) {
    const modal = document.getElementById('modal-scene');
    document.getElementById('scene-form').reset();
    document.getElementById('scene-id').readOnly = false;
    
    if (sceneId) {
        document.getElementById('scene-modal-title').textContent = 'Edit Scene';
        const scene = currentScenes.find(s => s.id === sceneId);
        if (scene) {
            document.getElementById('scene-id').value = scene.id;
            document.getElementById('scene-id').readOnly = true;
            document.getElementById('scene-title').value = scene.title;
            document.getElementById('scene-description').value = scene.description || '';
            document.getElementById('scene-panorama').value = scene.panorama;
            document.getElementById('scene-audio').value = scene.audio_file || '';
            document.getElementById('scene-hfov').value = scene.hfov;
            document.getElementById('scene-north').value = scene.north_offset;
            document.getElementById('scene-map-x').value = scene.map_x || '';
            document.getElementById('scene-map-y').value = scene.map_y || '';
            document.getElementById('scene-hotspots').value = JSON.stringify(scene.hotspots || [], null, 2);
        }
    } else {
        document.getElementById('scene-modal-title').textContent = 'Add Scene';
    }
    
    modal.classList.add('active');
}

document.getElementById('btn-add-scene').addEventListener('click', () => openSceneModal());

document.getElementById('scene-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    let hotspots = [];
    try {
        hotspots = JSON.parse(document.getElementById('scene-hotspots').value);
    } catch(err) {
        alert("Invalid JSON in Hotspots field.");
        return;
    }

    const payload = {
        id: document.getElementById('scene-id').value,
        title: document.getElementById('scene-title').value,
        description: document.getElementById('scene-description').value || null,
        panorama: document.getElementById('scene-panorama').value,
        audio_file: document.getElementById('scene-audio').value || null,
        hfov: parseInt(document.getElementById('scene-hfov').value) || 110,
        north_offset: parseInt(document.getElementById('scene-north').value) || 0,
        map_x: parseFloat(document.getElementById('scene-map-x').value) || null,
        map_y: parseFloat(document.getElementById('scene-map-y').value) || null,
        hotspots: hotspots,
        is_published: true
    };

    const { error } = await supabaseClient.from('scenes').upsert(payload);
    
    if (error) {
        showToast(error.message, 'error');
    } else {
        showToast('Scene saved', 'success');
        document.getElementById('modal-scene').classList.remove('active');
        loadScenes();
    }
});

// ==========================================
// 3. MAP LABELS MANAGER
// ==========================================
let currentLabels = [];

async function loadLabels() {
    const { data, error } = await supabaseClient.from('map_labels').select('*').order('id');
    if (error) return;
    
    currentLabels = data;
    const tbody = document.querySelector('#labels-table tbody');
    tbody.innerHTML = '';
    
    data.forEach(lbl => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${lbl.id}</td>
            <td><strong>${lbl.text}</strong></td>
            <td>${lbl.x}, ${lbl.y}</td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-secondary btn-edit-lbl" data-id="${lbl.id}"><i class="ph ph-pencil"></i></button>
                    <button class="btn btn-danger btn-delete-lbl" data-id="${lbl.id}"><i class="ph ph-trash"></i></button>
                </div>
            </td>
        `;
        tbody.appendChild(tr);
    });

    document.querySelectorAll('.btn-edit-lbl').forEach(btn => btn.addEventListener('click', (e) => openLabelModal(e.currentTarget.dataset.id)));
    document.querySelectorAll('.btn-delete-lbl').forEach(btn => {
        btn.addEventListener('click', async (e) => {
            if(confirm('Delete label?')) {
                await supabaseClient.from('map_labels').delete().eq('id', e.currentTarget.dataset.id);
                loadLabels();
            }
        });
    });
}

function openLabelModal(labelId = null) {
    const modal = document.getElementById('modal-label');
    document.getElementById('label-form').reset();
    document.getElementById('label-id').readOnly = false;
    
    if (labelId) {
        document.getElementById('label-modal-title').textContent = 'Edit Label';
        const lbl = currentLabels.find(l => l.id === labelId);
        if (lbl) {
            document.getElementById('label-id').value = lbl.id;
            document.getElementById('label-id').readOnly = true;
            document.getElementById('label-text').value = lbl.text;
            document.getElementById('label-x').value = lbl.x;
            document.getElementById('label-y').value = lbl.y;
            document.getElementById('label-size').value = lbl.size;
            document.getElementById('label-rotation').value = lbl.rotation;
        }
    } else {
        document.getElementById('label-modal-title').textContent = 'Add Label';
    }
    modal.classList.add('active');
}

document.getElementById('btn-add-label').addEventListener('click', () => openLabelModal());

document.getElementById('label-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const payload = {
        id: document.getElementById('label-id').value,
        text: document.getElementById('label-text').value,
        x: parseFloat(document.getElementById('label-x').value),
        y: parseFloat(document.getElementById('label-y').value),
        size: parseFloat(document.getElementById('label-size').value),
        rotation: parseFloat(document.getElementById('label-rotation').value)
    };

    const { error } = await supabaseClient.from('map_labels').upsert(payload);
    if (error) showToast(error.message, 'error');
    else {
        showToast('Label saved', 'success');
        document.getElementById('modal-label').classList.remove('active');
        loadLabels();
    }
});

// Modal Close Handlers
document.querySelectorAll('.modal-close, .modal-close-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
        e.target.closest('.modal-overlay').classList.remove('active');
    });
});

// Boot
initApp();
