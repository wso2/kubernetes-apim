docker tag ${1}:2.1.0 us.gcr.io/steam-talent-167709/${1}:2.1.0
gcloud docker -- push us.gcr.io/steam-talent-167709/${1}:2.1.0

