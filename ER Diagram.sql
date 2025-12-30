-- ============================================
-- الجداول الأساسية
-- ============================================

-- جدول المستخدمين الأساسي
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M', 'F')), -- M: ذكر, F: أنثى
    birth_date DATE,
    country_code CHAR(2),
    city VARCHAR(100),
    phone_number VARCHAR(20),
    profile_picture_url VARCHAR(255),
    cover_picture_url VARCHAR(255),
    marital_status VARCHAR(20), -- أعزب/أعزب لم يسبق الزواج/مطلق/أرمل
    children_count INTEGER DEFAULT 0,
    about_me TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    account_status VARCHAR(20) DEFAULT 'pending', -- pending, active, suspended, deleted
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول تفاصيل الهوية والتحقق
CREATE TABLE user_verification (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_type VARCHAR(20), -- passport, national_id, driver_license
    id_number VARCHAR(50),
    id_document_url VARCHAR(255),
    selfie_with_id_url VARCHAR(255),
    is_identity_verified BOOLEAN DEFAULT FALSE,
    verified_by_admin_id INTEGER,
    verification_date TIMESTAMP,
    notes TEXT
);

-- جدول الوصي (للمستخدمات الإناث)
CREATE TABLE female_guardians (
    id SERIAL PRIMARY KEY,
    female_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    guardian_name VARCHAR(100) NOT NULL,
    relationship VARCHAR(50), -- أب, أخ, عم, ولي شرعي
    guardian_phone VARCHAR(20),
    guardian_email VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    verification_code VARCHAR(10),
    verified_at TIMESTAMP
);

-- ============================================
-- الجداول الدينية والثقافية
-- ============================================

CREATE TABLE religious_info (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    faith_level VARCHAR(20), -- ملتزم جدا, ملتزم, متوسط, غير ملتزم
    prayer_status VARCHAR(20), -- دائم, غالبا, أحيانا, نادرا
    fasting_ramadan VARCHAR(20), -- دائم, غالبا, أحيانا, نادرا
    quran_knowledge VARCHAR(20), -- حافظ, يقرأ جيدا, يقرأ, مبتدئ
    hijab_status VARCHAR(20), -- محجبة دائما, محجبة غالبا, أحيانا, غير محجبة
    beard_status VARCHAR(20), -- ملتحي, غير ملتحي, أحيانا
    sect VARCHAR(50), -- سني, شيعي, اباضي (للمعلومات فقط)
    accepts_other_sects BOOLEAN DEFAULT TRUE
);

CREATE TABLE cultural_info (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    ethnicity VARCHAR(50),
    mother_tongue VARCHAR(50),
    languages_spoken TEXT[], -- Array of languages
    cultural_values TEXT, -- تقليدي, معتدل, عصري
    dietary_restrictions TEXT[] -- حلال فقط, نباتي, لا قيود
);

-- ============================================
-- التعليم والعمل
-- ============================================

CREATE TABLE education (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    degree VARCHAR(100),
    field_of_study VARCHAR(100),
    institution VARCHAR(150),
    graduation_year INTEGER,
    is_current BOOLEAN DEFAULT FALSE
);

CREATE TABLE employment (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    job_title VARCHAR(100),
    industry VARCHAR(100),
    company VARCHAR(150),
    employment_type VARCHAR(50), -- دائم, مؤقت, حر, عاطل
    annual_income_range VARCHAR(50),
    is_current BOOLEAN DEFAULT TRUE
);

-- ============================================
-- مواصفات الشريك المطلوب
-- ============================================

CREATE TABLE partner_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    min_age INTEGER,
    max_age INTEGER,
    preferred_gender CHAR(1) CHECK (preferred_gender IN ('M', 'F')),
    preferred_countries TEXT[], -- Array of country codes
    min_height_cm INTEGER,
    max_height_cm INTEGER,
    min_education_level VARCHAR(50),
    employment_preference VARCHAR(100),
    min_income_range VARCHAR(50),
    faith_level_preference VARCHAR(20),
    accepts_divorced BOOLEAN DEFAULT TRUE,
    accepts_widowed BOOLEAN DEFAULT TRUE,
    accepts_children BOOLEAN DEFAULT TRUE,
    max_children_count INTEGER,
    must_same_country BOOLEAN DEFAULT FALSE,
    must_same_ethnicity BOOLEAN DEFAULT FALSE
);

-- ============================================
-- نظام العضويات والدفع
-- ============================================

CREATE TABLE membership_plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    name_ar VARCHAR(50) NOT NULL,
    description TEXT,
    description_ar TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    features JSONB, -- Store features as JSON
    max_daily_messages INTEGER,
    can_initiate_chat BOOLEAN DEFAULT FALSE,
    can_see_who_viewed BOOLEAN DEFAULT FALSE,
    priority_in_search BOOLEAN DEFAULT FALSE,
    ai_matchmaking_access BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE user_memberships (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    plan_id INTEGER REFERENCES membership_plans(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'active', -- active, expired, cancelled
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- نظام التوافق والذكاء الاصطناعي
-- ============================================

CREATE TABLE compatibility_scores (
    id SERIAL PRIMARY KEY,
    user1_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    user2_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    overall_score DECIMAL(5,2), -- من 0 إلى 100
    religious_score DECIMAL(5,2),
    cultural_score DECIMAL(5,2),
    lifestyle_score DECIMAL(5,2),
    personality_score DECIMAL(5,2),
    last_calculated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user1_id, user2_id)
);

CREATE TABLE match_requests (
    id SERIAL PRIMARY KEY,
    sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    receiver_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, rejected, expired
    message TEXT,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '7 days')
);

-- ============================================
-- نظام المراسلة
-- ============================================

CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    user1_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    user2_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    last_message_id INTEGER, -- Reference to last message for quick access
    message_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(user1_id, user2_id)
);

CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    receiver_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    message_type VARCHAR(20) DEFAULT 'text', -- text, image, voice_note
    content TEXT,
    media_url VARCHAR(255),
    is_read BOOLEAN DEFAULT FALSE,
    is_delivered BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

CREATE TABLE daily_message_counts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    date DATE DEFAULT CURRENT_DATE,
    message_count INTEGER DEFAULT 0,
    UNIQUE(user_id, date)
);

-- ============================================
-- الإبلاغ والمراقبة
-- ============================================

CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    reporter_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    reported_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    report_type VARCHAR(50), -- inappropriate_behavior, fake_profile, harassment
    description TEXT,
    evidence_urls TEXT[], -- Array of URLs
    status VARCHAR(20) DEFAULT 'pending', -- pending, reviewed, resolved
    reviewed_by_admin_id INTEGER,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE blocked_users (
    id SERIAL PRIMARY KEY,
    blocker_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    blocked_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    reason VARCHAR(255),
    blocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(blocker_id, blocked_id)
);

-- ============================================
-- الفهارس المهمة للأداء
-- ============================================

CREATE INDEX idx_users_gender_age ON users(gender, birth_date);
CREATE INDEX idx_users_location ON users(country_code, city);
CREATE INDEX idx_users_verification ON users(is_verified, account_status);
CREATE INDEX idx_match_requests_status ON match_requests(status, sent_at);
CREATE INDEX idx_messages_conversation ON messages(conversation_id, sent_at);
CREATE INDEX idx_compatibility_scores ON compatibility_scores(user1_id, overall_score DESC);
CREATE INDEX idx_daily_messages ON daily_message_counts(user_id, date);

-- ============================================
-- إجراءات محفوظة (Stored Procedures)
-- ============================================

-- إجراء لحساب التوافق التلقائي
CREATE OR REPLACE FUNCTION calculate_compatibility(
    p_user1_id INTEGER,
    p_user2_id INTEGER
) RETURNS DECIMAL LANGUAGE plpgsql AS $$
DECLARE
    v_score DECIMAL;
BEGIN
    -- حساب النقاط بناءً على معايير متعددة
    -- (تفاصيل الخوارزمية تحتاج إلى تطوير)
    v_score := 85.5; -- قيمة افتراضية
    
    RETURN v_score;
END;
$$;