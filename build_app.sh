set -ex

./pub_get.sh

./build_runner.sh

./analyze.sh

./test_coverage.sh

(cd test_app;flutter build apk)
(cd test_app;flutter build ios --simulator)