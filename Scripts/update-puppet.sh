#!/bin/bash

VAGRANT_DIR="/vagrant"
LIBRARIAN_DIR="/tmp/librarian-puppet"

# Update puppet to latest version (bundled might be obsolete)
# and install librarian-puppet for module handling.
#
# Note: we need also git-core so that librarian can checkout GIT repositories.
if [ ! -e /var/puppet-updated ]; then
	apt-get update || exit 1
	apt-get --assume-yes install puppet git-core librarian-puppet || exit 1

	touch /var/puppet-updated
fi

# Check for any change in required puppet modules and install them
# TODO: support for Puppetfile.lock
if [ -e "$VAGRANT_DIR/Puppetfile" ]; then
	if [ ! -e "/var/puppetfile.md5" ] || [ ! -d "$LIBRARIAN_DIR" ] || ! `md5sum --status -c /var/puppetfile.md5` ; then
		echo "Puppetfile changed"
		md5sum "$VAGRANT_DIR/Puppetfile" > /var/puppetfile.md5

		[ ! -d "$LIBRARIAN_DIR" ] && mkdir -p "$LIBRARIAN_DIR"

		[ -e "$LIBRARIAN_DIR/Puppetfile" ] && rm "$LIBRARIAN_DIR/Puppetfile"
		ln -s "$VAGRANT_DIR/Puppetfile" "$LIBRARIAN_DIR/Puppetfile"
		cd "$LIBRARIAN_DIR"

		# Please remove GIT_SSL_NO_VERIFY once SpaceSSL certificates are added into
		# ca-certificates package or install them manually.
		# They are needed by our GitLab.
		GIT_SSL_NO_VERIFY=true librarian-puppet install --verbose --path /etc/puppet/modules || {
			rm /var/puppetfile.md5
			exit 1
		}
	fi
fi

exit 0