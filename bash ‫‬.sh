#!/bin/bash
# scripts/setup-dev.sh

set -e

echo "🚀 بدء إعداد بيئة التطوير..."

# التحقق من وجود Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker غير مثبت. الرجاء تثبيت Docker أولاً."
    exit 1
fi

# التحقق من وجود Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose غير مثبت. الرجاء تثبيته أولاً."
    exit 1
fi

# نسخ ملف البيئة
if [ ! -f .env ]; then
    echo "📄 نسخ ملف .env.example إلى .env"
    cp .env.example .env
    echo "✅ تم إنشاء ملف .env. الرجاء تعديل المتغيرات البيئية."
fi

# بناء الصور
echo "🏗️  بناء صور Docker..."
docker-compose -f docker-compose.dev.yml build

# بدء الخدمات
echo "🚀 تشغيل الحاويات..."
docker-compose -f docker-compose.dev.yml up -d

echo "⏳ الانتظار حتى تكون الخدمات جاهزة..."
sleep 10

# التحقق من حالة الخدمات
echo "🔍 التحقق من حالة الخدمات:"
docker-compose -f docker-compose.dev.yml ps

echo ""
echo "✅ تم إعداد البيئة بنجاح!"
echo ""
echo "📊 الروابط المتاحة:"
echo "   Frontend:    http://localhost:3001"
echo "   Backend:     http://localhost:3000"
echo "   pgAdmin:     http://localhost:5050"
echo "   Redis Commander: http://localhost:8081"
echo ""
echo "🔧 الأوامر المتاحة:"
echo "   تشغيل:  docker-compose -f docker-compose.dev.yml up -d"
echo "   إيقاف:  docker-compose -f docker-compose.dev.yml down"
echo "   سجلات:  docker-compose -f docker-compose.dev.yml logs -f"