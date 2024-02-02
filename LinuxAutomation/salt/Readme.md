Example
=======

sudo mkdir -p /srv/salt

sudo cp common.sls /srv/salt/common.sls

sudo salt-call --local state.sls common
