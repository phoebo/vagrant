#!/bin/bash

# Perform first time update / upgrade
if [ ! -e /var/ruby-updated ]; then
	apt-get remove ruby -y || exit 1
	apt-get install -y \
		curl \
		build-essential \
		g++

	mkdir /tmp/ruby
	cd /tmp/ruby || exit 1
	curl -L http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz | tar xz || exit 1
	cd ruby-2.1.5 || exit 1
	./configure || exit 1
	make || exit 1
	make install || exit 1
	cd /
	rm -rf /tmp/ruby
	gem install bundler || exit 1

	touch /var/ruby-updated
fi
