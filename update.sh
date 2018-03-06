#!/usr/bin/env bash

set -e

versions=(
    '5.5'
    '5.6'
    '5.7'
    '8.0'
    'mariadb'
)

cd "$(dirname "$(readlink -f "${BASH_SOURCE}")")"

generated_warning() {
	cat <<-EOH
		##
		## ВНИМАНИЕ! Этот файл создаётся сценарием "update.sh".
		## Не меняйте его вручную — он будет перезаписан.
		##

	EOH
}

for version in ${versions[*]}; do

    echo
    echo "MySQL: ${version}"

    baseDockerfile=Dockerfile.template
    targetDir="${version}"
    targetDockerfile="${version}/Dockerfile"

    echo "→ ${targetDockerfile}"

    { generated_warning; cat "$baseDockerfile"; } > "${targetDockerfile}"

    mysqlSoftware=mysql
    if [ "${version#mariadb}" != "$version" ]; then
        mysqlSoftware=mariadb
        version=latest
    fi

    sed -ri \
        -e 's!%%MYSQL_SOFTWARE%%!'"${mysqlSoftware}"'!' \
        -e 's!%%MYSQL_VERSION%%!'"${version}"'!' \
        "${targetDockerfile}"

    oldFiles=$(find "${targetDir}" -name 'docker-*')
    if [ ! -z "${oldFiles}" ]; then
        rm ${oldFiles}
    fi
    cp docker-* "${targetDir}/"

done
