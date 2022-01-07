use std::collections::HashMap;
use std::env;
use env::consts;
use std::path::{Path, PathBuf};

pub const CONTAINER_IMAGE_NAME: &str = "localhost/dangerzone-converter";
pub const CONTAINER_IMAGE_EXE: &str = "/usr/local/bin/dangerzone-container";

pub fn ocr_lang_key_by_name() -> HashMap<&'static str, &'static str> {
    [
        ("Afrikaans", "ar"),
        ("Albanian", "sqi"),
        ("Amharic", "amh"),
        ("Arabic", "ara"),
        ("Arabic script", "Arabic"),
        ("Armenian", "hye"),
        ("Armenian script", "Armenian"),
        ("Assamese", "asm"),
        ("Azerbaijani", "aze"),
        ("Azerbaijani (Cyrillic)", "aze_cyrl"),
        ("Basque", "eus"),
        ("Belarusian", "bel"),
        ("Bengali", "ben"),
        ("Bengali script", "Bengali"),
        ("Bosnian", "bos"),
        ("Breton", "bre"),
        ("Bulgarian", "bul"),
        ("Burmese", "mya"),
        ("Canadian Aboriginal script", "Canadian_Aboriginal"),
        ("Catalan", "cat"),
        ("Cebuano", "ceb"),
        ("Cherokee", "chr"),
        ("Cherokee script", "Cherokee"),
        ("Chinese - Simplified", "chi_sim"),
        ("Chinese - Simplified (vertical)", "chi_sim_vert"),
        ("Chinese - Traditional", "chi_tra"),
        ("Chinese - Traditional (vertical)", "chi_tra_vert"),
        ("Corsican", "cos"),
        ("Croatian", "hrv"),
        ("Cyrillic script", "Cyrillic"),
        ("Czech", "ces"),
        ("Danish", "dan"),
        ("Devanagari script", "Devanagari"),
        ("Divehi", "div"),
        ("Dutch", "nld"),
        ("Dzongkha", "dzo"),
        ("English", "eng"),
        ("English, Middle (1100-1500)", "enm"),
        ("Esperanto", "epo"),
        ("Estonian", "est"),
        ("Ethiopic script", "Ethiopic"),
        ("Faroese", "fao"),
        ("Filipino", "fil"),
        ("Finnish", "fin"),
        ("Fraktur script", "Fraktur"),
        ("Frankish", "frk"),
        ("French", "fra"),
        ("French, Middle (ca.1400-1600)", "frm"),
        ("Frisian (Western)", "fry"),
        ("Gaelic (Scots)", "gla"),
        ("Galician", "glg"),
        ("Georgian", "kat"),
        ("Georgian script", "Georgian"),
        ("German", "deu"),
        ("Greek", "ell"),
        ("Greek script", "Greek"),
        ("Gujarati", "guj"),
        ("Gujarati script", "Gujarati"),
        ("Gurmukhi script", "Gurmukhi"),
        ("Hangul script", "Hangul"),
        ("Hangul (vertical) script", "Hangul_vert"),
        ("Han - Simplified script", "HanS"),
        ("Han - Simplified (vertical) script", "HanS_vert"),
        ("Han - Traditional script", "HanT"),
        ("Han - Traditional (vertical) script", "HanT_vert"),
        ("Hatian", "hat"),
        ("Hebrew", "heb"),
        ("Hebrew script", "Hebrew"),
        ("Hindi", "hin"),
        ("Hungarian", "hun"),
        ("Icelandic", "isl"),
        ("Indonesian", "ind"),
        ("Inuktitut", "iku"),
        ("Irish", "gle"),
        ("Italian", "ita"),
        ("Italian - Old", "ita_old"),
        ("Japanese", "jpn"),
        ("Japanese script", "Japanese"),
        ("Japanese (vertical)", "jpn_vert"),
        ("Japanese (vertical) script", "Japanese_vert"),
        ("Javanese", "jav"),
        ("Kannada", "kan"),
        ("Kannada script", "Kannada"),
        ("Kazakh", "kaz"),
        ("Khmer", "khm"),
        ("Khmer script", "Khmer"),
        ("Korean", "kor"),
        ("Korean (vertical)", "kor_vert"),
        ("Kurdish (Arabic)", "kur_ara"),
        ("Kyrgyz", "kir"),
        ("Lao", "lao"),
        ("Lao script", "Lao"),
        ("Latin", "lat"),
        ("Latin script", "Latin"),
        ("Latvian", "lav"),
        ("Lithuanian", "lit"),
        ("Luxembourgish", "ltz"),
        ("Macedonian", "mkd"),
        ("Malayalam", "mal"),
        ("Malayalam script", "Malayalam"),
        ("Malay", "msa"),
        ("Maltese", "mlt"),
        ("Maori", "mri"),
        ("Marathi", "mar"),
        ("Mongolian", "mon"),
        ("Myanmar script", "Myanmar"),
        ("Nepali", "nep"),
        ("Norwegian", "nor"),
        ("Occitan (post 1500)", "oci"),
        ("Old Georgian", "kat_old"),
        ("Oriya (Odia) script", "Oriya"),
        ("Oriya", "ori"),
        ("Pashto", "pus"),
        ("Persian", "fas"),
        ("Polish", "pol"),
        ("Portuguese", "por"),
        ("Punjabi", "pan"),
        ("Quechua", "que"),
        ("Romanian", "ron"),
        ("Russian", "rus"),
        ("Sanskrit", "san"),
        ("script and orientation", "osd"),
        ("Serbian (Latin)", "srp_latn"),
        ("Serbian", "srp"),
        ("Sindhi", "snd"),
        ("Sinhala script", "Sinhala"),
        ("Sinhala", "sin"),
        ("Slovakian", "slk"),
        ("Slovenian", "slv"),
        ("Spanish, Castilian - Old", "spa_old"),
        ("Spanish", "spa"),
        ("Sundanese", "sun"),
        ("Swahili", "swa"),
        ("Swedish", "swe"),
        ("Syriac script", "Syriac"),
        ("Syriac", "syr"),
        ("Tajik", "tgk"),
        ("Tamil script", "Tamil"),
        ("Tamil", "tam"),
        ("Tatar", "tat"),
        ("Telugu script", "Telugu"),
        ("Telugu", "tel"),
        ("Thaana script", "Thaana"),
        ("Thai script", "Thai"),
        ("Thai", "tha"),
        ("Tibetan script", "Tibetan"),
        ("Tibetan Standard", "bod"),
        ("Tigrinya", "tir"),
        ("Tonga", "ton"),
        ("Turkish", "tur"),
        ("Ukrainian", "ukr"),
        ("Urdu", "urd"),
        ("Uyghur", "uig"),
        ("Uzbek (Cyrillic)", "uzb_cyrl"),
        ("Uzbek", "uzb"),
        ("Vietnamese script", "Vietnamese"),
        ("Vietnamese", "vie"),
        ("Welsh", "cym"),
        ("Yiddish", "yid"),
        ("Yoruba", "yor"),
    ].map( |(k, v)| (v, k)).iter().cloned().collect()
}

// TODO use the 'pathsearch' crate
fn executable_find<P>(exe_name: P) -> Option<PathBuf>
where P: AsRef<Path> {
    env::var_os("PATH").and_then(|paths| {
        env::split_paths(&paths).find_map(|dir| {
            let full_path = dir.join(&exe_name);
            if full_path.is_file() {
                Some(full_path)
            } else {
                None
            }
        })
    })
}

pub fn container_runtime_path() -> Option<PathBuf> {
    match consts::OS {
        "linux" => executable_find("podman"),
        _ => executable_find("docker")
    }
}

pub enum ContainerRt {
    DOCKER, PODMAN
}

pub fn container_runtime_tech() -> ContainerRt {
    match consts::OS {
        "linux" => ContainerRt::PODMAN,
        _ => ContainerRt::DOCKER
    }
}
