#!/bin/bash
set -ex

BUILD_DIR=$(mktemp -d)
trap 'rm -rf "${BUILD_DIR}"' EXIT

PKGNAME="us-de-layout"

TAG=$(git describe --tags --match 'v*' --abbrev=0 2>/dev/null || echo "v0.0")
RPMFULLNAME=$(git log -n 1 --pretty=format:%an)
RPMEMAIL=$(git log -n 1 --pretty=format:%ae)

UPSTREAM_VER=${TAG#v}
DISTANCE=$(git rev-list --count "${TAG}..HEAD")
RPM_REV=$((DISTANCE + 1))

mkdir -p ${BUILD_DIR}/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

sed "/^%changelog/a\\
* $(date +'%a %b %d %Y') ${RPMFULLNAME} <${RPMEMAIL}> - ${UPSTREAM_VER}-${RPM_REV}\\
- Auto-build from tag ${TAG} + ${DISTANCE} commits\\
" rpm/rpm.spec > ${BUILD_DIR}/rpmbuild/SPECS/rpm.spec

git archive \
	--format=tar.gz \
	--prefix="${PKGNAME}-${UPSTREAM_VER}/" \
	-o "${BUILD_DIR}/rpmbuild/SOURCES/${PKGNAME}-${UPSTREAM_VER}.tar.gz" \
	HEAD

rpmbuild \
	--define "_topdir ${BUILD_DIR}/rpmbuild" \
	--define "version ${UPSTREAM_VER}" \
	--define "release ${RPM_REV}" \
	-v -ba ${BUILD_DIR}/rpmbuild/SPECS/rpm.spec

cp ${BUILD_DIR}/rpmbuild/RPMS/noarch/*.rpm ./
