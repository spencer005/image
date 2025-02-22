dnf() { command dnf5 -y "$@"; }

copr() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: copr [enable|disable] repo1 [repo2 ...]" >&2
        exit 1
    fi

    action="$1"
    if [ "$action" != "enable" ] && [ "$action" != "disable" ]; then
        echo "Invalid action: $action. Only 'enable' or 'disable' are supported." >&2
        exit 1
    fi
    shift

    for repo in "$@"; do
        dnf copr "$action" "$repo"
    done
}

remove_cliwrap() {
    if [ -d /usr/libexec/rpm-ostree/wrapped ]; then
        # binaries which could be created if they did not exist thus may not be in wrapped dir
        rm -f \
            /usr/bin/yum \
            /usr/bin/dnf \
            /usr/bin/kernel-install
        # binaries which were wrapped
        mv -f /usr/libexec/rpm-ostree/wrapped/* /usr/bin
        rm -fr /usr/libexec/rpm-ostree
    fi
}
