// config.js
const CONFIG = {
  supabaseUrl: "https://brdaxznbrvhikmigswza.supabase.co",
  supabaseKey: "sb_publishable_vHrD3BIBf3tzn8hyLt8P9Q_KT1mm2y-",
  cloudinaryCloud: "dhruvin",
  cloudinaryUploadPreset: "indoor-campus-navigation"
};

if (typeof window !== "undefined") {
    window.CONFIG = CONFIG;
}
