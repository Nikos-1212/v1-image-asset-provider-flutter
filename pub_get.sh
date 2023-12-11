set -ex

(cd image_asset_provider; flutter pub get)
(cd test_app; flutter pub get)

(cd test_app; flutter precache --ios)
(cd test_app/ios;bundle install)
(cd test_app/ios;bundle exec pod update)