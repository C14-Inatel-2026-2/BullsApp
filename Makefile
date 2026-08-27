.PHONY: run clean build-apk build-web get test format

run:
	flutter run

clean:
	flutter clean

build-apk:
	flutter build apk --release

build-web:
	flutter build web --release

get:
	flutter pub get

test:
	flutter test

format:
	dart format lib/
