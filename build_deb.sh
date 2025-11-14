#!/bin/bash
set -e

test -z ${DEBFULLNAME} && { echo "DEBFULLNAME must be set"; exit 1; }
test -z ${DEBEMAIL} && { echo "DEBEMAIL must be set"; exit 1; }

BUILD_DIR=$(mktemp -d)
trap 'rm -rf "${BUILD_DIR}"' EXIT

PKGNAME="us-de-layout"

TAG=$(git describe --tags --match 'v*' --abbrev=0 2>/dev/null || echo "v0.0")
UPSTREAM_VER=${TAG#v}
DISTANCE=$(git rev-list --count "${TAG}..HEAD")
DEBIAN_REV=$((DISTANCE + 1))
VERSION="${UPSTREAM_VER}-${DEBIAN_REV}"

git archive \
	--format=tar.gz \
	--prefix="${PKGNAME}-${VERSION}/" \
	-o "${BUILD_DIR}/${PKGNAME}_${UPSTREAM_VER}.orig.tar.gz" \
	HEAD


tar -xzf "${BUILD_DIR}/${PKGNAME}_${UPSTREAM_VER}.orig.tar.gz" -C "$BUILD_DIR"

pushd "${BUILD_DIR}/${PKGNAME}-${VERSION}"
	dch -v "${VERSION}" "Auto-build from tag ${TAG} + ${DISTANCE} commits" --force-distribution --distribution unstable
	debuild -us -uc
popd

cp ${BUILD_DIR}/*.deb ./
