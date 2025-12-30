#!/bin/bash
# scripts/deploy.sh

set -e

ENV=${1:-production}
COMPOSE_FILE="docker-compose.prod.yml"

echo "🚀 بدء النشر على بيئة $ENV..."

# سحب أحدث الصور
echo "⬇️  سحب أحدث الصور من الـ Registry..."
docker-compose -f $COMPOSE_FILE pull

# تشغيل التحديثات
echo "🔄 تحديث الحاويات..."
docker-compose -f $COMPOSE_FILE up -d --remove-orphans

# تنظيف الصور القديمة
echo "🧹 تنظيف الصور غير المستخدمة..."
docker image prune -f

# تسجيل النشر
echo "📝 تسجيل عملية النشر..."
echo "$(date): Deployed to $ENV environment" >> deploy.log

echo "✅ تم النشر بنجاح على بيئة $ENV!"