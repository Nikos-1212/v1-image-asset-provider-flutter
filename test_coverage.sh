set -e

function generateCoverage {
  echo "Generating test coverage for MediaManager"
  (cd image_asset_provider; flutter test --coverage)
  (cd image_asset_provider/coverage; sed -i '' "s|SF:lib/|SF:image_asset_provider/lib/|g" lcov.info)

  echo "Combining all coverage into file://$(pwd)/all_coverage/combined-coverage.info"
  lcov --add-tracefile image_asset_provider/coverage/lcov.info --base-directory image_asset_provider/lib --no-external -d image_asset_provider \
       --output-file all_coverage/combined-coverage.info
  echo "Generating html file test coverage for MediaManager"
  genhtml all_coverage/combined-coverage.info --output-directory all_coverage/html --show-details
  echo "Open this file file://$(pwd)/all_coverage/html/index.html"
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v lcov >/dev/null 2>&1; then
    generateCoverage
  else
    echo "lcov is not installed in mac"
    echo "Install lcov using this command 'brew install lcov'"
  fi
elif [[ "$OSTYPE" == "msys" ]]; then
  if where lcov >/dev/null 2>&1; then
    generateCoverage
  else
    echo "lcov is not installed in windows"
    echo "Please refer to the following link for more information: https://github.com/linux-test-project/lcov."
  fi
else
  echo "Unknown operating system"
fi