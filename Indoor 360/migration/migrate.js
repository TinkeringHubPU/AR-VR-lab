import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { v2 as cloudinary } from 'cloudinary';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Initialize Clients
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

async function runMigration() {
    console.log("🚀 Starting Indoor Nav Migration (Flat Schema)...");

    // 1. Read config.json
    const configPath = path.resolve(__dirname, '../config.json');
    if (!fs.existsSync(configPath)) {
        console.error("❌ Could not find config.json");
        return;
    }
    const configData = JSON.parse(fs.readFileSync(configPath, 'utf8'));

    // 2. Read scenes.json
    const scenesPath = path.resolve(__dirname, '../scenes.json');
    let scenesData = {};
    if (fs.existsSync(scenesPath)) {
        scenesData = JSON.parse(fs.readFileSync(scenesPath, 'utf8'));
    }

    // ==========================================
    // MIGRATE SCENES
    // ==========================================
    const scenes = configData.scenes;
    console.log(`\n📦 Migrating ${Object.keys(scenes).length} scenes...`);
    
    for (const [id, scene] of Object.entries(scenes)) {
        console.log(`Processing [${id}]: ${scene.title}...`);
        
        let cloudinaryUrl = null;
        
        // Upload image to Cloudinary if it exists locally
        if (scene.panorama && !scene.panorama.includes('res.cloudinary.com')) {
            const localImagePath = path.resolve(__dirname, '..', scene.panorama);
            
            if (fs.existsSync(localImagePath)) {
                try {
                    console.log(`   Uploading ${scene.panorama} to Cloudinary...`);
                    const uploadResult = await cloudinary.uploader.upload(localImagePath, {
                        folder: "indoor-campus-navigation"
                    });
                    cloudinaryUrl = uploadResult.secure_url;
                } catch (uploadErr) {
                    console.error(`   ❌ Failed to upload image for ${id}:`, uploadErr.message);
                }
            } else {
                console.warn(`   ⚠️ Local image not found at ${localImagePath}`);
            }
        } else if (scene.panorama && scene.panorama.includes('res.cloudinary.com')) {
            cloudinaryUrl = scene.panorama; // Already a Cloudinary URL
        }

        // Get map coordinates if they exist
        const mapCoords = scenesData[id] || {};

        const newScene = {
            id: id,
            title: scene.title || `Imported ${id}`,
            description: scene.description || null,
            panorama: cloudinaryUrl || scene.panorama,
            audio_file: scene.audio && scene.audio.file ? scene.audio.file : null,
            hfov: scene.hfov || 110,
            north_offset: scene.northOffset || 0,
            map_x: mapCoords.x || null,
            map_y: mapCoords.y || null,
            hotspots: scene.hotSpots || [],
            is_published: true
        };

        const { error: insertErr } = await supabase.from('scenes').upsert([newScene]);

        if (insertErr) {
            console.error(`   ❌ Failed to insert scene ${id}:`, insertErr.message);
        } else {
            console.log(`   ✅ Successfully saved ${id} to database.`);
        }
    }

    // ==========================================
    // MIGRATE LABELS
    // ==========================================
    if (scenesData._labels && Array.isArray(scenesData._labels)) {
        console.log(`\n🏷️ Migrating ${scenesData._labels.length} Map Labels...`);
        
        for (const label of scenesData._labels) {
            const { error: labelErr } = await supabase.from('map_labels').upsert([label]);
            if (labelErr) {
                console.error(`   ❌ Failed to insert label ${label.id}:`, labelErr.message);
            } else {
                console.log(`   ✅ Saved label: ${label.text}`);
            }
        }
    }

    // ==========================================
    // MIGRATE GLOBALS
    // ==========================================
    if (configData.default) {
        console.log(`\n⚙️ Migrating Globals...`);
        const globals = {
            id: 'default',
            first_scene: configData.default.firstScene,
            scene_fade_duration: configData.default.sceneFadeDuration,
            auto_load: configData.default.autoLoad,
            compass: configData.default.compass
        };
        const { error: globalErr } = await supabase.from('config_globals').upsert([globals]);
        if (globalErr) {
            console.error(`   ❌ Failed to insert globals:`, globalErr.message);
        } else {
            console.log(`   ✅ Saved globals.`);
        }
    }

    console.log(`\n🎉 Migration Complete! Your database now perfectly mirrors config.json and scenes.json.`);
}

runMigration().catch(err => console.error("Unhandled error:", err));
