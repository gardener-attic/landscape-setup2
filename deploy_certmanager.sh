#!/bin/bash -eu

cd components
./deploy.sh certmanager
cd ..

# find position of the line '--oidc-ca-file=/etc/kubernetes/secrets/ca.crt' and save the array position of that entry within the yaml to variable
pos=$(kubectl -n kube-system get -o template ds kube-apiserver --template='{{range $i, $elem := (index .spec.template.spec.containers 0).command}}{{if eq $elem "--oidc-ca-file=/etc/kubernetes/secrets/ca.crt"}}{{$i}}{{end}}{{end}}')
if [ $pos ]; then
    # delete that entry
    kubectl -n kube-system patch ds kube-apiserver --type json -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/command/'$pos'"}]'
else
    echo "Line '--oidc-ca-file=/etc/kubernetes/secrets/ca.crt' not found in daemonset kube-apiserver."
    echo "It was supposed to be there and be deleted by this script, but if it's not in there, that should be fine too."
fi

echo "Certmanager successfully deployed!"