# SOZO English App - 開発用Makefile
.PHONY: help dev-build dev-deploy dev-deploy-all clean deps

help: ## ヘルプを表示
	@echo "SOZO English App - 開発コマンド"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

deps: ## 依存関係を取得
	flutter pub get

clean: ## プロジェクトをクリーンアップ
	flutter clean
	flutter pub get

dev-build: ## 開発用APKをビルド
	flutter build apk --release
	@echo "✅ APKビルド完了: build/app/outputs/flutter-apk/app-release.apk"

dev-deploy: ## Android版をFirebase App Distributionに配布
	@./scripts/deploy_dev.sh

dev-deploy-all: ## iOS + Android をFirebase App Distributionに配布
	@./scripts/deploy_both.sh

test: ## テストを実行
	flutter test

format: ## コードをフォーマット
	dart format lib test

lint: ## コード解析を実行
	flutter analyze

# デフォルトコマンド
.DEFAULT_GOAL := help 