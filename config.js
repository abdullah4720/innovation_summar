// ============================================================
// إعدادات الاتصال بـ Supabase — عدّل القيمتين التاليتين فقط
// تجدهما في: Supabase Dashboard > Project Settings > API
// ============================================================
const SUPABASE_URL = "https://rbdxcmpgcuursyhifjtt.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable__vCHW6cFK82CsuiUTfliHw_mSm0xqFm";

// كل صفحة (admin/checkin/facilitator) تحتفظ بجلسة دخول منفصلة عن غيرها
// حتى لو فُتحت بتبويبات مختلفة بنفس المتصفح — يمنع تصادم الجلسات بين الحسابات
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    storageKey: 'sb-auth-' + (location.pathname.split('/').pop() || 'index'),
  },
});

// أسماء المسارات وألوانها تُقرأ من قاعدة البيانات، لكن نبقي نسخة احتياطية هنا للطوارئ
const FALLBACK_TRACKS = [
  { code: "biz", name_ar: "ريادة الأعمال" },
  { code: "agents", name_ar: "وكلاء الذكاء الاصطناعي" },
  { code: "coding", name_ar: "البرمجة بالذكاء الاصطناعي" },
  { code: "elearn", name_ar: "التعلم الإلكتروني" },
  { code: "emerging", name_ar: "التقنيات الناشئة" },
  { code: "digital", name_ar: "التصنيع الرقمي والنمذجة" },
];
