Automate installation of tree on Linux

Example 1
=========
ansible-playbook installTree.yml -K

Example 2 (with ansible-vault)
==============================
ansible-vault create mylogin
ansible-vault decrypt mylogin
ansible-playbook installTree.yml -K --vault-password mylogin