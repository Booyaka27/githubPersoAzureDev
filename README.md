# githubPersoAzureDev

You will find in this repository templates to use with Terraform and packer for Azure. These templates as already been retrieve from Stanislas.io blog and adapt to autotrain to my environment.

Credentials has to be inserted in packer template and terraform templates. Terraform is checking all tf files and roll them out in the necessary order to chain necessary ressources, so credentials are in a distinct file. Packer is working in the same way using specific command to load variables first ;) 
packer build -var-file=variables.json logstach.json


Remove credentials by using gitignore