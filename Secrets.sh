# إعدادات البيئة التي تحتاج إلى إضافتها في GitHub Secrets:

# 1. المتغيرات البيئية العامة
DB_USER=admin
DB_PASSWORD=strong_password_here
DB_NAME=matrimony
JWT_SECRET=very_strong_jwt_secret_here
REDIS_PASSWORD=redis_password_here

# 2. إعدادات Staging
STAGING_HOST=staging.matrimony.com
STAGING_USER=deploy
STAGING_SSH_KEY=-----BEGIN RSA PRIVATE KEY-----

# 3. إعدادات Production
PRODUCTION_HOST=matrimony.com
PRODUCTION_USER=deploy
PRODUCTION_SSH_KEY=-----BEGIN RSA PRIVATE KEY-----