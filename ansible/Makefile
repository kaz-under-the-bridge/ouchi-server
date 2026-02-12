.PHONY: ping all nfs ai check

ping:
	ansible all -m ping

all:
	ansible-playbook site.yml

nfs:
	ansible-playbook playbooks/nfs-server.yml

ai:
	ansible-playbook playbooks/ai-commander.yml

check:
	ansible-playbook site.yml --check --diff
