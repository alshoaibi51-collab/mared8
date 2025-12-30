.PHONY: help dev build test lint deploy clean

help:
	@echo "🚀 Islamic Matrimony Platform - أوامر التشغيل"
	@echo ""
	@echo "التطوير:"
	@echo "  make dev          - تشغيل بيئة التطوير"
	@echo "  make build        - بناء التطبيق"
	@echo "  make test         - تشغيل الاختبارات"
	@echo "  make lint         - فحص الكود"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-dev   - تشغيل Docker للتطوير"
	@echo "  make docker-prod  - تشغيل Docker للإنتاج"
	@echo "  make docker-stop  - إيقاف Docker"
	@echo ""
	@echo "النشر:"
	@echo "  make deploy-dev   - النشر على Staging"
	@echo "  make deploy-prod  - النشر على Production"
	@echo ""
	@echo "الصيانة:"
	@echo "  make clean        - تنظيف التبعيات"
	@echo "  make logs         - عرض السجلات"

dev:
	@npm run dev

build:
	@npm run build

test:
	@npm test

lint:
	@npm run lint

docker-dev:
	@npm run docker:dev

docker-prod:
	@npm run docker:prod

docker-stop:
	@npm run docker:stop

deploy-dev:
	@./scripts/deploy.sh staging

deploy-prod:
	@./scripts/deploy.sh production

clean:
	@rm -rf node_modules client/node_modules server/node_modules
	@docker system prune -f

logs:
	@docker-compose -f docker-compose.dev.yml logs -f