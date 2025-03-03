# no shebang line here


# Check if variable is set in Bash. see: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
# Variables from CI context
if [[ -z ${CI_COMMIT_REF_NAME+x} ]]; then CI_COMMIT_REF_NAME=""; fi
if [[ -z ${CI_PROJECT_PATH+x} ]]; then CI_PROJECT_PATH=""; fi
if [[ -z ${CI_PROJECT_URL+x} ]]; then CI_PROJECT_URL=""; fi
if [[ -z ${CI_REF_NAME+x} ]]; then CI_REF_NAME=""; fi
if [[ -z ${APPVEYOR_PULL_REQUEST_HEAD_REPO_NAME+x} ]]; then APPVEYOR_PULL_REQUEST_HEAD_REPO_NAME=""; fi
if [[ -z ${APPVEYOR_REPO_BRANCH+x} ]]; then APPVEYOR_REPO_BRANCH=""; fi
if [[ -z ${APPVEYOR_REPO_NAME+x} ]]; then APPVEYOR_REPO_NAME=""; fi
if [[ -z ${APPVEYOR_REPO_TAG+x} ]]; then APPVEYOR_REPO_TAG=""; fi
if [[ -z ${APPVEYOR_REPO_TAG_NAME+x} ]]; then APPVEYOR_REPO_TAG_NAME=""; fi
if [[ -z ${TRAVIS_BRANCH+x} ]]; then TRAVIS_BRANCH=""; fi
if [[ -z ${TRAVIS_EVENT_TYPE+x} ]]; then TRAVIS_EVENT_TYPE=""; fi
if [[ -z ${TRAVIS_REPO_SLUG+x} ]]; then TRAVIS_REPO_SLUG=""; fi
if [[ -z ${TRAVIS_PULL_REQUEST+x} ]]; then TRAVIS_PULL_REQUEST=""; fi


# Script variables
if [[ -z ${GRADLE_CMD+x} ]]; then
    GRADLE_CMD="gradle"
    if [[ -f gradlew ]]; then GRADLE_CMD="./gradlew"; fi
fi
if [[ -z ${JAVA_HOME+x} ]]; then JAVA_HOME=""; fi
if [[ -z ${MAVEN_OPTS+x} ]]; then MAVEN_OPTS=""; fi
if [[ -z ${MVN_CMD+x} ]]; then
    MVN_CMD="mvn"
    if [[ -f mvnw ]]; then MVN_CMD="./mvnw"; fi
fi
if [[ -z ${ZSH_VERSION+x} ]]; then ZSH_VERSION=""; fi


if [[ -z ${CI_OPT_INFRASTRUCTURE+x} ]]; then CI_OPT_INFRASTRUCTURE=""; fi
if [[ -z ${CI_OPT_GIT_PREFIX+x} ]]; then CI_OPT_GIT_PREFIX=""; fi
if [[ -z ${CI_OPT_OSSRH_GIT_PREFIX+x} ]]; then CI_OPT_OSSRH_GIT_PREFIX=""; fi
if [[ -z ${CI_OPT_PRIVATE_GIT_PREFIX+x} ]]; then CI_OPT_PRIVATE_GIT_PREFIX=""; fi


# auto detect infrastructure using for this build.
# example of gitlab-ci's CI_PROJECT_URL: "https://example.com/gitlab-org/gitlab-ce"
# returns: ossrh, private or customized infrastructure name
function ci_opt_infrastructure() {
    if [[ -n "${CI_OPT_INFRASTRUCTURE}" ]]; then
        echo ${CI_OPT_INFRASTRUCTURE}
    elif [[ -n "${TRAVIS_REPO_SLUG}" ]]; then
        echo "ossrh"
        # TODO APPVEYOR_REPO_NAME
    elif [[ -n "${CI_PROJECT_URL}" ]] && [[ "${CI_PROJECT_URL}" == ${CI_OPT_PRIVATE_GIT_PREFIX}* ]]; then
        echo "private"
    else
        echo "private"
    fi
}

# arguments: default_value
function find_git_prefix_from_ci_script() {
    (>&2 echo "find CI_OPT_GIT_PREFIX from CI_OPT_CI_SCRIPT: ${CI_OPT_CI_SCRIPT}, default_value: $1")
    if [[ "${CI_OPT_CI_SCRIPT}" == http* ]]; then
        echo $(echo ${CI_OPT_CI_SCRIPT} | sed -E 's#/[^/]+/[^/]+/raw/[^/]+/.+##')
    else
        echo "$1"
    fi
}

# auto determine CI_OPT_GIT_PREFIX by infrastructure for further download.
# returns: prefix of git service url (infrastructure specific), i.e. https://github.com
function ci_infra_opt_git_prefix() {
    (>&2 echo "ci_infra_opt_git_prefix infrastructure: $(ci_opt_infrastructure), CI_OPT_CI_SCRIPT: ${CI_OPT_CI_SCRIPT}")
    if [[ -n "${CI_OPT_GIT_PREFIX}" ]]; then
        echo "${CI_OPT_GIT_PREFIX}"
    else
        local infrastructure="$(ci_opt_infrastructure)"
        local default_value=""
        if [[ "ossrh" == "${infrastructure}" ]]; then
            default_value="https://github.com"
            CI_OPT_GIT_PREFIX="${CI_OPT_OSSRH_GIT_PREFIX}"
        elif [[ "private" == "${infrastructure}" ]] || [[ -z "${infrastructure}" ]]; then
            default_value="http://gitlab"
            CI_OPT_GIT_PREFIX="${CI_OPT_PRIVATE_GIT_PREFIX}"
        fi

        if [[ -z "${CI_OPT_GIT_PREFIX}" ]]; then
            CI_OPT_GIT_PREFIX=$(find_git_prefix_from_ci_script "${default_value}")
        elif [[ -n "${CI_PROJECT_URL}" ]]; then
            CI_OPT_GIT_PREFIX=$(echo "${CI_PROJECT_URL}" | sed 's,/*[^/]\+/*$,,' | sed 's,/*[^/]\+/*$,,')
        fi
        echo ${CI_OPT_GIT_PREFIX}
    fi
}


if [[ -z ${CI_OPT_MAVEN_BUILD_OPTS_REPO+x} ]]; then CI_OPT_MAVEN_BUILD_OPTS_REPO="$(ci_infra_opt_git_prefix)/ci-and-cd/maven-build-opts-$(ci_opt_infrastructure)"; fi
# For gitlab >= 11.5 CI_OPT_MAVEN_BUILD_OPTS_REPO should be $(ci_infra_opt_git_prefix)/api/v4/projects/<projectId>/repository/files

if [[ -z ${CI_OPT_ORIGIN_REPO_SLUG+x} ]]; then CI_OPT_ORIGIN_REPO_SLUG=""; fi
if [[ -z ${CI_OPT_DOCKER_REGISTRY+x} ]]; then CI_OPT_DOCKER_REGISTRY=""; fi
if [[ -z ${CI_OPT_DOCKER_REGISTRY_URL+x} ]]; then CI_OPT_DOCKER_REGISTRY_URL=""; fi
if [[ -z ${CI_OPT_GIT_AUTH_TOKEN+x} ]]; then CI_OPT_GIT_AUTH_TOKEN=""; fi
if [[ -z ${CI_OPT_NEXUS3+x} ]]; then CI_OPT_NEXUS3=""; fi
if [[ -z ${CI_OPT_SONAR_HOST_URL+x} ]]; then CI_OPT_SONAR_HOST_URL=""; fi
if [[ -z ${CI_OPT_MAVEN_EFFECTIVE_POM+x} ]]; then CI_OPT_MAVEN_EFFECTIVE_POM=""; fi
if [[ -z ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE+x} ]]; then CI_OPT_MAVEN_EFFECTIVE_POM_FILE=""; fi
# Mandatory: false; Default: blank; Value: -s /path/to/settings.xml
if [[ -z ${CI_OPT_MAVEN_SETTINGS+x} ]]; then CI_OPT_MAVEN_SETTINGS=""; fi
# Mandatory: false; Default: an auto generated /cache/directory/settings.xml if src/main/maven/settings.xml absent;
if [[ -z ${CI_OPT_MAVEN_SETTINGS_FILE+x} ]]; then CI_OPT_MAVEN_SETTINGS_FILE=""; fi

if [[ -z ${CI_OPT_MAVEN_SETTINGS_SECURITY_FILE+x} ]]; then CI_OPT_MAVEN_SETTINGS_SECURITY_FILE=""; fi

if [[ -z ${CI_OPT_CI_SCRIPT+x} ]]; then CI_OPT_CI_SCRIPT=""; fi
if [[ -z ${CI_OPT_MAVEN_BUILD_REPO+x} ]]; then CI_OPT_MAVEN_BUILD_REPO=""; fi
if [[ -z ${CI_OPT_CI_OPTS_FILE+x} ]]; then CI_OPT_CI_OPTS_FILE="src/main/ci-script/ci_opts.sh"; fi
# For gitlab >= 11.5 CI_OPT_CI_OPTS_FILE should be src%2Fmain%2Fci-script%2Fci_opts.sh?ref=master

if [[ -z ${CI_OPT_DRYRUN+x} ]]; then CI_OPT_DRYRUN=""; fi
if [[ -z ${CI_OPT_OUTPUT_MAVEN_EFFECTIVE_POM_TO_CONSOLE+x} ]]; then CI_OPT_OUTPUT_MAVEN_EFFECTIVE_POM_TO_CONSOLE="false"; fi
if [[ -z ${CI_OPT_SHELL_EXIT_ON_ERROR+x} ]]; then CI_OPT_SHELL_EXIT_ON_ERROR="true"; fi
if [[ -z ${CI_OPT_SHELL_PRINT_EXECUTED_COMMANDS+x} ]]; then CI_OPT_SHELL_PRINT_EXECUTED_COMMANDS="false"; fi

if [[ -z ${CI_OPT_DOCKER_REGISTRY_PASS+x} ]]; then CI_OPT_DOCKER_REGISTRY_PASS=""; fi
if [[ -z ${CI_OPT_DOCKER_REGISTRY_USER+x} ]]; then CI_OPT_DOCKER_REGISTRY_USER=""; fi


# Maven options used in maven-build/pom.xml or build-docker/pom.xml
if [[ -z ${CI_OPT_CHECKSTYLE_CONFIG_LOCATION+x} ]]; then CI_OPT_CHECKSTYLE_CONFIG_LOCATION=""; fi
if [[ -z ${CI_OPT_MAVEN_CLEAN_SKIP+x} ]]; then CI_OPT_MAVEN_CLEAN_SKIP="false"; fi
if [[ -z ${CI_OPT_DEPENDENCY_CHECK+x} ]]; then CI_OPT_DEPENDENCY_CHECK="true"; fi
if [[ -z ${CI_OPT_DOCKER_IMAGE_PREFIX+x} ]]; then CI_OPT_DOCKER_IMAGE_PREFIX=""; fi
if [[ -z ${CI_OPT_DOCKERFILE_USEMAVENSETTINGSFORAUTH+x} ]]; then CI_OPT_DOCKERFILE_USEMAVENSETTINGSFORAUTH="false"; fi
if [[ -z ${CI_OPT_FRONTEND_NODEDOWNLOADROOT+x} ]]; then CI_OPT_FRONTEND_NODEDOWNLOADROOT=""; fi
if [[ -z ${CI_OPT_FRONTEND_NPMDOWNLOADROOT+x} ]]; then CI_OPT_FRONTEND_NPMDOWNLOADROOT=""; fi
if [[ -z ${CI_OPT_GITHUB_SITE_PUBLISH+x} ]]; then CI_OPT_GITHUB_SITE_PUBLISH=""; fi
if [[ -z ${CI_OPT_GITHUB_GLOBAL_REPOSITORYNAME+x} ]]; then CI_OPT_GITHUB_GLOBAL_REPOSITORYNAME=""; fi
if [[ -z ${CI_OPT_GITHUB_GLOBAL_REPOSITORYOWNER+x} ]]; then CI_OPT_GITHUB_GLOBAL_REPOSITORYOWNER=""; fi
if [[ -z ${CI_OPT_SKIPITS+x} ]]; then CI_OPT_SKIPITS=""; fi
if [[ -z ${CI_OPT_JACOCO+x} ]]; then CI_OPT_JACOCO="true"; fi
if [[ -z ${CI_OPT_JIRA_PASSWORD+x} ]]; then CI_OPT_JIRA_PASSWORD=""; fi
if [[ -z ${CI_OPT_JIRA_PROJECTKEY+x} ]]; then CI_OPT_JIRA_PROJECTKEY=""; fi
if [[ -z ${CI_OPT_JIRA_USER+x} ]]; then CI_OPT_JIRA_USER=""; fi
if [[ -z ${CI_OPT_MAVEN_OPTS+x} ]]; then CI_OPT_MAVEN_OPTS=""; fi
if [[ -z ${CI_OPT_MVN_MULTI_STAGE_BUILD+x} ]]; then CI_OPT_MVN_MULTI_STAGE_BUILD=""; fi
if [[ -z ${CI_OPT_PMD_RULESET_LOCATION+x} ]]; then CI_OPT_PMD_RULESET_LOCATION=""; fi
if [[ -z ${CI_OPT_SITE+x} ]]; then CI_OPT_SITE="true"; fi
if [[ -z ${CI_OPT_SITE_PATH_PREFIX+x} ]]; then CI_OPT_SITE_PATH_PREFIX=""; fi
if [[ -z ${CI_OPT_SONAR+x} ]]; then CI_OPT_SONAR=""; fi
if [[ -z ${CI_OPT_SONAR_LOGIN+x} ]]; then CI_OPT_SONAR_LOGIN=""; fi
if [[ -z ${CI_OPT_SONAR_ORGANIZATION+x} ]]; then CI_OPT_SONAR_ORGANIZATION=""; fi
if [[ -z ${CI_OPT_SONAR_PASSWORD+x} ]]; then CI_OPT_SONAR_PASSWORD=""; fi
if [[ -z ${CI_OPT_MAVEN_TEST_FAILURE_IGNORE+x} ]]; then CI_OPT_MAVEN_TEST_FAILURE_IGNORE=""; fi
if [[ -z ${CI_OPT_MAVEN_TEST_SKIP+x} ]]; then CI_OPT_MAVEN_TEST_SKIP=""; fi

# Variables that usually do not need to be set
if [[ -z ${CI_OPT_CACHE_DIRECTORY+x} ]]; then CI_OPT_CACHE_DIRECTORY=""; fi
if [[ -z ${CI_OPT_GIT_COMMIT_ID+x} ]]; then CI_OPT_GIT_COMMIT_ID=""; fi
if [[ -z ${CI_OPT_ORIGIN_REPO+x} ]]; then CI_OPT_ORIGIN_REPO=""; fi
if [[ -z ${CI_OPT_PUBLISH_CHANNEL+x} ]]; then CI_OPT_PUBLISH_CHANNEL=""; fi
if [[ -z ${CI_OPT_PUBLISH_TO_REPO+x} ]]; then CI_OPT_PUBLISH_TO_REPO=""; fi
if [[ -z ${CI_OPT_GIT_REF_NAME+x} ]]; then CI_OPT_GIT_REF_NAME=""; fi
if [[ -z ${CI_OPT_DOCKER+x} ]]; then CI_OPT_DOCKER=""; fi
if [[ -z ${CI_OPT_WAGON_MERGEMAVENREPOS_SOURCE+x} ]]; then CI_OPT_WAGON_MERGEMAVENREPOS_SOURCE=""; fi

if [[ -z ${CI_OPT_GRADLE_INIT_SCRIPT+x} ]]; then CI_OPT_GRADLE_INIT_SCRIPT=""; fi
if [[ -z ${CI_OPT_GRADLE_PROPERTIES+x} ]]; then CI_OPT_GRADLE_PROPERTIES=""; fi

# build a filter_script file
# filter_script filters maven or gradle's verbose output
# arguments: target_file
# returns: path of the filter_script
function filter_script() {
    local target_file="$1"

cat >${target_file} <<EOL
# filter log output
# reduce log avoid travis 4MB limit
while IFS='' read -r LINE
do
    echo "\${LINE}" \
        | { grep -v 'Downloading:' || true; } \
        | { grep -Ev '^Progress ' || true; } \
        | { grep -Ev '^Generating .+\.html\.\.\.' || true; }
done
EOL

    chmod 755 ${target_file}
    echo "${target_file}"
}

# see: http://stackoverflow.com/questions/16989598/bash-comparing-version-numbers
# arguments: first_version, second_version
# return: if first_version is greater than second_version
function version_gt() {
    if [[ ! -z "$(sort --help | { grep GNU || true; })" ]]; then
        test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
    else
        test "$(printf '%s\n' "$@" | sort | head -n 1)" != "$1";
    fi
}

function os_name() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo "unix"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "msys" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "win"* ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        echo "unix"
    else
        echo "generic"
    fi
}

# GPG options
if which gpg2 > /dev/null; then CI_OPT_GPG_EXECUTABLE="gpg2"; elif which gpg > /dev/null; then CI_OPT_GPG_EXECUTABLE="gpg"; else CI_OPT_GPG_EXECUTABLE=""; fi
if [[ -z ${CI_OPT_GPG_KEYID+x} ]]; then CI_OPT_GPG_KEYID=""; fi
if [[ -z ${CI_OPT_GPG_KEYNAME+x} ]]; then CI_OPT_GPG_KEYNAME=""; fi
if [[ -z ${CI_OPT_GPG_PASSPHRASE+x} ]]; then CI_OPT_GPG_PASSPHRASE=""; fi


function filter_secret_variables() {
    while read line; do
      printf "%s\n" "$line" \
        | sed -E 's#KEYNAME=.+#KEYNAME=<secret>#g' \
        | sed -E 's#ORGANIZATION=.+#ORGANIZATION=<secret>#g'\
        | sed -E 's#PASS=.+#PASS=<secret>#g' \
        | sed -E 's#PASSWORD=.+#PASSWORD=<secret>#g' \
        | sed -E 's#PASSPHRASE=.+#PASSPHRASE=<secret>#g' \
        | sed -E 's#TOKEN=.+#TOKEN=<secret>#g' \
        | sed -E 's#USER=.+#USER=<secret>#g' \
        | sed -E 's#USERNAME=.+#USERNAME=<secret>#g'
    done
}

function decrypt_files() {
    echo -e "\n    >>>>>>>>>> ---------- decrypt files and handle keys ---------- >>>>>>>>>>"
    local gpg_cmd=""
    echo determine gpg or gpg2 to use
    # invalid option --pinentry-mode loopback
    if which gpg2 > /dev/null; then
        gpg_cmd="gpg2 --use-agent"
    elif which gpg > /dev/null; then
        gpg_cmd="gpg"
    fi
    if [[ -n "${CI_OPT_GPG_EXECUTABLE}" ]]; then
        echo "using ${CI_OPT_GPG_EXECUTABLE}"
        GPG_TTY=$(tty || echo "")
        if [[ -z "${GPG_TTY}" ]]; then unset GPG_TTY; fi
        echo "gpg tty '${GPG_TTY}'"

        # use --batch=true to avoid 'gpg tty not a tty' error
        ${gpg_cmd} --batch=true --version

        # config gpg (version > 2.1)
        if version_gt $(${CI_OPT_GPG_EXECUTABLE} --batch=true --version | { grep -E '[0-9]+\.[0-9]+\.[0-9]+' || true; } | head -n1 | awk '{print $NF}') "2.1"; then
            echo "gpg version greater than 2.1"
            mkdir -p ~/.gnupg && chmod 700 ~/.gnupg
            touch ~/.gnupg/gpg.conf
            echo "add 'use-agent' to '~/.gnupg/gpg.conf'"
            echo 'use-agent' > ~/.gnupg/gpg.conf
            if version_gt $(${CI_OPT_GPG_EXECUTABLE} --batch=true --version | { grep -E '[0-9]+\.[0-9]+\.[0-9]+' || true; } | head -n1 | awk '{print $NF}') "2.2"; then
                # on gpg-2.1.11 'pinentry-mode loopback' is invalid option
                echo "add 'pinentry-mode loopback' to '~/.gnupg/gpg.conf'"
                echo 'pinentry-mode loopback' >> ~/.gnupg/gpg.conf
            fi
            cat ~/.gnupg/gpg.conf
            #gpg_cmd="${gpg_cmd} --pinentry-mode loopback"
            #export GPG_OPTS='--pinentry-mode loopback'
            #echo GPG_OPTS: ${GPG_OPTS}
            echo "add 'allow-loopback-pinentry' to '~/.gnupg/gpg-agent.conf'"
            touch ~/.gnupg/gpg-agent.conf
            echo 'allow-loopback-pinentry' > ~/.gnupg/gpg-agent.conf
            cat ~/.gnupg/gpg-agent.conf
            echo restart the agent
            echo RELOADAGENT | gpg-connect-agent
        fi

        # decrypt gpg key
        openssl version -a
        if [[ -f codesigning.asc.enc ]] && [[ -n "${CI_OPT_GPG_PASSPHRASE}" ]]; then
            echo decrypt private key
            # bad decrypt
            # 140611360391616:error:06065064:digital envelope routines:EVP_DecryptFinal_ex:bad decrypt:../crypto/evp/evp_enc.c:536:
            # see: https://stackoverflow.com/questions/34304570/how-to-resolve-the-evp-decryptfinal-ex-bad-decrypt-during-file-decryption
            openssl aes-256-cbc -k ${CI_OPT_GPG_PASSPHRASE} -in codesigning.asc.enc -out codesigning.asc -d -md md5
        fi
        if [[ -f codesigning.asc.gpg ]] && [[ -n "${CI_OPT_GPG_PASSPHRASE}" ]]; then
            echo decrypt private key
            LC_CTYPE="UTF-8" echo ${CI_OPT_GPG_PASSPHRASE} | ${gpg_cmd} --passphrase-fd 0 --yes --batch=true --cipher-algo AES256 -o codesigning.asc codesigning.asc.gpg
        fi

        if [[ -f codesigning.pub ]]; then
            echo import public keys
            ${gpg_cmd} --yes --batch --import codesigning.pub

            echo list public keys
            ${gpg_cmd} --batch=true --list-keys
        fi
        if [[ -f codesigning.asc ]]; then
            echo import private keys
            # some versions only can import public key from a keypair file, some can import key pair
            if [[ -f codesigning.pub ]]; then
                ${gpg_cmd} --yes --batch --import codesigning.asc
            else
                if [[ -z "$(${gpg_cmd} --list-secret-keys | { grep ${CI_OPT_GPG_KEYNAME} || true; })" ]]; then ${gpg_cmd} --yes --batch=true --fast-import codesigning.asc; fi
            fi
            echo list private keys
            ${gpg_cmd} --batch=true --list-secret-keys

            # issue: You need a passphrase to unlock the secret key
            # no-tty causes "gpg: Sorry, no terminal at all requested - can't get input"
            #echo 'no-tty' >> ~/.gnupg/gpg.conf
            #echo 'default-cache-ttl 600' > ~/.gnupg/gpg-agent.conf

            # test key
            # this test not working on appveyor
            # gpg: skipped "KEYID": secret key not available
            # gpg: signing failed: secret key not available
            #if [[ -f LICENSE ]]; then
            #    echo test private key imported
            #    echo ${CI_OPT_GPG_PASSPHRASE} | gpg --passphrase-fd 0 --yes --batch=true -u ${CI_OPT_GPG_KEYNAME} --armor --detach-sig LICENSE
            #fi
            echo set default key
            echo -e "trust\n5\ny\n" | gpg --command-fd 0 --batch=true --edit-key ${CI_OPT_GPG_KEYNAME}

            # for gradle build
            if [[ -n "${CI_OPT_GPG_KEYID}" ]]; then ${gpg_cmd} --batch=true --keyring secring.gpg --export-secret-key ${CI_OPT_GPG_KEYID} > secring.gpg; fi
        fi
    else
        echo "[WARN] Both gpg and gpg2 are not found."
    fi
    echo -e "    <<<<<<<<<< ---------- decrypt files and handle keys ---------- <<<<<<<<<<\n"
}


# download a file by curl
# arguments: curl_source, curl_target, curl_option
function download() {
    local curl_source="$1"
    local curl_target="$2"
    local curl_default_options="-H \"Cache-Control: no-cache\" -L -S -s -t utf-8"
    local curl_option="$3 ${curl_default_options}"
    local curl_secret="$(echo $3 | sed -E "s#: [^ ]+#: <secret>'#g") ${curl_default_options}"
    (>&2 echo "test contents between ${curl_target} and '${curl_source}'")
    if [[ -f ${curl_target} ]] && [[ -z "$(diff ${curl_target} <(sh -c "set -e; curl ${curl_option} '${curl_source}' 2>&1"))" ]]; then
        (>&2 echo "contents identical, skip download")
        return 0
    else
        if [[ ! -d $(dirname ${curl_target}) ]]; then mkdir -p $(dirname ${curl_target}); fi
        (>&2 echo "curl ${curl_secret} -o ${curl_target} '${curl_source}' 2>/dev/null")
        sh -c "set -e; curl ${curl_option} -o ${curl_target} '${curl_source}' 2>/dev/null"
        return $?
    fi
}

# download a file by curl only when file exists
# arguments: curl_source, curl_target, curl_option
function download_if_exists() {
    if [[ "$(is_remote_resource_exists "$1" "$3")" == "true" ]]; then
        download "$1" "$2" "$3"
        ret=$?
        (>&2 echo "ret ${ret}, download $1 $2")
        return ${ret}
    else
        return 1
    fi
}

# arguments: curl_source, curl_option
function is_remote_resource_exists() {
    local curl_source="$1"
    local curl_default_options="-H \"Cache-Control: no-cache\" -L -s -t utf-8"
    local curl_option="$2 ${curl_default_options}"
    local curl_secret="$(echo $2 | sed -E "s#: [^ ]+#: <secret>'#g") ${curl_default_options}"
    (>&2 echo "Test whether remote file exists: curl -I -o /dev/null -w \"%{http_code}\" ${curl_secret} '${curl_source}' | tail -n1")
    local status_code=$(sh -c "curl -I -o /dev/null -w \"%{http_code}\" ${curl_option} '${curl_source}' | tail -n1 || echo -n 500")
    (>&2 echo "status_code: ${status_code}")
    if [[ "200" == "${status_code}" ]]; then echo "true"; else echo "false"; fi
}
# get slug info of current repository (directory)
# return: 'group/project' or 'owner/project'
function git_repo_slug() {
    # test cases
    # echo "Fetch URL: http://user@pass:gitservice.org:20080/owner/repo.git" | ruby -ne 'puts /^\s*Fetch.*(:|\/){1}([^\/]+\/[^\/]+).git/.match($_)[2] rescue nil'
    # echo "Fetch URL: Fetch URL: git@github.com:ci-and-cd/maven-build.git" | ruby -ne 'puts /^\s*Fetch.*(:|\/){1}([^\/]+\/[^\/]+).git/.match($_)[2] rescue nil'
    # echo "Fetch URL: https://github.com/owner/repo.git" | ruby -ne 'puts /^\s*Fetch.*(:|\/){1}([^\/]+\/[^\/]+).git/.match($_)[2] rescue nil'
    local repo_slug=""
    if [[ -n "${TRAVIS_REPO_SLUG}" ]]; then
        repo_slug="${TRAVIS_REPO_SLUG}"
    elif [[ -n "${APPVEYOR_REPO_NAME}" ]]; then
        repo_slug="${APPVEYOR_REPO_NAME}"
    elif [[ -n "${CI_PROJECT_PATH}" ]]; then
        repo_slug="${CI_PROJECT_PATH}"
    elif [[ -d .git ]]; then
        repo_slug=$(git remote show origin -n | ruby -ne 'puts /^\s*Fetch.*(:|\/){1}([^\/]+\/[^\/]+).git/.match($_)[2] rescue nil')
    else
        (>&2 echo "[ERROR] Can not find value for git_repo_slug, exit")
        return 1
    fi
    (>&2 echo "git_repo_slug result: ${repo_slug}")
    echo "${repo_slug}"
}

# >>>>>>>>>> ---------- CI option functions ---------- >>>>>>>>>>
# returns: true or false
function ci_opt_use_docker() {
    if [[ -n "${CI_OPT_DOCKER}" ]]; then
        echo "${CI_OPT_DOCKER}"
    else
        # TODO Support named pipe (for windows).
        # Unix sock file
        if [[ -f /var/run/docker.sock ]] || [[ -L /var/run/docker.sock ]]; then docker_sock_file_present="true"; fi
        # TCP
        if [[ -n "${DOCKER_HOST}" ]]; then docker_host_var_present="true"; fi
        if [[ -n "$(find . -name '*Docker*')" ]] || [[ -n "$(find . -name '*docker-compose*.yml')" ]]; then docker_files_found="true"; fi
        if ([[ "${docker_sock_file_present}" == "true" ]] || [[ "${docker_host_var_present}" == "true" ]]) && [[ "${docker_files_found}" == "true" ]]; then
            echo "true"
        else
            echo "false"
        fi
    fi
}

# returns: git commit id
function ci_opt_git_commit_id() {
    if [[ -n "${CI_OPT_GIT_COMMIT_ID}" ]]; then
        echo "${CI_OPT_GIT_COMMIT_ID}"
    else
        echo "$(git rev-parse HEAD)"
    fi
}

function ci_opt_cache_directory() {
    local cache_directory=""
    if [[ -n "${CI_OPT_CACHE_DIRECTORY}" ]]; then
        cache_directory="${CI_OPT_CACHE_DIRECTORY}"
    else
        cache_directory="${HOME}/.ci-and-cd/tmp/$(ci_opt_git_commit_id)"
    fi
    mkdir -p ${cache_directory} 2>/dev/null
    echo "${cache_directory}"
}

# determine current is origin (original) or forked
function ci_opt_is_origin_repo() {
    if [[ -n "${CI_OPT_ORIGIN_REPO}" ]]; then
        echo "${CI_OPT_ORIGIN_REPO}"
    else
        if [[ -z "${CI_OPT_ORIGIN_REPO_SLUG}" ]]; then CI_OPT_ORIGIN_REPO_SLUG="unknown/unknown"; fi
        if ([[ "${CI_OPT_ORIGIN_REPO_SLUG}" == "$(git_repo_slug)" ]] && [[ "${TRAVIS_EVENT_TYPE}" != "pull_request" ]] && [[ -z "${APPVEYOR_PULL_REQUEST_HEAD_REPO_NAME}" ]]); then
            echo "true";
        else
            echo "false";
        fi
    fi
}

# auto detect current build ref name by CI environment variables or local git info
# gitlab-ci
# ${CI_REF_NAME} show branch or tag since GitLab-CI 5.2
# CI_REF_NAME for gitlab 8.x, see: https://gitlab.com/help/ci/variables/README.md
# CI_COMMIT_REF_NAME for gitlab 9.x, see: https://gitlab.com/help/ci/variables/README.md
#
# travis-ci
# TRAVIS_BRANCH for travis-ci, see: https://docs.travis-ci.com/user/environment-variables/
# for builds triggered by a tag, this is the same as the name of the tag (TRAVIS_TAG).
#
# appveyor
# APPVEYOR_REPO_BRANCH - build branch. For Pull Request commits it is base branch PR is merging into
# APPVEYOR_REPO_TAG - true if build has started by pushed tag; otherwise false
# APPVEYOR_REPO_TAG_NAME - contains tag name for builds started by tag; otherwise this variable is
# returns: current build ref name, i.e. develop, release ...
function ci_opt_ref_name() {
    if [[ -n "${CI_OPT_GIT_REF_NAME}" ]]; then
        echo "${CI_OPT_GIT_REF_NAME}"
    elif [[ -n "${TRAVIS_BRANCH}" ]]; then
        echo "${TRAVIS_BRANCH}"
    elif [[ -n "${APPVEYOR_REPO_TAG}" ]]; then
        if [[ "${APPVEYOR_REPO_TAG_NAME}" == "false" ]]; then echo "${APPVEYOR_REPO_TAG}"; else echo "${APPVEYOR_REPO_BRANCH}"; fi
    elif [[ -n "${CI_REF_NAME}" ]]; then
        echo "${CI_REF_NAME}"
    elif [[ -n "${CI_COMMIT_REF_NAME}" ]]; then
        echo "${CI_COMMIT_REF_NAME}"
    elif [[ -d .git ]] || [[ -f .git ]]; then
        # .git is a file in git submodule
        echo "$(git symbolic-ref -q --short HEAD || git describe --tags --exact-match)"
    else
        (>&2 echo "Can not find value for CI_OPT_GIT_REF_NAME, using default value 'master'")
        echo "master"
    fi
}

# auto determine current build publish channel by current build ref name
# arguments: ci_opt_ref_name
function ci_opt_publish_channel() {
    if [[ -n "${CI_OPT_PUBLISH_CHANNEL}" ]]; then
        echo "${CI_OPT_PUBLISH_CHANNEL}"
    else
        case "$(ci_opt_ref_name)" in
        "develop")
            echo "snapshot"
            ;;
        hotfix*)
            echo "release"
            ;;
        release*)
            echo "release"
            ;;
        support*)
            echo "release"
            ;;
        *)
            echo "snapshot"
            ;;
        esac
    fi
}

function ci_opt_publish_to_repo() {
    if [[ -n "${CI_OPT_PUBLISH_TO_REPO}" ]]; then
        echo "${CI_OPT_PUBLISH_TO_REPO}"
    else
        local ref_name="$(ci_opt_ref_name)"
        if [[ "$(ci_opt_is_origin_repo)" == "true" ]]; then
            case "${ref_name}" in
            "develop")
                echo "true"
                ;;
            feature*)
                echo "true"
                ;;
            hotfix*)
                echo "true"
                ;;
            release*)
                echo "true"
                ;;
            support*)
                echo "true"
                ;;
            *)
                echo "false"
                ;;
            esac
        else
            case "${ref_name}" in
            "develop")
                echo "false"
                ;;
            feature*)
                echo "true"
                ;;
            hotfix*)
                echo "false"
                ;;
            release*)
                echo "false"
                ;;
            support*)
                echo "false"
                ;;
            *)
                echo "false"
                ;;
            esac
        fi
    fi
}

function ci_opt_site() {
    if [[ -n "${CI_OPT_SITE}" ]]; then
        echo "${CI_OPT_SITE}"
    else
        echo "false"
    fi
}

function ci_opt_site_path_prefix() {
    if [[ -n "${CI_OPT_SITE_PATH_PREFIX}" ]]; then
        echo "${CI_OPT_SITE_PATH_PREFIX}"
    else
        echo $(echo $(git_repo_slug) | cut -d '/' -f2-)
    fi
}
# <<<<<<<<<< ---------- CI option functions ---------- <<<<<<<<<<


function ci_infra_opt_git_auth_token() {
    if [[ -n "${CI_OPT_GIT_AUTH_TOKEN}" ]]; then
        echo "${CI_OPT_GIT_AUTH_TOKEN}"
    else
        local var_name="CI_OPT_$(echo $(ci_opt_infrastructure) | tr '[:lower:]' '[:upper:]')_GIT_AUTH_TOKEN"
        (>&2 echo "ci_infra_opt_git_auth_token var_name: ${var_name}")
        if [[ -n "${BASH_VERSION}" ]]; then
            (>&2 echo "ci_infra_opt_git_auth_token BASH_VERSION: ${BASH_VERSION}")
            echo "${!var_name}"
        elif [[ -n "${ZSH_VERSION}" ]]; then
            (>&2 echo "ci_infra_opt_git_auth_token ZSH_VERSION: ${ZSH_VERSION}")
            echo "${(P)var_name}"
        else
            (>&2 echo "[ERROR] unsupported ${SHELL}")
            return 1
        fi
    fi
}


# Build MAVEN_OPTS by variables from CI_OPT_CI_OPTS_FILE and CI_OPT_*
function ci_opt_maven_opts() {
    if [[ -n "${CI_OPT_MAVEN_OPTS}" ]]; then
        echo "${CI_OPT_MAVEN_OPTS}"
    else
        local opts="${MAVEN_OPTS}"

        opts="${opts} -Dpublish.channel=$(ci_opt_publish_channel)"
        if [[ -n "${CI_OPT_CHECKSTYLE_CONFIG_LOCATION}" ]]; then opts="${opts} -Dcheckstyle.config.location=${CI_OPT_CHECKSTYLE_CONFIG_LOCATION}"; fi
        if [[ "${CI_OPT_MAVEN_CLEAN_SKIP}" == "true" ]]; then opts="${opts} -Dmaven.clean.skip=true"; fi
        if [[ "${CI_OPT_DEPENDENCY_CHECK}" == "true" ]]; then opts="${opts} -Ddependency-check=true"; fi

        opts="${opts} -Dgpg.executable=${CI_OPT_GPG_EXECUTABLE}"
        if version_gt $(${CI_OPT_GPG_EXECUTABLE} --batch=true --version | { grep -E '[0-9]+\.[0-9]+\.[0-9]+' || true; } | head -n1 | awk '{print $NF}') "2.1"; then
            opts="${opts} -Dgpg.loopback=true"
        fi

        if [[ -n "${CI_OPT_DOCKER_REGISTRY}" ]] && [[ "${CI_OPT_DOCKER_REGISTRY}" != *docker.io ]]; then opts="${opts} -Ddocker.registry=${CI_OPT_DOCKER_REGISTRY}"; fi
        if [[ -n "${CI_OPT_DOCKER_IMAGE_PREFIX}" ]]; then opts="${opts} -Ddocker.image.prefix=${CI_OPT_DOCKER_IMAGE_PREFIX}"; fi
        if [[ -n "${CI_OPT_DOCKERFILE_USEMAVENSETTINGSFORAUTH}" ]]; then opts="${opts} -Ddockerfile.useMavenSettingsForAuth=${CI_OPT_DOCKERFILE_USEMAVENSETTINGSFORAUTH}"; fi
        opts="${opts} -Dfile.encoding=UTF-8"
        if [[ -n "${CI_OPT_FRONTEND_NODEDOWNLOADROOT}" ]]; then opts="${opts} -Dfrontend.nodeDownloadRoot=${CI_OPT_FRONTEND_NODEDOWNLOADROOT}"; fi
        if [[ -n "${CI_OPT_FRONTEND_NPMDOWNLOADROOT}" ]]; then opts="${opts} -Dfrontend.npmDownloadRoot=${CI_OPT_FRONTEND_NPMDOWNLOADROOT}"; fi
        opts="${opts} -Dinfrastructure=$(ci_opt_infrastructure)"
        if [[ "${CI_OPT_SKIPITS}" == "true" ]]; then opts="${opts} -DskipITs=true"; else opts="${opts} -DskipITs=false"; fi
        if [[ "${CI_OPT_JACOCO}" == "true" ]]; then opts="${opts} -Djacoco=true"; elif [[ "${CI_OPT_JACOCO}" == "false" ]]; then opts="${opts} -Djacoco=false"; fi
        if [[ "${CI_OPT_MAVEN_TEST_FAILURE_IGNORE}" == "true" ]]; then opts="${opts} -Dmaven.test.failure.ignore=true"; fi
        if [[ "${CI_OPT_MAVEN_TEST_SKIP}" == "true" ]]; then opts="${opts} -Dmaven.test.skip=true"; else opts="${opts} -Dmaven.test.skip=false"; fi
        if [[ "${CI_OPT_MVN_MULTI_STAGE_BUILD}" == "true" ]]; then opts="${opts} -Dmvn.multi.stage.build=true"; fi
        if [[ -n "${CI_OPT_PMD_RULESET_LOCATION}" ]]; then opts="${opts} -Dpmd.ruleset.location=${CI_OPT_PMD_RULESET_LOCATION}"; fi
        opts="${opts} -Dsite=$(ci_opt_site)"
        opts="${opts} -Dsite.path=$(ci_opt_site_path_prefix)/$(ci_opt_publish_channel)"
        if [[ "$(ci_opt_site)" == "true" ]] && [[ "$(ci_opt_infrastructure)" == "ossrh" ]]; then
            if [[ "${CI_OPT_GITHUB_SITE_PUBLISH}" == "true" ]]; then
                opts="${opts} -Dgithub.site.publish=true"
            else
                opts="${opts} -Dgithub.site.publish=false"
            fi
        fi
        # if sonar=true, jacoco should be set to true also
        if [[ "${CI_OPT_SONAR}" == "true" ]]; then opts="${opts} -Dsonar=true -Djacoco=true"; fi
        opts="${opts} -Duser.language=zh -Duser.region=CN -Duser.timezone=Asia/Shanghai"
        if [[ -n "${CI_OPT_WAGON_MERGEMAVENREPOS_SOURCE}" ]]; then opts="${opts} -Dwagon.merge-maven-repos.source=${CI_OPT_WAGON_MERGEMAVENREPOS_SOURCE} -DaltDeploymentRepository=repo::default::file://${CI_OPT_WAGON_MERGEMAVENREPOS_SOURCE}"; fi

        if [[ "${CI_OPT_SONAR}" == "true" ]] && [[ -n "${CI_OPT_SONAR_HOST_URL}" ]]; then opts="${opts} -D$(ci_opt_infrastructure).sonar.host.url=${CI_OPT_SONAR_HOST_URL}"; fi
        if [[ "${CI_OPT_SONAR}" == "true" ]] && [[ -n "${CI_OPT_SONAR_LOGIN}" ]]; then opts="${opts} -Dsonar.login=${CI_OPT_SONAR_LOGIN}"; fi
        if [[ "${CI_OPT_SONAR}" == "true" ]] && [[ -n "${CI_OPT_SONAR_PASSWORD}" ]]; then opts="${opts} -Dsonar.password=${CI_OPT_SONAR_PASSWORD}"; fi
        if [[ -n "${CI_OPT_NEXUS3}" ]]; then opts="${opts} -D$(ci_opt_infrastructure)-nexus3.repository=${CI_OPT_NEXUS3}repository"; fi

        # MAVEN_OPTS that need to kept secret
        if [[ -n "${CI_OPT_JIRA_PROJECTKEY}" ]]; then opts="${opts} -Djira.projectKey=${CI_OPT_JIRA_PROJECTKEY} -Djira.user=${CI_OPT_JIRA_USER} -Djira.password=${CI_OPT_JIRA_PASSWORD}"; fi
        # public sonarqube config, see: https://sonarcloud.io
        if [[ "${CI_OPT_SONAR}" == "true" ]] && [[ -n "${CI_OPT_SONAR_ORGANIZATION}" ]] && [[ "$(ci_opt_infrastructure)" == "ossrh" ]]; then opts="${opts} -Dsonar.organization=${CI_OPT_SONAR_ORGANIZATION}"; fi
        if [[ -n "${CI_OPT_MAVEN_SETTINGS_SECURITY_FILE}" ]] && [[ -f "${CI_OPT_MAVEN_SETTINGS_SECURITY_FILE}" ]]; then opts="${opts} -Dsettings.security=${CI_OPT_MAVEN_SETTINGS_SECURITY_FILE}"; fi

        echo "${opts}"
    fi
}

# Build GRADLE_PROPERTIES by variables from CI_OPT_CI_OPTS_FILE and CI_OPT_*
function ci_opt_gradle_properties() {
    if [[ -n "${CI_OPT_GRADLE_PROPERTIES}" ]]; then
        echo "${CI_OPT_GRADLE_PROPERTIES}"
    else
        local properties="";
        if [[ -n "${CI_OPT_GRADLE_INIT_SCRIPT}" ]]; then properties="${properties} --init-script ${CI_OPT_GRADLE_INIT_SCRIPT}"; fi
        properties="${properties} -Pinfrastructure=$(ci_opt_infrastructure)"
        properties="${properties} -PtestFailureIgnore=${CI_OPT_MAVEN_TEST_FAILURE_IGNORE}"
        properties="${properties} -Psettings=${CI_OPT_MAVEN_SETTINGS_FILE}"
        if [[ -n "${CI_OPT_MAVEN_SETTINGS_SECURITY_FILE}" ]]; then properties="${properties} -Psettings.security=${CI_OPT_MAVEN_SETTINGS_SECURITY_FILE}"; fi
        echo "${properties}"
    fi
}

function init_docker_config() {
    if [[ ! -d "${HOME}/.docker/" ]]; then echo "mkdir ${HOME}/.docker/ "; mkdir -p "${HOME}/.docker/"; fi

    if [[ "${CI_OPT_DRYRUN}" != "true" ]]; then
        if [[ -n "${CI_OPT_DOCKER_REGISTRY_PASS}" ]] && [[ -n "${CI_OPT_DOCKER_REGISTRY_USER}" ]] && [[ -n "${CI_OPT_DOCKER_REGISTRY}" ]]; then
            if [[ "${CI_OPT_DOCKER_REGISTRY_URL}" == https* ]]; then
                (>&2 echo "docker logging into secure registry ${CI_OPT_DOCKER_REGISTRY} (${CI_OPT_DOCKER_REGISTRY_URL})")
                (>&2 echo logging into secure registry ${CI_OPT_DOCKER_REGISTRY})
                echo ${CI_OPT_DOCKER_REGISTRY_PASS} | docker login --password-stdin -u="${CI_OPT_DOCKER_REGISTRY_USER}" ${CI_OPT_DOCKER_REGISTRY}
            else
                (>&2 echo "docker logging into insecure registry ${CI_OPT_DOCKER_REGISTRY} (${CI_OPT_DOCKER_REGISTRY_URL})")
                (>&2 echo logging into insecure registry ${CI_OPT_DOCKER_REGISTRY})
                echo ${CI_OPT_DOCKER_REGISTRY_PASS} | DOCKER_OPTS="–insecure-registry ${CI_OPT_DOCKER_REGISTRY}" docker login --password-stdin -u="${CI_OPT_DOCKER_REGISTRY_USER}" ${CI_OPT_DOCKER_REGISTRY}
            fi
            (>&2 echo "docker login done")
        else
            (>&2 echo "skip docker login")
        fi
    fi
}

function pull_base_image() {
    if type -p docker > /dev/null; then
        local dockerfiles=($(find . -name '*Docker*' | grep -Ev '.+/.+\..+' | grep -v '/target/classes/'))
        echo "Found ${#dockerfiles[@]} Dockerfiles, '${dockerfiles[@]}'"
        # maven could not resolve sibling dependencies on first build of a version
        #if [[ ${#dockerfiles[@]} -gt 0 ]]; then
        #    echo ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -e process-resources
        #    ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -e process-resources
        #fi

        local base_images=($(find . -name '*Docker*' | grep -Ev '.+/.+\..+' | grep -v '/target/classes/' | xargs cat | { grep -E '^FROM' || true; } | awk '{print $2}' | uniq))
        echo "Found ${#base_images[@]} base images, '${base_images[@]}'"
        if [[ ${#base_images[@]} -gt 0 ]]; then
            for base_image in ${base_images[@]}; do docker pull ${base_image}; done
        fi
    fi
}


# download a file by curl only when file exists
# arguments: source_file, target_file
function download_from_git_repo() {
    local source_file="$1"
    local target_file="$2"

    local curl_options="-H \"PRIVATE-TOKEN: $(ci_infra_opt_git_auth_token)\""

    if [[ "${CI_OPT_MAVEN_BUILD_OPTS_REPO}" =~ ^.+/api/v4/projects/[0-9]+/repository/.+$ ]]; then
        if download_if_exists "${CI_OPT_MAVEN_BUILD_OPTS_REPO}/$(echo ${source_file} | sed 's#/#%2F#g')?ref=master" "${target_file}.json" "${curl_options}"; then
            (>&2 echo decode ${target_file}.json)
            cat "${target_file}.json" | jq -r ".content" | base64 --decode | tee "${target_file}"
        else
            (>&2 echo "[ERROR] can not download ${target_file}")
            # TODO log output 'please make sure you have permission to access resources and CI_OPT_GIT_AUTH_TOKEN is defined correctly'
            return 1
        fi
    else
        download_if_exists "${CI_OPT_MAVEN_BUILD_OPTS_REPO}/raw/master/${source_file}" "${target_file}" "${curl_options}"
        return $?
    fi
}


function alter_mvn() {
    (>&2 echo "alter_mvn is_origin_repo: $(ci_opt_is_origin_repo), ref_name: $(ci_opt_ref_name), args: $@")

    goals=()
    result=()

    for element in $@; do
        if [[ "${element}" == "mvn" ]] || [[ "${element}" == "${MVN_CMD}" ]]; then
            #(>&2 echo "alter_mvn command '${element}' found")
            continue
        elif [[ "${element}" == -* ]]; then
            (>&2 echo "alter_mvn property '${element}' found")
            result+=("${element}")
        else
            (>&2 echo "alter_mvn goal '${element}' found")

            if [[ "${element}" == *deploy ]] && [[ "${element}" != *site* ]]; then
            # deploy, site-deploy, push (docker)
                if [[ "$(ci_opt_publish_to_repo)" == "true" ]]; then
                    if [[ "${CI_OPT_MVN_MULTI_STAGE_BUILD}" == "true" ]]; then
                    # maven multi stage build
                        goals+=("org.codehaus.mojo:wagon-maven-plugin:merge-maven-repos@merge-maven-repos-deploy")
                        if [[ "$(ci_opt_use_docker)" == "true" ]]; then goals+=("dockerfile:push"); fi
                    else
                        goals+=("${element}")
                    fi
                else
                    (>&2 echo "skip ${element}")
                fi
            elif [[ "${element}" == *site* ]]; then
                # if ci_opt_site=false, do not build site
                if [[ "$(ci_opt_site)" == "true" ]]; then
                    goals+=("${element}")
                else
                    (>&2 echo "skip ${element}")
                fi
            elif ([[ "${element}" == *clean ]] || [[ "${element}" == *install ]]); then
            # goals need to alter
                if [[ "${CI_OPT_MVN_MULTI_STAGE_BUILD}" == "true" ]]; then
                # maven multi stage build
                    if [[ "${element}" == *clean ]]; then
                        goals+=("clean")
                        goals+=("org.apache.maven.plugins:maven-antrun-plugin:run@wagon-repository-clean")
                    elif [[ "${element}" == *install ]]; then
                        goals+=("deploy")
                        if [[ "$(ci_opt_use_docker)" == "true" ]]; then goals+=("dockerfile:build"); fi
                    fi
                else
                    goals+=("${element}")
                fi
            elif [[ "${element}" == *sonar ]]; then
                if [[ "$(ci_opt_ref_name)" == "develop" ]] && [[ "$(ci_opt_is_origin_repo)" == "true" ]]; then
                    goals+=("${element}")
                else
                    (>&2 echo "skip ${element}")
                fi
            else
                # if not origin repo (forked)
                goals+=("${element}")
                #(>&2 echo "alter_mvn (forked repo) drop '${element}'")
            fi
        fi
    done

    for goal in ${goals[@]}; do result+=("${goal}"); done
    (>&2 echo "alter_mvn output: ${result[*]}")
    echo "${result[*]}"
}

function run_mvn() {
    echo -e "\n>>>>>>>>>> ---------- run_mvn toolchains.xml ---------- >>>>>>>>>>"
#    # always down toolchains.xml on travis-ci build
#    if [[ ! -f "${HOME}/.m2/toolchains.xml" ]] || [[ -n "${TRAVIS_EVENT_TYPE}" ]]; then
#        download_from_git_repo "src/main/maven/toolchains.xml" "${HOME}/.m2/toolchains.xml"
#    else
#        echo "Found ${HOME}/.m2/toolchains.xml"
#        cat ${HOME}/.m2/toolchains.xml
#    fi
    if ! download_from_git_repo "src/main/maven/toolchains-$(os_name).xml" "${HOME}/.m2/toolchains.xml"; then
        echo "[ERROR] can not download src/main/maven/toolchains.xml"
        return 1
    fi
    echo -e "<<<<<<<<<< ---------- run_mvn toolchains.xml ---------- <<<<<<<<<<\n"

    echo -e "\n>>>>>>>>>> ---------- run_mvn settings.xml and settings-security.xml ---------- >>>>>>>>>>"
    # Maven settings.xml
    if [[ -z "${CI_OPT_MAVEN_SETTINGS}" ]]; then
        if [[ -z "${CI_OPT_MAVEN_SETTINGS_FILE}" ]]; then CI_OPT_MAVEN_SETTINGS_FILE="$(pwd)/src/main/maven/settings.xml"; fi
        if [[ ! -f ${CI_OPT_MAVEN_SETTINGS_FILE} ]]; then
            CI_OPT_MAVEN_SETTINGS_FILE="$(ci_opt_cache_directory)/settings-$(ci_opt_infrastructure).xml"
            if download_from_git_repo "src/main/maven/settings.xml" "${CI_OPT_MAVEN_SETTINGS_FILE}"; then
                CI_OPT_MAVEN_SETTINGS="-s ${CI_OPT_MAVEN_SETTINGS_FILE}"
            else
                echo "[ERROR] can not download src/main/maven/settings.xml"
                return 1
            fi
        else
            echo "Found ${CI_OPT_MAVEN_SETTINGS_FILE}"
            cp -f ${CI_OPT_MAVEN_SETTINGS_FILE} $(ci_opt_cache_directory)/settings-$(ci_opt_infrastructure).xml
            CI_OPT_MAVEN_SETTINGS="-s $(ci_opt_cache_directory)/settings-$(ci_opt_infrastructure).xml"
        fi
    fi
    echo "CI_OPT_MAVEN_SETTINGS: ${CI_OPT_MAVEN_SETTINGS}"

    # Download maven's settings-security.xml if current infrastructure has this file
    download_from_git_repo "src/main/maven/settings-security.xml" "${HOME}/.m2/settings-security.xml" || echo "[WARN] settings-security.xml not found or can not download."
    echo -e "<<<<<<<<<< ---------- run_mvn settings.xml and settings-security.xml ---------- <<<<<<<<<<\n"

    echo -e "\n>>>>>>>>>> ---------- run_mvn properties and environment variables ---------- >>>>>>>>>>"
    # Load infrastructure specific ci options (CI_OPT_CI_OPTS_FILE)
    if [[ ! -f "${CI_OPT_CI_OPTS_FILE}" ]]; then
        if [[ -f ../maven-build-opts-$(ci_opt_infrastructure)/${CI_OPT_CI_OPTS_FILE} ]]; then
            # for maven-build* developer
            eval "$(cat ../maven-build-opts-$(ci_opt_infrastructure)/${CI_OPT_CI_OPTS_FILE})"
        else
            # for maven-build* user
            if download_from_git_repo "${CI_OPT_CI_OPTS_FILE}" "$(ci_opt_cache_directory)/${CI_OPT_CI_OPTS_FILE}"; then
                . $(ci_opt_cache_directory)/${CI_OPT_CI_OPTS_FILE}
            else
                echo "[WARN] can not download ${CI_OPT_CI_OPTS_FILE}"
            fi
        fi
    else
        . ${CI_OPT_CI_OPTS_FILE}
    fi

    if [[ "ossrh" == "$(ci_opt_infrastructure)" ]]; then
        if [[ -z "${CI_OPT_GITHUB_GLOBAL_REPOSITORYNAME}" ]]; then CI_OPT_GITHUB_GLOBAL_REPOSITORYNAME="$(ci_opt_site_path_prefix)"; fi
        if [[ -z "${CI_OPT_GITHUB_GLOBAL_REPOSITORYOWNER}" ]]; then CI_OPT_GITHUB_GLOBAL_REPOSITORYOWNER="$(echo $(git_repo_slug) | cut -d '/' -f1-)"; fi
        # export and expose to maven sub process
        export CI_OPT_GITHUB_GLOBAL_REPOSITORYNAME
        export CI_OPT_GITHUB_GLOBAL_REPOSITORYOWNER
    fi

    if [[ -z "${CI_OPT_MAVEN_EFFECTIVE_POM}" ]]; then CI_OPT_MAVEN_EFFECTIVE_POM="true"; fi
    if [[ -z "${CI_OPT_MAVEN_EFFECTIVE_POM_FILE}" ]]; then CI_OPT_MAVEN_EFFECTIVE_POM_FILE="$(ci_opt_cache_directory)/effective-pom.xml"; fi
    echo -e "<<<<<<<<<< ---------- run_mvn properties and environment variables ---------- <<<<<<<<<<\n"

    echo -e "\n>>>>>>>>>> ---------- run_mvn alter_mvn ---------- >>>>>>>>>>"
    local altered=$(alter_mvn $@)
    echo "alter_mvn result: ${MVN_CMD} ${altered}"
    local mvn_opts_and_goals=("${altered}")
    local mvn_goals=()
    for element in ${mvn_opts_and_goals[@]}; do if [[ "${element}" == -* ]]; then continue; else mvn_goals+=("${element}"); fi; done
    echo "alter_mvn found ${#mvn_goals[@]} goals: ${mvn_goals[@]}"
    if [[ ${#mvn_goals[@]} -eq 0 ]]; then
        echo "[WARN] There are not goals to run, exit.";
        return 0;
    fi
    echo -e "<<<<<<<<<< ---------- run_mvn alter_mvn ---------- <<<<<<<<<<\n"

    if [[ -n "${CI_OPT_DOCKER_REGISTRY_URL}" ]]; then
        CI_OPT_DOCKER_REGISTRY=$(echo "${CI_OPT_DOCKER_REGISTRY_URL}" | awk -F/ '{print $3}')
    fi

    echo -e "\n>>>>>>>>>> ---------- run_mvn options ---------- >>>>>>>>>>"
    export MAVEN_OPTS="$(ci_opt_maven_opts)"
    set | grep -E '^CI_OPT_' | filter_secret_variables || echo "no any CI_OPT_* present"
    set | grep -E '^CI_OPT_' | filter_secret_variables || echo "no any CI_OPT_* present"
    echo MAVEN_OPTS=${MAVEN_OPTS} | filter_secret_variables || echo "no MAVEN_OPTS present"
    echo -e "\n<<<<<<<<<< ---------- run_mvn options ---------- <<<<<<<<<<\n"

    if [[ "$(ci_opt_use_docker)" == "true" ]]; then
        docker version
        # config and login
        init_docker_config

        # clean images
        echo find old docker images to clean
        local old_images=($(docker images | { grep 'none' || true; } | awk '{print $3}'))
        echo "Found ${#old_images[@]} old images, '${old_images[@]}'"
        if [[ ${#old_images[@]} -gt 0 ]]; then
            for old_image in ${old_images[@]}; do docker rmi ${old_image} || echo "error on clean image ${old_image}"; done
        fi
    fi

    echo -e "\n>>>>>>>>>> ---------- run_mvn project info ---------- >>>>>>>>>>"
    echo JAVA_HOME "'${JAVA_HOME}'"
    ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -version

    # Maven effective pom
    mkdir -p $(dirname ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE}) && touch ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE}
    if [[ "${CI_OPT_MAVEN_EFFECTIVE_POM}" == "true" ]] && [[ "${CI_OPT_DRYRUN}" != "true" ]]; then
        if [[ "${CI_OPT_SHELL_EXIT_ON_ERROR}" == "true" ]]; then set +e; fi
        if [[ "${CI_OPT_OUTPUT_MAVEN_EFFECTIVE_POM_TO_CONSOLE}" == "true" ]]; then
            if [[ -n "${TRAVIS_EVENT_TYPE}" ]]; then
                echo travis-ci has log limit of 10000 lines, merge every 10 lines of log into 1, avoid travis timeout and to much lines
                echo "${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -U -e help:effective-pom | awk 'NR%10{printf \"%s \",\$0;next;}1'' ..."
                ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -U -e help:effective-pom | awk 'NR%10{printf "%s ",$0;next;}1'
            elif [[ -n "${CI_COMMIT_REF_NAME}" ]]; then
                echo gitlab-ci has log limit of 4194304 bytes
                echo "${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -U -e help:effective-pom > ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE} ..."
                ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -U -e help:effective-pom > ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE}
            else
                echo "${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -U -e help:effective-pom >&3 ..."
                exec 3> >(tee ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE})
                ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -U -e help:effective-pom >&3
            fi
        else
            echo "${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -U -e help:effective-pom > ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE} ..."
            ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} -U -e help:effective-pom > ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE}
        fi
        if [[ $? -ne 0 ]]; then echo "[ERROR] error on generate effective-pom"; cat ${CI_OPT_MAVEN_EFFECTIVE_POM_FILE}; exit 1; else echo "effective-pom generated successfully"; fi
        if [[ "${CI_OPT_SHELL_EXIT_ON_ERROR}" == "true" ]]; then set -e -o pipefail; fi
    fi
    echo -e "<<<<<<<<<< ---------- run_mvn project info ---------- <<<<<<<<<<\n"

    echo -e "\n>>>>>>>>>> ---------- check project version ---------- >>>>>>>>>>"
    #local project_version=$(${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -Ev '(^\[|Download.+)')
    local project_version=$(${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} help:evaluate -Dexpression=project.version | grep -Ev '(^\[|Download.+)')
    if [[ "$(ci_opt_publish_channel)" == "snapshot" ]]; then
        if [[ "${project_version}" != *-SNAPSHOT ]]; then
            echo "Invalid version ${project_version} for ref $(ci_opt_ref_name)"
            echo "You should use versions like 1.0.0-SNAPSHOT with '-SNAPSHOT' suffix on develop branch or feature branches"
            exit 1
        elif [[ "$(ci_opt_ref_name)" != "develop" ]] && [[ "${project_version}" =~ ^([0-9]+\.){0,2}[0-9]+-SNAPSHOT$ ]]; then
            echo "Invalid version ${project_version} for ref $(ci_opt_ref_name)"
            echo "You should use versions like 1.0.0-feature_name-SNAPSHOT or 1.0.0-branch_name-SNAPSHOT on feature branches"
            exit 1
        fi
    else
        if [[ "${project_version}" == *-SNAPSHOT ]]; then
            echo "Invalid version ${project_version} for ref $(ci_opt_ref_name)"
            echo "You should use version like 1.0.0 without '-SNAPSHOT' suffix on releases"
            exit 1
        fi
    fi
    echo -e "<<<<<<<<<< ---------- check project version ---------- <<<<<<<<<<\n"

    echo -e "\n>>>>>>>>>> ---------- pull_base_image ---------- >>>>>>>>>>"
    if [[ "$(ci_opt_use_docker)" == "true" ]] && [[ "${CI_OPT_DRYRUN}" != "true" ]]; then
        pull_base_image
    fi
    echo -e "<<<<<<<<<< ---------- pull_base_image ---------- <<<<<<<<<<\n"

    #local altered="$@"
    local filter_script_file=$(filter_script "$(ci_opt_cache_directory)/filter")
    echo -e "\n>>>>>>>>>> ---------- ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} ${altered} | ${filter_script_file} ---------- >>>>>>>>>>"
    if [[ "${CI_OPT_DRYRUN}" != "true" ]]; then
        bash -c "set -e -o pipefail; ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} ${altered} | ${filter_script_file}"
    fi
    echo -e "<<<<<<<<<< ---------- ${MVN_CMD} ${CI_OPT_MAVEN_SETTINGS} ${altered} | ${filter_script_file} ---------- <<<<<<<<<<\n"
}

function run_gradle() {
    echo "run_gradle $@"
    if [[ "${CI_OPT_GRADLE_INIT_SCRIPT}" == http* ]]; then
        download "${CI_OPT_GRADLE_INIT_SCRIPT}" "$(ci_opt_cache_directory)/$(basename $(echo ${CI_OPT_GRADLE_INIT_SCRIPT}))" ""
        CI_OPT_GRADLE_INIT_SCRIPT="$(ci_opt_cache_directory)/$(basename $(echo ${CI_OPT_GRADLE_INIT_SCRIPT}))"
    fi

    # >>>>>>>>>> ---------- gradle properties and environment variables ---------- >>>>>>>>>>
    export GRADLE_PROPERTIES="$(ci_opt_gradle_properties)"
    # <<<<<<<<<< ---------- gradle properties and environment variables ---------- <<<<<<<<<<

    # >>>>>>>>>> ---------- gradle project info ---------- >>>>>>>>>>
    ${GRADLE_CMD} --stacktrace ${GRADLE_PROPERTIES} -version
    # <<<<<<<<<< ---------- gradle project info ---------- <<<<<<<<<<
}

## check if current repository is a spring-cloud-configserver's config repository
#function is_config_repository() {
#    if [[ "$(basename $(pwd))" == *-config ]] && ([[ -f "application.yml" ]] || [[ -f "application.properties" ]]); then
#        return
#    fi
#    false
#}


# see: https://qiita.com/narumi_888/items/e425f29b84da6b72ad62
if sed --version 2>/dev/null | grep -q GNU; then
    alias sedi='sed -i '
else
    alias sedi='sed -i "" '
    echo "[ERROR] Only GNU sed is supported."
    echo "Run 'brew install gnu-sed' to install GNU sed on Mac OSX"

    if [[ -f /usr/local/opt/gnu-sed/bin/gsed ]]; then
        export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
        export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
    fi
fi

if [[ "${CI_OPT_SHELL_PRINT_EXECUTED_COMMANDS}" == "true" ]]; then set -x; fi
# key line to make whole build process file when command using pipelines fails
if [[ "${CI_OPT_SHELL_EXIT_ON_ERROR}" == "true" ]]; then set -e -o pipefail; fi

echo -e "\n>>>>>>>>>> ---------- init options ---------- >>>>>>>>>>"
set | grep -E '^CI_OPT_' | filter_secret_variables || echo "no any CI_OPT_* present"
set | grep -E '^CI_OPT_' | filter_secret_variables || echo "no any CI_OPT_* present"
echo -e "\n<<<<<<<<<< ---------- init options ---------- <<<<<<<<<<\n"

echo -e "\n>>>>>>>>>> ---------- build context info ---------- >>>>>>>>>>"
echo "gitlab-ci variables: CI_REF_NAME: ${CI_REF_NAME}, CI_COMMIT_REF_NAME: ${CI_COMMIT_REF_NAME}, CI_PROJECT_URL: ${CI_PROJECT_URL}"
echo "travis-ci variables: TRAVIS_BRANCH: ${TRAVIS_BRANCH}, TRAVIS_EVENT_TYPE: ${TRAVIS_EVENT_TYPE}, TRAVIS_REPO_SLUG: ${TRAVIS_REPO_SLUG}, TRAVIS_PULL_REQUEST: ${TRAVIS_PULL_REQUEST}"
decrypt_files
if [[ -f "${HOME}/.bashrc" ]]; then source "${HOME}/.bashrc"; fi
echo "PWD: $(pwd)"
echo "USER: $(whoami)"
echo -e "<<<<<<<<<< ---------- build context info ---------- <<<<<<<<<<\n"

echo -e "\n>>>>>>>>>> ---------- important variables ---------- >>>>>>>>>>"
if [[ -z "${CI_OPT_MAVEN_BUILD_REPO}" ]]; then
    if [[ "${CI_OPT_CI_SCRIPT}" == http* ]]; then
        # test with: https://github.com/ci-and-cd/maven-build/raw/v2.0.0/src/main/ci-script/lib_ci.sh
        url_prefix="$(echo ${CI_OPT_CI_SCRIPT} | sed -r 's#/raw/.+#/raw#')"
        if [[ "$(git_repo_slug)" != "ci-and-cd/maven-build" ]]; then
            # For other projects, should use master branch by default.
            CI_OPT_MAVEN_BUILD_REPO="${url_prefix}/master"
        else
            # Use current branch for ci-and-cd/maven-build project
            CI_OPT_MAVEN_BUILD_REPO="${url_prefix}/$(ci_opt_ref_name)"
        fi
    elif [[ -n "${CI_OPT_CI_SCRIPT}" ]]; then
        # use current directory
        CI_OPT_MAVEN_BUILD_REPO=""
    else
        echo "[ERROR] Both CI_OPT_MAVEN_BUILD_REPO and CI_OPT_CI_SCRIPT are not set, exit."
        return 1
    fi
fi
if [[ -z "$(ci_infra_opt_git_auth_token)" ]]; then
    if [[ "$(ci_opt_is_origin_repo)" == "true" ]] && [[ "$(ci_opt_infrastructure)" != "ossrh" ]]; then
        echo "[ERROR] CI_OPT_GIT_AUTH_TOKEN not set and using origin private repo, exit."; return 1;
    else
        # For PR build on travis-ci or appveyor
        echo "[WARN] CI_OPT_GIT_AUTH_TOKEN not set.";
    fi
fi
echo -e "<<<<<<<<<< ---------- important variables ---------- <<<<<<<<<<\n"

echo -e "\n>>>>>>>>>> ---------- options with important variables ---------- >>>>>>>>>>"
set | grep -E '^CI_OPT_' | filter_secret_variables || echo "no any CI_OPT_* present"
set | grep -E '^CI_OPT_' | filter_secret_variables || echo "no any CI_OPT_* present"
echo -e "\n<<<<<<<<<< ---------- options with important variables ---------- <<<<<<<<<<\n"

# Load remote script library here

if [[ -f pom.xml ]]; then
    echo "MVN_CMD '${MVN_CMD}'"
    run_mvn $@
fi
if [[ -f build.gradle ]]; then
    echo "GRADLE_CMD '${GRADLE_CMD}'"
    run_gradle $@
fi
