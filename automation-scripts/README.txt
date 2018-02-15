This project contains automation scripts of APIM 2.1.0 pattern deployment in K8s.

Follow the instructions to run the scripts.

1. Change the pattern no that need to be installed, in deploy.sh.
2. Make deploy.sh executable.
    chmod +x deploy.sh
3. Run deploy.sh with following arguments.
    ./deploy.sh K8s_master_url docker-server docker-username docker-password docker-email